from clang.cindex import Cursor, CursorKind, TranslationUnit, TypeKind, conf
from xdsl.ir import SSAValue

import utils

class ASTVisitor:

    def visit(self, cursor:Cursor, level=0):
        method = 'visit_' + cursor.kind.name.lower()
        visitor = getattr(self, method, self.generic_visit)
        return visitor(cursor, level)

    def generic_visit(self, cursor: Cursor, level):
        """ Default visitor for unhandled nodes. """
        print("  " * level + f"{cursor.kind.name} - {cursor.spelling}")

    # Specific handlers for different node types
    def visit_function_decl(self, cursor: Cursor, level) -> None:
        pass

    def visit_var_decl(self, cursor: Cursor, level) -> SSAValue:
        pass

    def visit_binary_operator(self, cursor: Cursor, level) -> SSAValue:
        pass

    def visit_floating_literal(self, cursor: Cursor, level) -> SSAValue:
        pass

    def visit_integer_literal(self, cursor: Cursor, level) -> SSAValue:
        pass

    def visit_string_literal(self, cursor: Cursor, level) -> SSAValue:
        pass

    def visit_boolean_literal(self, cursor: Cursor, level) -> SSAValue:
        pass

    def visit_unexposed_expr(self, cursor: Cursor, level) -> SSAValue:
        pass

    def visit_decl_ref_expr(self, cursor: Cursor, level) -> SSAValue:
        pass

    def visit_overloaded_decl_ref(self, cursor: Cursor, level):
        pass

    def visit_struct_decl(self, cursor, level):
        print("  " * level + f"Struct: {cursor.spelling}")
        # pass

    def visit_class_decl(self, cursor, level):
        print("  " * level + f"Class: {cursor.spelling}")
        # pass

    def visit_enum_decl(self, cursor, level):
        print("  " * level + f"Enum: {cursor.spelling}")
        # pass

    def visit_typedef_decl(self, cursor, level):
        print("  " * level + f"Typedef: {cursor.spelling} (Underlying Type: {cursor.underlying_typedef_type.spelling})")
        # pass
