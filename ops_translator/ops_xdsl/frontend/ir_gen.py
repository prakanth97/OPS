from __future__ import annotations

from dataclasses import dataclass

from clang.cindex import Cursor, CursorKind, TranslationUnit, TypeKind, conf

from xdsl.builder import Builder
from xdsl.dialects.builtin import ModuleOp
from xdsl.ir import SSAValue
from xdsl.rewriter import InsertPoint
from xdsl.utils.scoped_dict import ScopedDict

from frontend.ast_visitor import ASTVisitor

@dataclass(init=False)
class IRGen(ASTVisitor):
    """
    Implement the IR generator for OPS DSL.
    """

    module: ModuleOp

    builder: Builder

    global_symbol_table: ScopedDict[str, SSAValue] | None

    symbol_table: ScopedDict[str, SSAValue] | None = None

    def __init__(self):
        self.module = ModuleOp()
        self.builder = Builder(InsertPoint.at_end(self.module.body.blocks[0]))

    def ir_gen(self, ast: TranslationUnit):
        self.visit(ast.cursor, 0)

    # def visit_var_decl(self, cursor, level):

