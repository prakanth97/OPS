import ops
from store import Application, ParseError, Program
import cpp.translator.kernels as ctk
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict, Any
import re
from clang.cindex import CursorKind, Cursor, TranslationUnit, Index
from xdsl.dialects.builtin import FloatAttr, f64, IntegerType, Float64Type
from xdsl.irdl import IRDLOperation, SSAValue
from xdsl.ir import Region, Block
from ops_dialect.ops_dialect import GetIndexOp, ReturnOp
from xdsl.dialects.stencil import AccessOp, ReduceOp, YieldOp
from xdsl.dialects import arith
from xdsl.dialects import math as math_dialect
import ops

@dataclass
class StencilAccess:
    field_name: str
    offsets: Tuple[int, ...]  # Variable length for up to 5D (OPS)MAX_DIM

@dataclass
class ReductionInfo:
    param_name: str
    access_type: ops.AccessType
    reduction_ast: Cursor

@dataclass 
class KernelInfo:
    name: str
    dim: int  # Dims
    param_order: List[str] # To maintain global parameter order
    read_fields: List[str]   # const ACC parameters
    write_fields: List[str]  # non-const ACC parameters
    write_targets: List[Tuple[StencilAccess, Cursor]]
    accesses: List[StencilAccess]
    computation_ast: Cursor
    has_idx_param: bool = False
    idx_param_name: Optional[str] = None
    reductions: List[ReductionInfo] = field(default_factory=list)

