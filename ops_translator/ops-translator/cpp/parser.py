import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Union, Any

from clang.cindex import Cursor, CursorKind, TranslationUnit, TypeKind, conf

import ops
from store import Function, Location, ParseError, Program, Type
from util import safeFind #TODO: implement safe find
from dataclasses import dataclass

# New constant evaluator mechanism
class ConstantEvaluator:
    def __init__(self):
        self.constants = {}  # var_name -> value
    
    def register_constant(self, name: str, node: Cursor):
        """Store both name and AST node for lazy evaluation"""
        self.constants[name] = node
    
    def evaluate(self, node: Cursor, depth: int = 0) -> Optional[int]:
        """Recursively evaluate with cycle detection"""
        
        # Prevent infinite recursion
        if depth > 10:
            return None

        # Handle UNEXPOSED_EXPR by unwrapping to first child
        if node.kind == CursorKind.UNEXPOSED_EXPR:
            children = list(node.get_children())
            if children:
                return self.evaluate(children[0], depth)
            return None
        
        if node.kind == CursorKind.INTEGER_LITERAL:
            tokens = list(node.get_tokens())
            return int(tokens[0].spelling)
        
        elif node.kind == CursorKind.UNARY_OPERATOR:
            children = list(node.get_children())
            if not children:
                return None
            
            val = self.evaluate(children[0], depth + 1)
            if val is None:
                return None
            
            # Determine operator
            tokens = list(node.get_tokens())
            op = tokens[0].spelling
            
            if op == '-':
                return -val
            elif op == '+':
                return val
            return None
        
        elif node.kind == CursorKind.BINARY_OPERATOR:
            children = list(node.get_children())
            
            if len(children) != 2:
                return None
            
            left = self.evaluate(children[0], depth + 1)
            right = self.evaluate(children[1], depth + 1)

            if left is None or right is None:
                return None
                
            
            # Find operator token
            tokens = list(node.get_tokens())
            left_tokens = list(children[0].get_tokens())
            
            op_idx = len(left_tokens)
            if op_idx < len(tokens):
                op = tokens[op_idx].spelling
                
                if op == '+': return left + right
                elif op == '-': return left - right
                elif op == '*': return left * right
                elif op == '/': return left // right if right != 0 else None
            
            return None
        
        elif node.kind == CursorKind.DECL_REF_EXPR:
            # Variable reference - RECURSIVELY evaluate its definition
            var_name = node.spelling
            
            if var_name not in self.constants:
                return None
            
            # Get the definition node and evaluate it
            definition = self.constants[var_name]
            return self.evaluate(definition, depth + 1)
        
        elif node.kind == CursorKind.PAREN_EXPR:
            # Just unwrap parentheses
            children = list(node.get_children())
            if children:
                return self.evaluate(children[0], depth + 1)
            return None
        
        return None


def parseMeta(node: Cursor, program: Program) -> None:
    if node.kind == CursorKind.TYPE_REF:
        parseTypeRef(node, program)

    if node.kind == CursorKind.FUNCTION_DECL:
        parseFunction(node, program) #TODO

    for child in node.get_children():
        parseMeta(child, program) 


def parseTypeRef(node: Cursor, program: Program) -> None:
    node = node.get_definition()

    if node is None or Path(str(node.location.file)) != program.path:
        return

    matching_entities = program.findEntities(node.spelling)

    for entity in matching_entities: 
        if entity.ast == node: #The entitiy is already exist
            return

    typ = Type(node.spelling, node, program) 

    for n in node.walk_preorder():
        if n.kind != CursorKind.CALL_EXPR and n.kind != CursorKind.TYPE_REF:
            continue

        n = n.get_definition()

        if n is None or Path(str(n.location.file)) != program.path:
            continue

        typ.depends.add(n.spelling)

    program.entities.append(typ)


