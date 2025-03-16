"""
Notes :
TODO: Write verification of operations
"""

from typing import Union, Iterable

from xdsl.dialects.builtin import (
    IntegerAttr,
    StringAttr,
    ArrayAttr,
    ArrayOfConstraint,
    IntAttr,
    AnyAttr,
    FloatAttr,
    Attribute,
    FunctionType,
    i32,
    i64,
    f32,
    f64
)
from xdsl.ir import (
    Data,
    ParametrizedAttribute,
    Dialect,
    Region,
    Block,
    SSAValue, Operation,
)
from xdsl.irdl import (
    irdl_attr_definition,
    irdl_op_definition,
    attr_def,
    IRDLOperation,
    region_def,
    operand_def,
    AnyOf,
    result_def,
    ParameterDef,
)

from clang.cindex import Type

######### OP Definition ########

# @irdl_op_definition
# class BinaryOp(IRDLOperation):
#     name = "ops.ir.binary_op"
#
#     op = attr_def(StringAttr)
#     lhs = operand_def(Attribute)
#     rhs = operand_def(Attribute)
#     res = result_def(Attribute)
#
#     def __init__(self, op: str, lhs: SSAValue, rhs: SSAValue):
#         # TODO: Replace binary op with arith dialect
#         super().__init__(result_types=[lhs.type], attributes={"op": StringAttr(op)}, operands=[lhs, rhs])

@irdl_op_definition
class Literal(IRDLOperation):
    name = "ops.ir.literal"

    value = attr_def(AnyOf([StringAttr, IntegerAttr, FloatAttr]))
    res = result_def(Attribute)

    def __init__(self, value: Union[None, bool, int, str, float], width: int = 32):
        if type(value) is int:
            attr = IntegerAttr.from_int_and_width(value, width)
        elif type(value) is float:
            attr = FloatAttr(value, width)
        elif type(value) is str:
            attr = StringAttr(value)
        elif type(value) is bool:
            attr = IntegerAttr(1, 1)
        else:
            raise ValueError(f"Unsupported type: {type(value)}")
        super().__init__(result_types=[attr.type], attributes={"value": attr})

@irdl_op_definition
class FuncOp(IRDLOperation):
    name = "ops.ir.func"
    body = region_def()
    sym_name = attr_def(StringAttr)
    function_type = attr_def(FunctionType)
    sym_visibility = attr_def(StringAttr)

    def __init__(
            self,
            name: str,
            func_type: FunctionType,
            region: Region | type[Region.DEFAULT] = Region.DEFAULT,
            private: bool = False,
    ):
        attributes: dict[str, Attribute] = {
            "sym_name": StringAttr(name),
            "function_type": func_type,
        }

        if not isinstance(region, Region):
            region = Region(Block(arg_types=func_type.inputs))
        if private:
            attributes["sym_visibility"] = StringAttr("private")

        super().__init__(attributes=attributes, regions=[region])

@irdl_op_definition
class ReturnOP(IRDLOperation):
    name = "ops.ir.return"

@irdl_op_definition
class CallOp(IRDLOperation):
    name = "ops.ir.call"

@irdl_op_definition
class OpsDeclBlock(IRDLOperation):
    name = "ops.ir.ops_decl_block"

@irdl_op_definition
class OpsDeclDat(IRDLOperation):
    name = "ops.ir.ops_decl_dat"

@irdl_op_definition
class OpsArgDat(IRDLOperation):
    name = "ops.ir.ops_arg_dat"

@irdl_op_definition
class OpsStencil(IRDLOperation):
    name = "ops.ir.ops_stencil"

@irdl_op_definition
class OpsDeclConst(IRDLOperation):
    name = "ops.ir.ops_decl_const"

@irdl_op_definition
class OpsParLoop(IRDLOperation):
    name = "ops.ir.ops_par_loop"


######### Attr Definition ########

# @irdl_attr_definition
# class Param(ParametrizedAttribute):
#     name = "ops.ir.param"
#
#     param_name = parameter_def[StringAttr]
#     param_type =
#

# @irdl_attr_definition
# class ArrayType(ParametrizedAttribute):
#     name = "array.type"
#
#     member_type: Union[i32, f32, f64]
#     size: ParameterDef[IntegerAttr]
#
#     # def __init__(self, member_type, size: int):
#         # self.member_type = member_type
#         # self.size = IntegerAttr.from_index_int_value(size)
#

class Param:
    name: str
    type: Type

    def __init__(self, name: str, typ: Type):
        self.name = name
        self.type = typ
