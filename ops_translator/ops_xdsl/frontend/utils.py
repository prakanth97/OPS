from clang.cindex import Cursor

from xdsl.dialects.builtin import i32, i64, f32, f64, IntegerAttr, FloatAttr, StringAttr
from xdsl.ir import SSAValue, Attribute

"""
Contains utility functions for the frontend.
"""

# TODO: Add other types as needed, such as user defined type, struct, etc.
def get_type(typ: str):
    if typ == "int":
        return i32
    elif typ == "float":
        return f32
    elif typ == "double":
        return f64
    else:
        raise ValueError(f"Unknown type: {typ}")

def get_literal_value(cursor):
    for token in cursor.get_tokens():
        if token.kind.name == "LITERAL":
            return token.spelling
    return None

def get_binary_operator(cursor):
    for token in cursor.get_tokens():
        if token.kind.name == "PUNCTUATION":
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
