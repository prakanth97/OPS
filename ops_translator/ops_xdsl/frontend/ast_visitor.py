from clang.cindex import Cursor, CursorKind, TranslationUnit, TypeKind, conf
from xdsl.ir import SSAValue

class ASTVisitor:

    def visit(self, cursor: Cursor):
        method = 'visit_' + cursor.kind.name.lower()
        visitor = getattr(self, method, self.generic_visit)
        return visitor(cursor)

    def generic_visit(self, cursor: Cursor):
        """ Default visitor for unhandled nodes. """
        print(f"{cursor.kind.name} - {cursor.spelling}")

    # Specific handlers for different node types
    def visit_function_decl(self, cursor: Cursor) -> None:
        pass

    def visit_var_decl(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_binary_operator(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_floating_literal(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_integer_literal(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_string_literal(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_boolean_literal(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_unexposed_expr(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_decl_ref_expr(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_overloaded_decl_ref(self, cursor: Cursor):
        pass

    def visit_compound_stmt(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_decl_stmt(self, cursor: Cursor) -> SSAValue:
        pass

    def visit_paren_expr(self, cursor: Cursor) -> SSAValue:
        for child in cursor.get_children():
                return self.visit(child)

    def visit_init_list_expr(self, cursor: Cursor):
        pass

