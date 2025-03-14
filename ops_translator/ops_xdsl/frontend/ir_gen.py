from __future__ import annotations

from dataclasses import dataclass

from clang.cindex import Cursor, CursorKind, TranslationUnit, TypeKind

from dialects.ops import (
    BinaryOp,
    Literal,
    FuncOp,
    Param,
)

from xdsl.builder import Builder
from xdsl.dialects.builtin import (
    ModuleOp,
    IntegerAttr,
    i32,
    FunctionType,
)
from xdsl.ir import (
    SSAValue,
    Block,
    Region,
)
from xdsl.rewriter import InsertPoint
from xdsl.utils.scoped_dict import ScopedDict

from frontend.ast_visitor import ASTVisitor

# TODO: Import necessary classes
import xdsl.dialects.llvm as llvm
import frontend.utils as utils

@dataclass(init=False)
class IRGen(ASTVisitor):
    """
    Implement the MLIR (OPS IR) emission from clang AST.

    This will emit the MLIR representation of OPS DSL, preserving
    the semantics of the language and allow to perform accurate
    analysis and transformation based on these high level semantics.
    """

    module: ModuleOp

    builder: Builder

    symbol_table: ScopedDict[str, SSAValue] | None = None

    def __init__(self):
        self.module = ModuleOp([])
        self.builder = Builder(InsertPoint.at_end(self.module.body.blocks[0]))

    def declare(self, var: str, value: SSAValue) -> bool:
        """
        Declare a variable in the current scope.
        """
        assert self.symbol_table is not None
        if var in self.symbol_table:
            return False
        self.symbol_table[var] = value
        return True

    def ir_gen(self, ast: TranslationUnit) -> ModuleOp:
        self.symbol_table = ScopedDict[str, SSAValue]()
        for cursor in ast.cursor.get_children():
            if isinstance(cursor, Cursor):
                self.visit(cursor, 0)

        return self.module

    def visit_function_decl(self, cursor, level) -> FuncOp:
        """
        Emit a function declaration in the current scope.
        """
        if cursor.get_definition() is None:
            return self.visit_function_signature(cursor)

        # Keep the parent
        parent_build = self.builder

        # Create a scope in the symbol table to hold variable declarations.
        self.symbol_table = ScopedDict[str, SSAValue](parent=self.symbol_table)

        params: list[Param] = []
        body_cursor: Cursor | None = None
        for child in cursor.get_children():
            if child.kind == CursorKind.PARM_DECL:
                params.append(Param(child.spelling, child.type.spelling))
            elif child.kind == CursorKind.COMPOUND_STMT:
                body_cursor = child

        input_types = [utils.get_type(param.type) for param in params]

        block = Block(arg_types=input_types)

        # Create the block for the current function
        self.builder = Builder(InsertPoint.at_end(block))

        # Declare all the function arguments in the symbol table.
        for param, value in zip(params, block.args):
            self.declare(param.name, value)

        if body_cursor is not None:
            self.visit(body_cursor, level + 1)

        # TODO: Handle ReturnOP

        return_type = utils.get_type(cursor.result_type.spelling)

        func_type = FunctionType.from_lists(input_types, [return_type])

        # clean up
        self.symbol_table = self.symbol_table.parent
        self.builder = parent_build

        func = self.builder.insert(
            FuncOp(cursor.spelling, func_type, Region(block), private=False)
        )

        return func

    def visit_function_signature(self, cursor: Cursor) -> FuncOp:
        params: list[Param] = []
        for child in cursor.get_children():
            if child.kind == CursorKind.PARM_DECL:
                params.append(Param(child.spelling, child.type.spelling))

        input_types = [utils.get_type(param.type) for param in params]
        result_type = utils.get_type(cursor.result_type.spelling)
        func_type = FunctionType.from_lists(input_types, [result_type])
        return self.builder.insert(FuncOp(cursor.spelling, func_type, Region()))

    def visit_var_decl(self, cursor, level):
        """
        Handle the variable declaration, this will codegen the expression that forms the
        initializer and record the value in the symbol table before returning it.
        Future expressions will be able to reference this variable through symbol
        table lookup.
        """

        var_name = cursor.spelling
        var_type = utils.get_type(cursor.type.spelling)

        # Handle the initializer expression
        value = llvm.UndefOp(i32).res
        for child in cursor.get_children():
            if isinstance(child, Cursor):
                value = self.visit(child, level + 1)
            break

        self.declare(var_name, value)

        return value

    def visit_binary_operator(self, cursor, level):
        """
        Handle the binary operator, this will codegen the operands and the operation
        and return the resulting value.
        """

        # Handle the left operand
        children = cursor.get_children()
        left = self.visit(next(children), level + 1)
        right = self.visit(next(children), level + 1)

        bin_op = utils.get_binary_operator(cursor)
        op = self.builder.insert(BinaryOp(bin_op, left, right))

        return op.res

    def visit_floating_literal(self, cursor, level) -> SSAValue:
        value = utils.get_literal_value(cursor)

        literal = Literal(float(value), 32)
        op = self.builder.insert(literal)
        return op.res

    def visit_integer_literal(self, cursor, level) -> SSAValue:
        value = utils.get_literal_value(cursor)

        literal = Literal(int(value), 32)
        op = self.builder.insert(literal)
        return op.res

    def visit_boolean_literal(self, cursor, level) -> SSAValue:
        value = utils.get_literal_value(cursor)

        literal = Literal(bool(value), 1)
        op = self.builder.insert(literal)
        return op.res

    def visit_string_literal(self, cursor, level) -> SSAValue:
        value = utils.get_literal_value(cursor)

        literal = Literal(str(value), 32)
        op = self.builder.insert(literal)
        return op.res

    def visit_unexposed_expr(self, cursor, level) -> SSAValue|FunctionType:
        # Check and handle overloaded function calls
        children = cursor.get_children()
        first_child = next(children)
        if isinstance(first_child, Cursor) & utils.is_contain_overload_func(first_child):
            return self.handle_overloaded_function(cursor, level)

        # TODO: Handle other unexposed expressions
        # TODO: Add type cast for cast operations
        # for child in cursor.get_children():
        #     if isinstance(child, Cursor):
        #          self.visit(child, level + 1)

    def visit_decl_ref_expr(self, cursor, level) -> SSAValue|FunctionType:
        var_name = utils.get_decl_ref_name(cursor)
        return self.symbol_table[var_name]

    def handle_overloaded_function(self, cursor, level) -> FunctionType:
        pass

    def visit_overloaded_decl_ref(self, cursor, level):
        pass
