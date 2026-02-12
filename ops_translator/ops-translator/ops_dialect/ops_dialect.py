from xdsl.traits import IsTerminator
from xdsl.ir import SSAValue, TypeAttribute, ParametrizedAttribute, Attribute
from xdsl.irdl import (
    IRDLOperation,
    param_def,
    irdl_op_definition,
    irdl_attr_definition,
    operand_def,
    var_operand_def,
    result_def,
    traits_def,
    region_def
)

from xdsl.dialects.llvm import LLVMArrayType, LLVMPointerType, i32
from xdsl.dialects.builtin import StringAttr, IntegerType
 
import ops_types


@irdl_op_definition
class ExtractArgTypeOp(IRDLOperation):
    name = "ops.extract_arg_type"

    ops_arg = operand_def(Attribute)

    result = result_def(IntegerType(32))

    def __init__(self, arg: SSAValue):
        super().__init__(operands=[arg], result_types=[IntegerType(32)])


@irdl_op_definition
class ExtractArgDatOp(IRDLOperation):
    name = "ops.extract_arg_dat"
    
    ops_arg = operand_def(Attribute)

    result = result_def()

    def __init__(self, arg: SSAValue):
        super().__init__(operands=[arg], result_types=[ops_types.ops_dat_type])


@irdl_op_definition
class ExtractArgDatDataOp(IRDLOperation):
    name = "ops.extract_arg_dat_data"
    
    ops_dat = operand_def(Attribute)

    result = result_def()

    def __init__(self, arg: SSAValue):
        super().__init__(operands=[arg], result_types=[LLVMPointerType()])


@irdl_op_definition
class ExtractArgDatSizeOp(IRDLOperation):
    name = "ops.extract_arg_dat_size"
    
    ops_dat = operand_def(Attribute)

    result = result_def()

    def __init__(self, arg: SSAValue):
        super().__init__(operands=[arg], result_types=[LLVMArrayType.from_size_and_type(
            ops_types.OPS_MAX_DIM, i32)
        ])


@irdl_op_definition
class ExtractArgAccessOp(IRDLOperation):
    name = "ops.extract_arg_access"
    
    ops_arg = operand_def(Attribute)

    result = result_def()

    def __init__(self, arg: SSAValue):
        super().__init__(operands=[arg], result_types=[i32])


@irdl_attr_definition
class OpsBlockType(ParametrizedAttribute, TypeAttribute):
    name = "ops.block"


@irdl_attr_definition
class OpsArgType(ParametrizedAttribute, TypeAttribute):
    name = "ops.arg"

    access_mode: StringAttr = param_def(StringAttr)

    def __init__(self, access_mode: str | StringAttr = "read"):
        if isinstance(access_mode, str):
            access_mode = StringAttr(access_mode)
        super().__init__(access_mode)


@irdl_op_definition
class ParLoopOp(IRDLOperation):

    name = "ops.par_loop"
    kernel_name_ptr = operand_def()
    block = operand_def()
    dim = operand_def()
    range_ptr = operand_def()
    args = var_operand_def()
    
    # This is where kernel computation goes
    body = region_def()


@irdl_op_definition
class YieldOp(IRDLOperation):

    name = "ops.yield"
    
    # Variable number of operands (can yield multiple values)
    arguments = var_operand_def()

    traits = traits_def(IsTerminator())


irdl_op_definition
class ExtractBlockOp(IRDLOperation):

    name = "ops.extract_block"
    block_struct = operand_def()
    result = result_def()


@irdl_op_definition
class ExtractDimOp(IRDLOperation):
    name = "ops.extract_dim"
    dim_value = operand_def()
    result = result_def()


@irdl_op_definition
class ExtractRangeOp(IRDLOperation):
    name = "ops.extract_range"
    range_ptr = operand_def()
    dim = operand_def()
    result = result_def()


@irdl_op_definition
class PointerToMemref(IRDLOperation):
    name = "ops.ptr_to_memref"
    ptr = operand_def()
    result = result_def()


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