def parseFunction(node: Cursor, program: Program) -> None:
    node = node.get_definition()

    if node is None or Path(str(node.location.file)) != program.path: 
        return

    matching_entities = program.findEntities(node.spelling)

    for entity in matching_entities:
        if entity.ast == node: #The entitiy is already exist
            return

    function = Function(node.spelling, node, program)

    for n in node.get_children():
        if n.kind != CursorKind.PARM_DECL:
            continue

        function.parameters.append(n.spelling)

    for n in node.walk_preorder():
        if n.kind != CursorKind.CALL_EXPR and n.kind != CursorKind.TYPE_REF:
            continue

        n = n.get_definition()

        if n is None or Path(str(n.location.file)) != program.path:
            continue

        function.depends.add(n.spelling) 

    program.entities.append(function)


def parseLocation(node: Cursor) -> Location:
    return Location(node.location.file.name, node.location.line, node.location.column)


def parseLoops(translation_unit: TranslationUnit, program: Program) -> None:
    macros: Dict[Location, str] = {}
    nodes: List[Cursor] = []

    evaluator = ConstantEvaluator()
    extract_constants_from_file(translation_unit.cursor, evaluator)

    dat_registry = find_and_parse_dat_decls(translation_unit.cursor, evaluator)

    for node in translation_unit.cursor.get_children():

        if node.kind == CursorKind.MACRO_DEFINITION:
            continue

        if node.location.file.name != translation_unit.spelling:
            continue

        if node.kind == CursorKind.MACRO_INSTANTIATION:
            macros[parseLocation(node)] = node.spelling
            continue

        nodes.append(node)

    for node in nodes:
        for child in node.walk_preorder():
            if child.kind.is_unexposed():
                parseCall(translation_unit, child, macros, program, evaluator, dat_registry)

    return program


def parseUnexposedFunction(node: Cursor) -> Union[Tuple[str, List[Cursor]], None]:
    args = []
    # child_string=""
    for child in node.get_children():
        args.append(child)

    if len(args) == 0:
        return None

    first_child = args.pop(0)

    if (
        first_child.kind == CursorKind.MEMBER_REF_EXPR
        and len(list(first_child.get_children())) >= 2
    ):
        name_token = list(first_child.get_children())[1]
        name = name_token.spelling
    elif first_child.kind == CursorKind.DECL_REF_EXPR:
        name = list(first_child.get_tokens())[0].spelling
    else:
        return None

    return (name, args)


def parseCall(translation_unit: TranslationUnit, node: Cursor, macros: Dict[Location, str], program: Program, evaluator: ConstantEvaluator, dat_registry: Dict[str, Tuple]) -> None:

    if parseUnexposedFunction(node) == None:
        return
    else:
        (name, args) = parseUnexposedFunction(node)

    loc = parseLocation(node)

    if name == "ops_decl_const" or name == "decl_const":
        program.consts.append(parseConst(args, loc, macros))

    elif name == "ops_par_loop":
        loop = parseLoop(translation_unit, args, loc, macros, evaluator, dat_registry)
        program.loops.append(loop)

        if program.ndim == None:
            program.ndim = loop.ndim
        elif program.ndim < loop.ndim:
            program.ndim = loop.ndim


def decend(node: Cursor) -> Optional[Cursor]:
    return next(node.get_children(), None)


def parseStringLit(node: Cursor) -> str:
    if node.kind == CursorKind.UNEXPOSED_EXPR:
        node = decend(node)
        if node.kind != CursorKind.STRING_LITERAL:
            raise ParseError("Expected string literal")

    elif node.kind != CursorKind.STRING_LITERAL:
        raise ParseError("Expected string literal")

    return node.spelling[1:-1]


def parseIntExpression(node: Cursor) -> int:
    if node.type.kind != TypeKind.INT:
        raise ParseError("Expected int expression", parseLocation(node))

    eval_result = conf.lib.clang_Cursor_Evaluate(node)
    val = conf.lib.clang_EvalResult_getAsInt(eval_result)
    conf.lib.clang_EvalResult_dispose(eval_result)

    return val


