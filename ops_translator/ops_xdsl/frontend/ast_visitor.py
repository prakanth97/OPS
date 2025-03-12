import clang.cindex

from clang.cindex import Cursor, CursorKind, TranslationUnit, TypeKind, conf

class ASTVisitor:
    def visit(self, cursor:Cursor, level=0):
        method = 'visit_' + cursor.kind.name.lower()
        visitor = getattr(self, method, self.generic_visit)
        visitor(cursor, level)

        for child in cursor.get_children():
            self.visit(child, level + 1)

    def generic_visit(self, cursor, level):
        """ Default visitor for unhandled nodes. """
        print("  " * level + f"{cursor.kind.name} - {cursor.spelling}")

    # Specific handlers for different node types
    def visit_function_decl(self, cursor, level):
        print("  " * level + f"Function: {cursor.spelling} (Return Type: {cursor.result_type.spelling})")

    def visit_var_decl(self, cursor, level):
        print("  " * level + f"Variable: {cursor.spelling} (Type: {cursor.type.spelling})")

    def visit_struct_decl(self, cursor, level):
        print("  " * level + f"Struct: {cursor.spelling}")

    def visit_class_decl(self, cursor, level):
        print("  " * level + f"Class: {cursor.spelling}")

    def visit_enum_decl(self, cursor, level):
        print("  " * level + f"Enum: {cursor.spelling}")

    def visit_typedef_decl(self, cursor, level):
        print("  " * level + f"Typedef: {cursor.spelling} (Underlying Type: {cursor.underlying_typedef_type.spelling})")

if __name__ == "__main__":
    index = clang.cindex.Index.create()
    tu = index.parse('/Users/u5624836/Desktop/repos/OPS/ops_translator/ops_xdsl/ops_sample/laplace2d.cpp')
    visitor = ASTVisitor()
    visitor.visit(tu.cursor)
