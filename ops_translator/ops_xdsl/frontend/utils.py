from clang.cindex import Cursor, Type, TypeKind

from xdsl.dialects.builtin import i32, i64, f32, f64, IntegerAttr, FloatAttr, StringAttr
from xdsl.ir import SSAValue, Attribute

from xdsl.dialects.builtin import VectorType

"""
Contains utility functions for the frontend.
"""

# TODO: Add other types as needed, such as user defined type, struct, etc.
def get_type(typ: Type):
    type_kind = typ.kind
    if type_kind == TypeKind.INT:
        return i32
    elif type_kind == TypeKind.FLOAT:
        return f32
    elif type_kind == TypeKind.DOUBLE:
        return f64
    elif type_kind == TypeKind.CONSTANTARRAY:
        return VectorType(shape=[typ.element_count], element_type=get_type(typ.element_type))
    else:
        raise ValueError(f"Unknown type: {typ}")

def get_literal_value(cursor):
    for token in cursor.get_tokens():
        if token.kind.name == "LITERAL":
            value = token.spelling
            if value[-1] == "f":
                return value[:-1]
            return token.spelling
    return None

def get_binary_operator(cursor):
    tokens = list(cursor.get_tokens())
    for i, token in enumerate(tokens):
        if token.kind.name == "PUNCTUATION" and token.spelling in ["+", "-", "*", "/"]:
            return token.spelling
    return None

def get_decl_ref_name(cursor):
    for token in cursor.get_tokens():
        if token.kind.name == "IDENTIFIER":
            return token.spelling
    return None

def is_contain_overload_func(cursor):
    for child in cursor.get_children():
        if isinstance(child, Cursor) and child.type.spelling == "<overloaded function type>":
            return True
    return False