def parseIntLiteral(node: Cursor) -> Optional[int]:
    if node.kind == CursorKind.INTEGER_LITERAL:
        tokens = list(node.get_tokens())
        if len(tokens) == 1:
            value_str = tokens[0].spelling
            return int(value_str)
    elif node.kind == CursorKind.UNARY_OPERATOR:
        operator = None
        value = None
        for token in node.get_tokens():
            if operator is None:
                operator = token.spelling
            else:
                value = int(token.spelling)
        if operator == '-' and value is not None:
            return -value
        elif operator == '+' and value is not None:
            return value
    else:
        raise ParseError("Expected int expression", parseLocation(node))

    raise ParseError("Invalid node type " + str(node.kind), parseLocation(node))


def parseIntLiteral_old(node: Cursor) -> Optional[int]:
    if node.type.kind != TypeKind.INT:
        raise ParseError("Expected int expression", parseLocation(node))

    if node.kind == CursorKind.INTEGER_LITERAL:
        eval_result = conf.lib.clang_Cursor_Evaluate(node)
        val = conf.lib.clang_EvalResult_getAsInt(eval_result)
        conf.lib.clang_EvalResult_dispose(eval_result)
        return val
    else:
        raise ParseError("Invalid node type " + str(node.kind), parseLocation(node))


def parseType(typ: str, loc: Location, include_custom=False) -> Tuple[ops.Type, bool]:
    typ_clean = typ.strip()
    typ_clean = re.sub(r"\s*const\s*", "", typ_clean) # Why removing const?

    soa = False
    if re.search(r":soa", typ_clean):
        soa = True

    typ_clean = re.sub(r"\s*:soa\s*", "", typ_clean)

    typ_map = {
        "short": ops.Int(True, 16),
        "unsigned short": ops.Int(False, 16),
        "ushort": ops.Int(False, 16),
        "int": ops.Int(True, 32),
        "long": ops.Int(True, 32),
        "long int": ops.Int(True, 32),
        "uint": ops.Int(False, 32),
        "unsigned int": ops.Int(False, 32),
        "ll": ops.Int(True, 64),
        "long long": ops.Int(True, 64),
        "ull": ops.Int(False, 64),
        "unsigned long long": ops.Int(False, 64),
        "half": ops.Float(16),
        "float": ops.Float(32),
        "double": ops.Float(64),
        "bool": ops.Bool(),
        "char": ops.Char(),
        "complexd": ops.ComplexD(),
        "complexf": ops.ComplexF()
    }

    if typ_clean in typ_map:
        return typ_map[typ_clean], soa

    if include_custom:
        return ops.Custom(typ_clean), soa

    raise ParseError(f"Unable to parse type: '{typ}'", loc)


def parseIdentifier(node: Cursor, raw: bool = True) -> str:
    if raw:
        return "".join([t.spelling for t in node.get_tokens()])

    while node.kind == CursorKind.CSTYLE_CAST_EXPR:
        node = list(node.get_children())[1]

    if node.kind == CursorKind.UNEXPOSED_EXPR:
        node = decend(node)

    if node.kind == CursorKind.UNARY_OPERATOR and next(node.get_tokens()).spelling in ("&", "*"):
        node = decend(node)

    if node.kind == CursorKind.GNU_NULL_EXPR:
        raise ParseError("Expected identifier, found NULL", parseLocation(node))

    if node.kind != CursorKind.DECL_REF_EXPR:
        raise ParseError("Expected identifier", parseLocation(node))

    return node.spelling


def parseConst(args: List[Cursor], loc: Location, macros: Dict[Location, str]) -> ops.Const:
    if(len(args) != 4):
        raise ParseError(f"Incorrect number({len(args)}) of args passed to ops_decl_const", loc)

    name = parseStringLit(args[0])
    if parseLocation(args[1]) in macros.keys():
        dim = macros[parseLocation(args[1])]
    else:
        dim = parseIdentifier(args[1])
    typ, _ = parseType(parseStringLit(args[2]), loc, True)
    ptr = parseIdentifier(args[3], raw=False)

    return ops.Const(loc, ptr, dim, typ, name)


def parseAccessType(node: Cursor, loc: Location, macros: Dict[Location, str]) -> ops.AccessType:

    if parseLocation(node) in macros.keys():
        access_type_str = macros[parseLocation(node)]

        access_type_map = {"OPS_READ": 0, "OPS_WRITE": 1, "OPS_RW": 2, "OPS_INC": 3, "OPS_MIN": 4, "OPS_MAX": 5}

        if access_type_str not in access_type_map:
            raise ParseError(
                f"invalid access type {access_type_str}, expected one of {', '.join(access_type_map.keys())}", loc
            )

        access_type_raw = access_type_map[access_type_str]
        return ops.AccessType(access_type_raw)


