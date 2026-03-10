import ops
from store import Application, ParseError, Program
import cpp.translator.kernels as ctk
from dataclasses import dataclass
from typing import List, Tuple, Optional, Dict
import re
from clang.cindex import CursorKind, Cursor, TranslationUnit, Index
from xdsl.dialects.stencil import IndexAttr
from xdsl.dialects.builtin import FloatAttr, f64
from xdsl.irdl import IRDLOperation, SSAValue
from ops_dialect.ops_dialect import YieldOp
from xdsl.dialects.stencil import AccessOp
from xdsl.dialects import arith

@dataclass
class StencilAccess:
    field_name: str
    offsets: Tuple[int, ...]  # Variable length for up to 5D (OPS)MAX_DIM

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

        params = list(func_node.get_arguments())
        param_order = [param.spelling for param in params]
    
        # Match parameters to dats by position
        for i, param in enumerate(params):
            param_name = param.spelling
            
            if i >= len(loop.args):
                raise ParseError(f"Parameter {param_name} has no corresponding ops_dat")

            arg = loop.args[i]

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
        assignment_nodes = self.find_all_assignments(func_node)
        
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
            accesses=accesses,
            computation_ast=rhs
        )
    

    def find_all_assignments(self, func_node: Cursor) -> List[Cursor]:
        """Find all assignment statement (=) in the function body"""
        assignments = []

        for node in func_node.walk_preorder():
            if node.kind == CursorKind.BINARY_OPERATOR:
                # Check if it's an assignment
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
        
        raise ParseError(f"Expected CALL_EXPR, got {node.kind}")
    
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


    def parse_kernel_source(self, source: str) -> TranslationUnit:
        """Parse kernel source code (already extracted as string)"""
        
        args = ['-std=c++11']
        # TODO: Use include directory to stop ACC errors from parser
        
        # Use a dummy filename since we're parsing from string
        filename = "kernel.cpp"
        
        translation_unit = Index.create().parse(
            filename,
            unsaved_files=[(filename, source)],
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
        temp_args: List[SSAValue]
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
        results = []
        for write_target, rhs_ast in kernel_info.write_targets:
            result = self.build_computation_ops(
                rhs_ast,
                access_values,
                ops
            )
            results.append(result)
        
        # 3. Return ALL results (one per write field)
        return_op = YieldOp.create(operands=results)  # Multiple operands!
        ops.append(return_op)
        
        return ops

    def create_stencil_access(self, access: StencilAccess, temp_ssa_value: SSAValue) -> AccessOp:
        """Create stencil.access operation for A(i, j)"""
        
        print(access.offsets)
        access_op = AccessOp.get(
            temp_ssa_value,
            access.offsets
        )
        
        return access_op


    def build_computation_ops(
        self,
        expr_node: Cursor,
        access_values: Dict[Tuple[str, Tuple[int, ...]], SSAValue],
        ops_list: List[IRDLOperation]
    ) -> SSAValue:
        """
        Recursively build computation from AST node
        
        Returns the SSA value representing the result
        """

        
        # Base case: it's an accessor like A(1, 0)
        if expr_node.kind == CursorKind.CALL_EXPR:
            access = self.parse_accessor(expr_node, dim=2)  # TODO: get dim properly
            key = (access.field_name, access.offsets)
            return access_values[key]
        
        # Constant (like 0.25f)
        elif expr_node.kind == CursorKind.FLOATING_LITERAL:
            token_str = list(expr_node.get_tokens())[0].spelling
            # Remove f/F suffix if present
            token_str = token_str.rstrip('fF')
            value = float(token_str)
            const_op = arith.ConstantOp(FloatAttr(value, f64))
            ops_list.append(const_op)
            return const_op.results[0]
        
        elif expr_node.kind == CursorKind.INTEGER_LITERAL:
            value = int(list(expr_node.get_tokens())[0].spelling)
            # TODO: Add support for integer opeartions

            # Convert int to float for consistency
            const_op = arith.ConstantOp(FloatAttr(float(value), f64))
            ops_list.append(const_op)
            return const_op.results[0]
        
        # Binary operation (+ - * /)
        elif expr_node.kind == CursorKind.BINARY_OPERATOR:
            children = list(expr_node.get_children())
            if len(children) != 2:
                raise ParseError(f"Binary operator has {len(children)} children")
            
            # Recursively build left and right
            left = self.build_computation_ops(children[0], access_values, ops_list)
            right = self.build_computation_ops(children[1], access_values, ops_list)
            
            # Determine operator
            tokens = list(expr_node.get_tokens())
            # Find the operator token (between left and right operands)
            left_tokens = list(children[0].get_tokens())
            op_idx = len(left_tokens)
            operator = tokens[op_idx].spelling
            
            # Create appropriate arith operation
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
            return self.build_computation_ops(children[0], access_values, ops_list)
        
        # UNEXPOSED_EXPR - unwrap
        elif expr_node.kind == CursorKind.UNEXPOSED_EXPR:
            children = list(expr_node.get_children())
            if children:
                return self.build_computation_ops(children[0], access_values, ops_list)
        
        raise ParseError(f"Unsupported expression kind: {expr_node.kind}")




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