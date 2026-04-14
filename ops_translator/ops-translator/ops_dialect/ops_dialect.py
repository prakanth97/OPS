from xdsl.traits import IsTerminator
from xdsl.ir import SSAValue, TypeAttribute, ParametrizedAttribute, Attribute, Operation
from xdsl.irdl import (
    IRDLOperation,
    param_def,
    irdl_op_definition,
    irdl_attr_definition,
    operand_def,
    var_operand_def,
    result_def,
    traits_def,
    region_def,
    var_result_def,
    attr_def,
    opt_operand_def,
    opt_attr_def,
    AttrSizedOperandSegments
)

from xdsl.dialects.llvm import LLVMArrayType, LLVMPointerType, i32
from xdsl.dialects.builtin import StringAttr, IntegerType, IntegerAttr, BoolAttr

from typing import List
from .ops_types import *


@irdl_op_definition
class ExtractArgOp(IRDLOperation):
    name = "ops.extract_arg"
    
    ops_arg = operand_def(Attribute)

    result = result_def()

    def __init__(self, arg: SSAValue):
        super().__init__(operands=[arg], result_types=[ops_arg_type])

@irdl_op_definition
class ExtractArgDatOp(IRDLOperation):
    name = "ops.extract_arg_dat"
    
    ops_arg = operand_def(Attribute)

    result = result_def()

    def __init__(self, arg: SSAValue):
        super().__init__(operands=[arg], result_types=[ops_dat_type])


@irdl_op_definition
class ExtractArgDatDataOp(IRDLOperation):
    name = "ops.extract_arg_dat_data"
    
    ops_dat = operand_def(Attribute)

    result = result_def()

    def __init__(self, arg: SSAValue):
        super().__init__(operands=[arg], result_types=[LLVMPointerType()])


@irdl_op_definition
class ParLoopOp(IRDLOperation):

    name = "ops.par_loop"
    kernel_name_ptr = operand_def()
    block = operand_def()
    dim = operand_def()
    range_ptr = operand_def()

    dats = var_operand_def()
    idx = opt_operand_def()
    reductions = var_operand_def()
    
    # This is where kernel computation goes
    body = region_def()

    irdl_options = [AttrSizedOperandSegments()]



@irdl_op_definition
class ReturnOp(IRDLOperation):

    name = "ops.return"
    
    # Variable number of operands (can return multiple values)
    arguments = var_operand_def()

    traits = traits_def(IsTerminator())


@irdl_op_definition
class PointerToMemref(IRDLOperation):
    name = "ops.ptr_to_memref"
    ptr = operand_def()
    result = result_def()
    is_reduction = opt_attr_def(BoolAttr)

    # attribute which tells whether its mesh data or a reduction pointer


@irdl_op_definition
class MemrefToStencilField(IRDLOperation):
    name = "ops.memref_to_field"
    ref = operand_def()
    result = result_def()


@irdl_op_definition
class ComputeOp(IRDLOperation):
    """Placeholder compute operation - later becomes stencil.apply"""

    name = "ops.compute"
    operands_ = var_operand_def()
    
    # Kernel computation body goes here
    body = region_def()


@irdl_op_definition
class GetIndexOp(IRDLOperation):
    """Get the current iteration indices for all dimensions"""

    name = "ops.get_index"

    # indices = result_def()
    indices = var_result_def(i32)


    def __init__(self, dim_value: int):
        Operation.__init__(
            self,
            operands=[],
            result_types=[IntegerType(32) for _ in range(dim_value)],
            attributes={"dim": IntegerAttr(dim_value, IntegerType(32))},
            successors=[],
            regions=[]
        )

    @staticmethod
    def get(dim: int):
        return GetIndexOp(dim)

@irdl_op_definition
class ExtractIndexOp(IRDLOperation):
    """Extract a specific dimension from the index"""

    name = "ops.extract_index"

    indices = var_operand_def(i32)
    result = result_def(i32)
    
    dimension = attr_def(IntegerAttr)


    def __init__(self, indices_vals: List[SSAValue], dimension_val: int):
        super().__init__(
            operands=indices_vals,
            result_types=[IntegerType(32)],
            attributes={"dimension": IntegerAttr(dimension_val, IntegerType(32))}
        )

    @staticmethod
    def get(indices: List[SSAValue], dimension: int):
        return ExtractIndexOp(indices, dimension)