def parseArgDat(loop: ops.Loop, args: List[Cursor], loc: Location, macros: Dict[Location, str], evaluator: ConstantEvaluator, dat_registry: Dict[str, Tuple]) -> None:
    if len(args) != 5:
        raise ParseError(f"Incorrect number({len(args)}) of args passed to ops_arg_dat", loc)

    dat_ptr = parseIdentifier(args[0])
    dim = parseIntLiteral(args[1])
    stencil_ptr = parseIdentifier(args[2])
    dat_typ, dat_soa = parseType(parseStringLit(args[3]), loc)
    access_type = parseAccessType(args[4], loc, macros)

    # Look up the dat info from registry
    if dat_ptr in dat_registry:
        dat_info = dat_registry[dat_ptr]
        print(f"Found dat {dat_ptr}: size={dat_info[0]}, base={dat_info[1]}, d_m={dat_info[2]}, d_p={dat_info[3]}")
    else:
        print(f"Warning: Could not find declaration for dat {dat_ptr}")
        dat_info = None

    loop.addArgDat(loc, dat_ptr, dim, dat_typ, dat_soa, stencil_ptr, access_type, True, dat_info)


def parseArgDatOpt(loop: ops.Loop, args: List[Cursor], loc: Location, macros: Dict[Location, str]) -> None:
    if len(args) != 6:
        raise ParseError(f"Incorrect number({len(args)}) of args passed to ops_arg_dat_opt", loc)

    dat_ptr = parseIdentifier(args[0])
    dim = parseIntLiteral(args[1])
    stencil_ptr = parseIdentifier(args[2])
    dat_typ, dat_soa = parseType(parseStringLit(args[3]), loc)
    access_type = parseAccessType(args[4], loc, macros)
    opt = parseIntExpression(args[5])

    loop.addArgDat(loc, dat_ptr, dim, dat_typ, dat_soa, stencil_ptr, access_type, bool(opt))


def parseArgReduce(loop: ops.Loop, args: List[Cursor], loc: Location, macros: Dict[Location, str]) -> None:
    if len(args) != 4:
        raise ParseError(f"Incorrect number of args passed to ops_arg_reduce: {len(args)}", loc)

    reduct_handle_ptr = parseIdentifier(args[0])
    dim = parseIntLiteral(args[1])
    typ, soa = parseType(parseStringLit(args[2]), loc)
    access_type = parseAccessType(args[3], loc, macros)

    loop.addArgReduce(loc, reduct_handle_ptr, dim, typ, access_type)


def parseBlock(node: Cursor, dim: int) -> ops.Block:
    ptr = parseIdentifier(node)
    loc = parseLocation(node)
    return ops.Block(loc, ptr, dim)

# NEW - Parse the loop iteration range
def parseRange(node: Cursor, dim: int, evaluator: ConstantEvaluator) -> ops.Range:
    ptr = parseIdentifier(node)
    loc = parseLocation(node)

    # Find the variable declaration for this range
    var_decl = find_variable_declaration(node)
    
    if var_decl is None:
        raise ValueError(f"Could not find declaration for range variable '{ptr}' at {loc}")

    # Get the array initializer
    initializer = None
    for child in var_decl.get_children():
        if child.kind == CursorKind.INIT_LIST_EXPR:
            initializer = child
            break
    
    if initializer is None:
        raise ValueError(f"Range variable '{ptr}' has no initializer at {loc}")

    # Evaluate each element in the initializer
    bounds = []

    for i, element in enumerate(initializer.get_children()):
        value = evaluator.evaluate(element)
        if value is None:
            raise ValueError(
                f"Could not evaluate element in range '{ptr}' to constant at {loc}. "
                f"Ranges must use compile-time constant expressions."
            )
        bounds.append(value)
    
    # Validate bounds count
    expected_count = 2 * dim
    if len(bounds) != expected_count:
        raise ValueError(
            f"Range '{ptr}' has {len(bounds)} values, expected {expected_count} for {dim}D"
        )
    
    return ops.Range(loc, ptr, dim, bounds)