class KernelParser:
    
    def parseC(self, loop: ops.Loop, program: Program, app: Application) -> KernelInfo:
        kernel_entities = app.findEntities(loop.kernel, program)
        
        if len(kernel_entities) == 0:
            raise ParseError(f"Unable to find kernel: {loop.kernel}")
        
        extracted_entities = ctk.extractDependancies(kernel_entities, app)
        source = ctk.writeSource(extracted_entities)
        
        # Parse the extracted source
        translation_unit = self.parse_kernel_source(source)
        
        # Find and parse the kernel function
        kernel_func = self.find_kernel_function(translation_unit, loop.kernel)
        
        if not kernel_func:
            raise ParseError(f"Could not find kernel function: {loop.kernel}")
        
        kernel_info = self.parse_kernel_function(kernel_func, loop)
        
        return kernel_info
    
    
    def find_kernel_function(self, translation_unit: TranslationUnit, func_name: str) -> Optional[Cursor]:
        """Find the kernel function declaration"""
        for node in translation_unit.cursor.walk_preorder():
            if node.kind == CursorKind.FUNCTION_DECL and node.spelling == func_name:
                return node
        return None
    
    
    def parse_kernel_function(self, func_node: Cursor, loop: ops.Loop) -> KernelInfo:
        """Parse the kernel function to extract stencil information"""
        
        # 1. Extract parameters
        read_fields = []
        write_fields = []
        read_write_fields = []
        has_idx_param = False
        idx_param_name = None
        reduction_params = {}

        params = list(func_node.get_arguments())
        param_order = [param.spelling for param in params]
    
        # Match parameters to dats by position
        for i, param in enumerate(params):
            param_name = param.spelling
            
            if i >= len(loop.args):
                raise ParseError(f"Parameter {param_name} has no corresponding ops_dat")

            arg = loop.args[i]
            
            if isinstance(arg, ops.ArgIdx):
                has_idx_param = True
                idx_param_name = param_name
                continue

            if isinstance(arg, ops.ArgReduce):
                reduction_params[param_name] = arg.access_type
                continue

            access_type = arg.access_type

            if access_type == ops.AccessType.OPS_READ:
                read_fields.append(param_name)
            elif access_type == ops.AccessType.OPS_WRITE:
                write_fields.append(param_name)
            elif access_type == ops.AccessType.OPS_RW:
                read_write_fields.append(param_name)
                read_fields.append(param_name)
                write_fields.append(param_name)
            else:
                raise ParseError(f"Unknown access type: {access_type}")        

        # 2. Find the assignment statement in the function body
        reductions = self.find_reductions(func_node, reduction_params)
    
        # Collect reduction AST nodes to exclude from assignments
        reduction_nodes = {red.reduction_ast for red in reductions}
        
        # Find all assignments (will be filtered)
        all_assignment_nodes = self.find_all_assignments(func_node)
        print("PRINTING")
        print(all_assignment_nodes)
        
        # Filter out reductions from assignments
        assignment_nodes = [node for node in all_assignment_nodes if node not in reduction_nodes]
    
      
        if not assignment_nodes:
            raise ParseError(f"No assignment found in kernel {func_node.spelling}")
        
        # 3. Extract LHS (write target)
        write_targets = []
        all_accesses = []

        for assignment_node in assignment_nodes:

            lhs, rhs = self.split_assignment(assignment_node)
            write_target = self.parse_accessor(lhs, loop.ndim)
            write_targets.append((write_target, rhs))
        
            # 4. Extract all RHS accesses
            accesses = self.extract_accesses_from_expr(rhs, loop.ndim)
            all_accesses.extend(accesses)

        for reduction in reductions:
            # Get the RHS of the compound assignment (e.g., A(0,0) in *sum += A(0,0))
            children = list(reduction.reduction_ast.get_children())
            if len(children) > 1:
                rhs = children[1]
            else:
                rhs = children[0]
            
            # Extract accesses from the reduction RHS
            reduction_accesses = self.extract_accesses_from_expr(rhs, loop.ndim)
            all_accesses.extend(reduction_accesses)

        # Remove duplicate accesses
        unique_accesses = []
        seen = set()

        for acc in all_accesses:
            key = (acc.field_name, acc.offsets)
            if key not in seen:
                seen.add(key)
                unique_accesses.append(acc)

        return KernelInfo(
            name=func_node.spelling,
            dim=loop.ndim,
            param_order=param_order,
            read_fields=read_fields,
            write_fields=write_fields,
            write_targets=write_targets,
            accesses=unique_accesses,
            computation_ast=rhs,
            has_idx_param=has_idx_param,
            idx_param_name=idx_param_name,
            reductions=reductions
        )
    
    def find_reductions(self, func_node: Cursor, reduction_params: Dict[str, ops.AccessType]) -> List[ReductionInfo]:
        reductions = []
    
        for node in func_node.walk_preorder():
            if node.kind == CursorKind.COMPOUND_ASSIGNMENT_OPERATOR:
                # Check if it's operating on a reduction parameter
                children = list(node.get_children())
                if len(children) >= 1:
                    lhs = children[0]
                    
                    # Check if LHS is a pointer dereference
                    if lhs.kind == CursorKind.UNARY_OPERATOR:
                        # Get the token to check if '*'
                        tokens = list(lhs.get_tokens())
                        if tokens and tokens[0].spelling == '*':
                            # If a dereference - get the variable name
                            deref_children = list(lhs.get_children())
                            if deref_children:
                                var_name = deref_children[0].spelling
                                
                                if var_name in reduction_params:
                                    # Found a reduction operation
                                    access_type = reduction_params[var_name]
                                    reductions.append(ReductionInfo(
                                        param_name=var_name,
                                        access_type=access_type,
                                        reduction_ast=node
                                    ))

            # Pattern 2: Assignment with reduction function (*error = fmax(*error, ...))
            elif node.kind == CursorKind.BINARY_OPERATOR:
                tokens = list(node.get_tokens())
                # Check if it's assignment
                if any(tok.spelling == '=' for tok in tokens):
                    children = list(node.get_children())
                    if len(children) == 2:
                        lhs = children[0]
                        rhs = children[1]
                        
                        # Check if LHS is *variable
                        if lhs.kind == CursorKind.UNARY_OPERATOR:
                            lhs_tokens = list(lhs.get_tokens())
                            if lhs_tokens and lhs_tokens[0].spelling == '*':
                                lhs_children = list(lhs.get_children())
                                if lhs_children:
                                    var_name = lhs_children[0].spelling
                                    
                                    if var_name in reduction_params:
                                        # Check if RHS references the same variable
                                        # (pattern: *error = fmax(*error, ...))
                                        rhs_refs_var = False
                                        for rhs_node in rhs.walk_preorder():
                                            if rhs_node.kind == CursorKind.UNARY_OPERATOR:
                                                rhs_tokens = list(rhs_node.get_tokens())
                                                if rhs_tokens and rhs_tokens[0].spelling == '*':
                                                    rhs_children = list(rhs_node.get_children())
                                                    if rhs_children and rhs_children[0].spelling == var_name:
                                                        rhs_refs_var = True
                                                        break
                                        
                                        if rhs_refs_var:
                                            access_type = reduction_params[var_name]
                                            reductions.append(ReductionInfo(
                                                param_name=var_name,
                                                access_type=access_type,
                                                reduction_ast=node
                                            ))
        
        return reductions

    def debug_tree(self, node, indent=0):
        print("  " * indent, node.kind, f"'{node.spelling}'")
        for child in node.get_children():
            self.debug_tree(child, indent + 1)

    def find_all_assignments(self, func_node: Cursor) -> List[Cursor]:
        """Find all assignment statement (=) in the function body"""
        assignments = []

        for node in func_node.walk_preorder():
            if node.kind == CursorKind.BINARY_OPERATOR:
                # Check if an assignment
                tokens = list(node.get_tokens())
                for token in tokens:
                    if token.spelling == '=':
                        assignments.append(node)
                        break

        return assignments
    
    def split_assignment(self, assignment_node: Cursor) -> Tuple[Cursor, Cursor]:
        """Split assignment into LHS and RHS"""

        children = list(assignment_node.get_children())
        if len(children) != 2:
            raise ParseError("Expected 2 children in assignment")
        return children[0], children[1]

    def parse_accessor(self, node: Cursor, dim: int) -> StencilAccess:
        """
        Parse A(i, j) or Anew(0, 0) to extract field name and offsets
        """
        
        if node.kind == CursorKind.CALL_EXPR:
            children = list(node.get_children())
            
            if len(children) < 1:
                raise ParseError("Call expression has no children")
            
            # Get field name - try different approaches
            field_node = children[0]
            
            # Try spelling first
            field_name = field_node.spelling
            
            # If empty, try getting from tokens
            if not field_name:
                tokens = list(field_node.get_tokens())
                if tokens:
                    field_name = tokens[0].spelling
            
            # If still empty, walk children to find DECL_REF_EXPR
            if not field_name:
                for child in field_node.walk_preorder():
                    if child.kind == CursorKind.DECL_REF_EXPR:
                        field_name = child.spelling
                        break
            
            if not field_name:
                raise ParseError(f"Could not extract field name from {field_node.kind}")
            
            # Remaining children are the offset arguments
            offsets = []
            for arg in children[1:]:
                offset = self.evaluate_offset(arg)
                offsets.append(offset)
            
            return StencilAccess(field_name, tuple(offsets))

        raise ParseError(f"Expected CALL_EXPR, got {node.kind}.")
    
    def evaluate_offset(self, node: Cursor) -> int:
        """Evaluate an offset expression to an integer (0, 1, -1, etc.)"""
        if node.kind == CursorKind.INTEGER_LITERAL:
            return int(list(node.get_tokens())[0].spelling)
        elif node.kind == CursorKind.UNARY_OPERATOR:
            # Handle negative numbers
            tokens = list(node.get_tokens())
            if tokens[0].spelling == '-':
                return -int(tokens[1].spelling)
        raise ParseError(f"Could not evaluate offset: {node.kind}")
    
    
    def extract_accesses_from_expr(self, expr_node: Cursor, dim: int) -> List[StencilAccess]:
        """Extract all A(i,j) accesses from an expression"""
        accesses = []
        
        for node in expr_node.walk_preorder():
            if node.kind == CursorKind.CALL_EXPR:
                try:
                    access = self.parse_accessor(node, dim)
                    accesses.append(access)
                except:
                    pass  # Not an accessor, skip
        
        return accesses


    def inject_locals_into_function(self, source: str) -> str:
        preamble = "#include <cmath>\n\n"

        # Find the opening brace of the function
        brace_index = source.find('{')
        if brace_index == -1:
            return preamble + source  # fallback

        # Split into:
        # 1. function signature + {
        # 2. rest of body
        before = source[:brace_index + 1]
        after = source[brace_index + 1:]

        # Inject locals right after {
        # TODO: This hardcoding of global consts is due to them being declared
        # using external functions. This is a known limitation of this parsing approach
        # when kernel functions have no defined specification to reduce the allowed operations 
        locals_block = """
        const double pi = 3.14;
        int jmax = 100;
        """

        new_source = preamble + before + locals_block + after
        return new_source

    def parse_kernel_source(self, source: str) -> TranslationUnit:
        """Parse kernel source code (already extracted as string)"""
        
        args = ['-std=c++11', '-fsyntax-only']

        # TODO: Use include directory to stop ACC errors from parser
        
        # Use a dummy filename since parsing from string
        filename = "kernel.cpp"

        modified_source = self.inject_locals_into_function(source)
        print(modified_source)       
        
        translation_unit = Index.create().parse(
            filename,
            unsaved_files=[(filename, modified_source)],
            args=args,
            options=TranslationUnit.PARSE_DETAILED_PROCESSING_RECORD
        )
        
        for diagnostic in translation_unit.diagnostics:
            if diagnostic.severity >= 3:  # Error or Fatal
                print(f"Kernel parse error: {diagnostic.spelling}")
        
        return translation_unit
    
    def kernel_info_to_stencil_ops(
        self,
        kernel_info: KernelInfo,
        temp_args: List[SSAValue],
        global_consts: dict[str, Any]
    ) -> List[IRDLOperation]:
        """Convert KernelInfo to stencil IR operations"""
        
        ops = []
        access_values = {}
        
        # Map field names to their temp arguments
        field_to_temp = {
            field_name: temp_args[i]
            for i, field_name in enumerate(kernel_info.read_fields)
        }
        
        # 1. Create stencil.access ONCE for each unique access (shared by all writes)
        for access in kernel_info.accesses:
            key = (access.field_name, access.offsets)
            if key not in access_values:
                temp_arg = field_to_temp[access.field_name]
                access_op = self.create_stencil_access(access, temp_arg)
                ops.append(access_op)
                access_values[key] = access_op.results[0]
        
        # 2. Build computation for EACH write target
        self._index_values = None
        results = []
        for _, rhs_ast in kernel_info.write_targets:
            result = self.build_computation_ops(
                rhs_ast,
                access_values,
                ops,
                kernel_info,
                global_consts
            )

            result_type = result.type
            if isinstance(result_type, IntegerType) and result_type.width.data == 32:
                cast_op = arith.SIToFPOp(result, f64)
                ops.append(cast_op)
                result = cast_op.results[0]
            results.append(result)
        
        # 3. Generate reduction operations
        for reduction in kernel_info.reductions:
            self.generate_reduction_op(
                reduction,
                access_values,
                ops,
                kernel_info,
                global_consts
            )

        # 4. Return ALL results (one per write field)
        return_op = ReturnOp.create(operands=results)
        ops.append(return_op)
        
        return ops

    def generate_reduction_op(self, reduction: ReductionInfo, access_values: Dict, ops_list: List[IRDLOperation], kernel_info: KernelInfo, global_consts: dict[str, Any]) -> None:
        compound_assign = reduction.reduction_ast
        children = list(compound_assign.get_children())
        rhs = children[1] if len(children) > 1 else children[0]
        
        # For *sum += A(0,0), reduce_value_ast = A(0,0)
        # For *error = fmax(*error, fabs(...)), reduce_value_ast = fabs(...)
        
        if rhs.kind == CursorKind.CALL_EXPR:
            func_name = self.get_func_name(rhs)
            
            if func_name in ['fmax', 'fmin']:
                # Extract second argument: fmax(*error, X) -> X is what we reduce
                rhs_children = list(rhs.get_children())
                if len(rhs_children) >= 3:
                    reduce_value_ast = rhs_children[2]
                else:
                    raise ParseError(f"Invalid {func_name} in reduction")
            else:
                reduce_value_ast = rhs
        else:
            reduce_value_ast = rhs
        
        # Build the value to reduce (without accumulator mapping)
        reduce_value = self.build_computation_ops(
            reduce_value_ast,
            access_values,
            ops_list,
            kernel_info,
            global_consts
        )
        
        # Cast if needed
        if isinstance(reduce_value.type, IntegerType):
            cast_op = arith.SIToFPOp(reduce_value, f64)
            ops_list.append(cast_op)
            reduce_value = cast_op.results[0]
        
        # Create body: combine(accumulator, new_value)
        body_block = Block(arg_types=[f64, f64])
        lhs_arg = body_block.args[0]  # accumulator
        rhs_arg = body_block.args[1]  # new value
        
        compare_op = None
        
        # NOTE: The reduction ops use a compare and select pattern; this is because openMP lowering does not support operations 
        # like arith.maximumf and arith.minimumf, but compare and select is explicitly supported in the MLIR source code

        if reduction.access_type == ops.AccessType.OPS_INC:
            init_value = arith.ConstantOp(FloatAttr(0.0, f64))
            combine_op = arith.AddfOp(lhs_arg, rhs_arg)
        elif reduction.access_type == ops.AccessType.OPS_MAX:
            init_value = arith.ConstantOp(FloatAttr(-1.7976931348623157e+308, f64))
            compare_op = arith.CmpfOp(lhs_arg, rhs_arg, "ogt")
            combine_op = arith.SelectOp(compare_op.results[0], lhs_arg, rhs_arg)
        elif reduction.access_type == ops.AccessType.OPS_MIN:
            init_value = arith.ConstantOp(FloatAttr(1.7976931348623157e+308, f64))
            compare_op = arith.CmpfOp(lhs_arg, rhs_arg, "olt")
            combine_op = arith.SelectOp(compare_op.results[0], lhs_arg, rhs_arg)
        
        if compare_op is not None:
            body_block.add_op(compare_op)

        body_block.add_op(combine_op)
        return_op = YieldOp(combine_op.results[0])
        body_block.add_op(return_op)
        
        body_region = Region([body_block])
        reduce_op = ReduceOp(reduce_value, init_value.results[0], body_region)
        ops_list.append(reduce_op)


    def create_stencil_access(self, access: StencilAccess, temp_ssa_value: SSAValue) -> AccessOp:
        """Create stencil.access operation for A(i, j)"""
        
        access_op = AccessOp.get(
            temp_ssa_value,
            access.offsets
        )
        
        return access_op

    # This is the main function that takes parsed kernel function details and converts them into 
    # equivalent MLIR operations
    def build_computation_ops(
        self,
        expr_node: Cursor,
        access_values: Dict[Tuple[str, Tuple[int, ...]], SSAValue],
        ops_list: List[IRDLOperation],
        kernel_info: KernelInfo,
        global_consts: dict[str, Any]
    ) -> SSAValue:
        """
        Recursively build computation from AST node
        
        Returns the SSA value representing the result
        """

        # Handle array subscript (idx[1])
        if expr_node.kind == CursorKind.ARRAY_SUBSCRIPT_EXPR:
            children = list(expr_node.get_children())

            if len(children) == 2:
                array_name_node = children[0]
                index_node = children[1]

                array_name = array_name_node.spelling
                if array_name == kernel_info.idx_param_name:
                    # Handle expressions like idx[1] or idx[1]+1
                    dim_index = self.evaluate_offset(index_node)

                    if not hasattr(self, '_index_values'):
                        self._index_values = None

                    if self._index_values is None:
                        get_index_op = GetIndexOp.get(kernel_info.dim)
                        ops_list.append(get_index_op)
                        self._index_values = list(get_index_op.results)

                    return self._index_values[dim_index]
        
        # Handle function calls (sin, exp, fmax, fabs)
        elif expr_node.kind == CursorKind.CALL_EXPR:
            children = list(expr_node.get_children())
            
            if not children:
                raise ParseError("Call expression has no children")
            
            func_name_node = children[0]
            func_name = func_name_node.spelling

            # If spelling is empty, try getting from tokens
            if not func_name:
                tokens = list(func_name_node.get_tokens())
                if tokens:
                    func_name = tokens[0].spelling
            
            # Still empty - Try getting from the call expression itself
            if not func_name:
                tokens = list(expr_node.get_tokens())
                if tokens:
                    func_name = tokens[0].spelling
            
            
            # Check if it's a math function
            if func_name in ['sin', 'cos', 'exp', 'fabs', 'sqrt', 'log']:
                # Unary math function
                if len(children) != 2:
                    raise ParseError(f"{func_name} expects 1 argument")
                
                arg = self.build_computation_ops(children[1], access_values, ops_list, kernel_info, global_consts)
                
                if func_name == 'sin':
                    op = math_dialect.SinOp(arg)
                elif func_name == 'cos':
                    op = math_dialect.CosOp(arg)
                elif func_name == 'exp':
                    op = math_dialect.ExpOp(arg)
                elif func_name == 'fabs':
                    op = math_dialect.AbsFOp(arg)
                elif func_name == 'sqrt':
                    op = math_dialect.SqrtOp(arg)
                elif func_name == 'log':
                    op = math_dialect.LogOp(arg)
                
                ops_list.append(op)
                return op.results[0]
            
            elif func_name in ['fmax', 'fmin']:
                # Binary math function
                if len(children) != 3:
                    raise ParseError(f"{func_name} expects 2 arguments")
                
                arg1 = self.build_computation_ops(children[1], access_values, ops_list, kernel_info, global_consts)
                arg2 = self.build_computation_ops(children[2], access_values, ops_list, kernel_info, global_consts)
                
                if func_name == 'fmax':
                    op = arith.MaximumFOp(arg1, arg2)
                elif func_name == 'fmin':
                    op = arith.MinimumFOp(arg1, arg2)
                
                ops_list.append(op)
                return op.results[0]
            
            else:
                # It's a stencil accessor like A(1, 0)

                access = self.parse_accessor(expr_node, dim=2)
                key = (access.field_name, access.offsets)
                return access_values[key]
            
        # Handle unary operators (pointer dereference, negation)
        elif expr_node.kind == CursorKind.UNARY_OPERATOR:
            tokens = list(expr_node.get_tokens())
            
            if tokens and tokens[0].spelling == '*':
                # Pointer dereference - this is reading a reduction accumulator
                children = list(expr_node.get_children())
                if children:
                    var_name = children[0].spelling
                    
                    # Check if this is a reduction parameter

                    reduction_param_names = {red.param_name for red in kernel_info.reductions}
                    if var_name in reduction_param_names:
                        # This references the current accumulator value in the reduction
                        # This is handled specially in generate_reduction_op, error if we got to this point here
                        
                        raise ParseError(f"Reduction accumulator '{var_name}' reference in expression - handle in reduction generation")
                    
                    raise ParseError(f"Pointer dereference of non-reduction variable: {var_name}")
            
            elif tokens and tokens[0].spelling == '-':
                # Unary negation
                children = list(expr_node.get_children())
                if children:
                    arg = self.build_computation_ops(children[0], access_values, ops_list, kernel_info, global_consts)
                    op = arith.NegfOp(arg)
                    ops_list.append(op)
                    return op.results[0]
            
            raise ParseError(f"Unsupported unary operator")

        elif expr_node.kind == CursorKind.DECL_REF_EXPR:
            var_name = expr_node.spelling
            
            # Look up in program's const_values
            if var_name in global_consts:
                value = global_consts[var_name]
                const_op = arith.ConstantOp(FloatAttr(value, f64))
                ops_list.append(const_op)
                return const_op.results[0]
            
            raise ParseError(f"Unknown variable reference: {var_name}")


        # Handle variable references (like 'pi')
        elif expr_node.kind == CursorKind.DECL_REF_EXPR:
            var_name = expr_node.spelling
            
            # Handle known constants
            if var_name == 'pi':
                import math
                const_op = arith.ConstantOp(FloatAttr(math.pi, f64))
                ops_list.append(const_op)
                return const_op.results[0]
            
            # Handle other global constants if needed
            raise ParseError(f"Unknown variable reference: {var_name}")
        
        # Constant (like 0.25f)
        elif expr_node.kind == CursorKind.FLOATING_LITERAL:
            token_str = list(expr_node.get_tokens())[0].spelling
            token_str = token_str.rstrip('fF')
            value = float(token_str)
            const_op = arith.ConstantOp(FloatAttr(value, f64))
            ops_list.append(const_op)
            return const_op.results[0]
        
        elif expr_node.kind == CursorKind.INTEGER_LITERAL:
            value = int(list(expr_node.get_tokens())[0].spelling)
            const_op = arith.ConstantOp(FloatAttr(float(value), f64))
            ops_list.append(const_op)
            return const_op.results[0]
        
        # Binary operation (+ - * /)
        elif expr_node.kind == CursorKind.BINARY_OPERATOR:
            children = list(expr_node.get_children())
            if len(children) != 2:
                raise ParseError(f"Binary operator has {len(children)} children")
            
            left = self.build_computation_ops(children[0], access_values, ops_list, kernel_info, global_consts)
            right = self.build_computation_ops(children[1], access_values, ops_list, kernel_info, global_consts)
            
            # Type casting
            left_type = left.type
            right_type = right.type

            if isinstance(left_type, IntegerType) and left_type.width.data == 32:
                if isinstance(right_type, Float64Type):
                    cast_op = arith.SIToFPOp(left, f64)
                    ops_list.append(cast_op)
                    left = cast_op.results[0]
        
            if isinstance(right_type, IntegerType) and right_type.width.data == 32:
                if isinstance(left_type, Float64Type):
                    cast_op = arith.SIToFPOp(right, f64)
                    ops_list.append(cast_op)
                    right = cast_op.results[0]

            # Determine operator
            tokens = list(expr_node.get_tokens())
            left_tokens = list(children[0].get_tokens())
            op_idx = len(left_tokens)
            operator = tokens[op_idx].spelling

            left_is_int = isinstance(left_type, IntegerType)
            right_is_int = isinstance(right_type, IntegerType)

            if left_is_int and right_is_int:
                if operator == '+':
                    op = arith.AddiOp(left, right)
                elif operator == '-':
                    op = arith.SubiOp(left, right)
                elif operator == '*':
                    op = arith.MuliOp(left, right)
                elif operator == '/':
                    op = arith.DivSIOp(left, right)
                else:
                    raise ParseError(f"Unsupported operator: {operator}")
            else:
                if operator == '+':
                    op = arith.AddfOp(left, right)
                elif operator == '-':
                    op = arith.SubfOp(left, right)
                elif operator == '*':
                    op = arith.MulfOp(left, right)
                elif operator == '/':
                    op = arith.DivfOp(left, right)
                else:
                    raise ParseError(f"Unsupported operator: {operator}")
            
            ops_list.append(op)
            return op.results[0]
        
        # Parentheses - unwrap
        elif expr_node.kind == CursorKind.PAREN_EXPR:
            children = list(expr_node.get_children())
            return self.build_computation_ops(children[0], access_values, ops_list, kernel_info, global_consts)
        
        # UNEXPOSED_EXPR - unwrap
        elif expr_node.kind == CursorKind.UNEXPOSED_EXPR:
            children = list(expr_node.get_children())
            if children:
                return self.build_computation_ops(children[0], access_values, ops_list, kernel_info, global_consts)
        
        elif expr_node.kind == CursorKind.UNARY_OPERATOR:
            children = list(expr_node.get_children())
            
            if len(children) != 1:
                raise ParseError(f"Unary operator has {len(children)} children")
            
            operand = self.build_computation_ops(
                children[0], access_values, ops_list, kernel_info, global_consts
            )
            
            # Get operator symbol
            tokens = list(expr_node.get_tokens())
            
            # Usually first token is the operator
            operator = tokens[0].spelling if tokens else None

            if operator == '-':
                # Negation: 0 - operand
                zero = arith.ConstantOp(FloatAttr(0.0, f64))
                ops_list.append(zero)
                op = arith.SubfOp(zero.result, operand)
                ops_list.append(op)
                return op.results[0]
            
            elif operator == '+':
                # Unary plus -> no-op
                return operand
            
            else:
                raise ParseError(f"Unsupported unary operator: {operator}")

        raise ParseError(f"Unsupported expression kind: {expr_node.kind}")


    def get_func_name(self, call_expr: Cursor) -> str:
        """Helper to extract function name from CALL_EXPR"""
        children = list(call_expr.get_children())
        if children:
            name = children[0].spelling
            if not name:
                tokens = list(children[0].get_tokens())
                if tokens:
                    name = tokens[0].spelling
            return name
        return ""

    # TODO: work on Fortran parser
    
    def parseFortran(self,
        loop: ops.Loop,
        program: Program,
        app: Application
    ):
        kernel_entities = app.findEntities(loop.kernel, program)

        if len(kernel_entities) == 0:
            raise ParseError(f"Unable to find kernel: {loop.kernel}")

        extracted_entities = ctk.extractDependancies(kernel_entities, app)


        source = ctk.writeSource(extracted_entities)

        print(source)
        return source