def find_variable_declaration(node: Cursor) -> Optional[Cursor]:
    """Find the declaration of the variable referenced by this node"""
    
    # If node is a DECL_REF_EXPR, get its definition
    if node.kind == CursorKind.DECL_REF_EXPR:
        return node.get_definition()
    
    # Otherwise search for it by name
    var_name = parseIdentifier(node)
    
    # Walk up to find the function or file scope
    current = node.semantic_parent
    while current:
        for child in current.get_children():
            if child.kind == CursorKind.VAR_DECL and child.spelling == var_name:
                return child
        current = current.semantic_parent
    
    return None


def parseArgGbl(loop: ops.Loop, args: List[Cursor], loc: Location, macros: Dict[Location, str]) -> None:
    if len(args) !=4:
        raise ParseError("Incorrect number of args passed to ops_arg_gbl", loc)

    ptr = parseIdentifier(args[0])
    if parseLocation(args[1]) in macros.keys():
        dim = macros[parseLocation(args[1])]
    else:
        dim = parseIdentifier(args[1])
    typ, _ = parseType(parseStringLit(args[2]), loc)
    access_type = parseAccessType(args[3], loc, macros)

    loop.addArgGbl(loc, ptr, dim, typ, access_type)


def parseArgIdx(loop: ops.Loop, args: List[Cursor], loc: Location, macros: Dict[Location, str]) -> None:
    if len(args) !=0:
        raise ParseError("Incorrect number of args passed to ops_arg_idx", loc)

    loop.addArgIdx(loc)


def parseLoop(translation_unit: TranslationUnit, args: List[Cursor], loc: Location, macros: Dict[Location, str], evaluator: ConstantEvaluator, dat_registry: Dict[str, Tuple]) -> ops.Loop:
    if len(args) < 6:
        raise ParseError("Incorrect number of args passed to ops_par_loop")
    
    evaluator = ConstantEvaluator()
    extract_constants_from_file(translation_unit.cursor, evaluator)


    kernel = parseIdentifier(args[0])
    dim    = parseIntLiteral(args[3])
    block  = parseBlock(args[2], dim)
    range = parseRange(args[4], dim, evaluator)

    loop = ops.Loop(loc, kernel, block, range, dim)

    for node in args[5:]:
        node_name = node.spelling

        arg_loc = parseLocation(node)
        arg_args = list(node.get_arguments())

        if node_name == "ops_arg_dat":
            parseArgDat(loop, arg_args, arg_loc, macros, evaluator, dat_registry)

        elif node_name == "ops_arg_dat_opt":
            parseArgDatOpt(loop, arg_args, arg_loc, macros)

        elif node_name == "ops_arg_idx":
            parseArgIdx(loop, arg_args, arg_loc, macros)

        elif node_name == "ops_arg_reduce":
            parseArgReduce(loop, arg_args, arg_loc, macros)

        elif node.kind.is_unexposed() and parseUnexposedFunction(node) != None:
            (_, arg_args) = parseUnexposedFunction(node)
            parseArgGbl(loop, arg_args, arg_loc, macros)

        else:
            raise ParseError(f"Invalid loop argument {node_name}", parseLocation(node))

    return loop


def extract_constants_from_file(cursor: Cursor, evaluator: ConstantEvaluator):
    """First pass: find all const int declarations"""
    
    for node in cursor.walk_preorder():
        if node.kind == CursorKind.VAR_DECL:
            found = False
            if "imax" in node.spelling or "imax" in node.type.spelling:
                found = True
            
            # Check if const
            if 'const' in node.type.spelling:
                var_name = node.spelling
                
                # Get the initializer expression
                children = list(node.get_children())

                for child in children:
                    if child.kind != CursorKind.TYPE_REF:
                        evaluator.register_constant(var_name, child)
                        break


def find_and_parse_dat_decls(translation_unit: Cursor, evaluator: ConstantEvaluator) -> Dict[str, Tuple]:
    """Find all ops_decl_dat calls and extract their parameters"""
    dat_registry = {}
    
    for node in translation_unit.walk_preorder():
        if node.kind == CursorKind.VAR_DECL:
            for child in node.get_children():
                if child.kind == CursorKind.UNEXPOSED_EXPR:
                    # Check if this is an ops_decl_dat call
                    children = list(child.get_children())
                    if len(children) >= 10:  # ops_decl_dat has many args
                        parsed = parseUnexposedFunction(child)
                        if parsed:
                            func_name, args = parsed
                            if func_name == "ops_decl_dat":
                                dat_name = node.spelling
                                size, base, d_m, d_p = parse_decl_dat_call_from_args(args, evaluator)
                                if size or base or d_m or d_p:
                                    dat_registry[dat_name] = (size, base, d_m, d_p)
                                    print(f"Registered dat: {dat_name} with size={size}")
                                break
    
    return dat_registry


def parse_decl_dat_call_from_args(args: List[Cursor], evaluator: ConstantEvaluator) -> Optional[Tuple]:
    """
    Parse ops_decl_dat arguments: (block, dim, size, base, d_m, d_p, data, type, name)
    Note: args comes from parseUnexposedFunction, which already removed the function name
    """
    if len(args) < 7:
        return None
    
    # Get size and halo details
    size = evaluate_array_argument(args[2], evaluator)
    base = evaluate_array_argument(args[3], evaluator)
    d_m = evaluate_array_argument(args[4], evaluator)
    d_p = evaluate_array_argument(args[5], evaluator)
    
    if size is None or base is None or d_m is None or d_p is None:
        print(f"Warning: Could not evaluate arrays: size={size}, base={base}, d_m={d_m}, d_p={d_p}")
        return None
    
    return size, base, d_m, d_p


def evaluate_array_argument(node: Cursor, evaluator: ConstantEvaluator) -> Optional[List[int]]:
    """
    Evaluate an array argument (either literal {6, 6} or variable reference 'size')
    """
    # Check if a variable reference
    if node.kind == CursorKind.DECL_REF_EXPR or node.kind == CursorKind.UNEXPOSED_EXPR:
        # Find the variable declaration
        var_decl = find_variable_declaration(node)
        if var_decl:
            # Get its initializer
            for child in var_decl.get_children():
                if child.kind == CursorKind.INIT_LIST_EXPR:
                    return evaluate_array_initializer(child, evaluator)
    
    # Or it might be a direct array literal
    elif node.kind == CursorKind.INIT_LIST_EXPR:
        return evaluate_array_initializer(node, evaluator)
    
    return None


def evaluate_array_initializer(init_list: Cursor, evaluator: ConstantEvaluator) -> Optional[List[int]]:
    """Evaluate {imax, jmax} or {6, 6} to [6, 6]"""
    values = []
    for element in init_list.get_children():
        val = evaluator.evaluate(element)
        if val is None:
            return None
        values.append(val)
    return values


def parseConstantDeclarations(cursor: Cursor, program: Program) -> Dict[str, Any]:
    """
    Parse global constant declarations and extract their values.
    Returns a dict mapping variable names to their compile-time values.
    """
    const_values = {}
    
    for node in cursor.walk_preorder():
        # Look for variable declarations
        if node.kind == CursorKind.VAR_DECL:
            var_name = node.spelling
            
            # Check if it has a constant initializer
            children = list(node.get_children())
            if children:
                init_expr = children[0]
                
                # Try to evaluate the initializer
                try:
                    if init_expr.kind == CursorKind.FLOATING_LITERAL:
                        tokens = list(init_expr.get_tokens())
                        if tokens:
                            value_str = tokens[0].spelling.rstrip('fF')
                            const_values[var_name] = float(value_str)
                    
                    elif init_expr.kind == CursorKind.INTEGER_LITERAL:
                        tokens = list(init_expr.get_tokens())
                        if tokens:
                            const_values[var_name] = int(tokens[0].spelling)
                except:
                    pass  # Skip if can't evaluate
    
    return const_values
