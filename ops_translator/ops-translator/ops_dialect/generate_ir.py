from xdsl.ir import SSAValue, TypeAttribute, ParametrizedAttribute, Block, Region
from xdsl.dialects.builtin import (
    StringAttr,
    IntegerAttr,
    SymbolRefAttr,
    DenseIntElementsAttr,
    IndexType,
    VectorType,
    ModuleOp,
    NoneAttr
)
from xdsl.builder import Builder, InsertPoint, ImplicitBuilder
from xdsl.dialects.arith import ConstantOp
from xdsl.dialects.func import FuncOp, ReturnOp
from xdsl.dialects import llvm
from xdsl.dialects.llvm import (
    LLVMStructType, 
    LLVMArrayType, 
    LLVMPointerType, 
    i32, 
    LLVMFunctionType, 
    LLVMVoidType,
    DictionaryAttr, 
    UnitAttr, 
    ArrayAttr, 
    LinkageAttr,
    FuncOp as LLVMFuncOp
)
from xdsl.dialects.builtin import (
    ModuleOp,
    FunctionType,
    StringAttr,
    IntegerType, 
    OpaqueAttr
)
from ops_dialect import *
import ops_types



def create_function(kernel_name: str) -> ModuleOp:
    module = ModuleOp([])

    builder = Builder(InsertPoint.at_start(module.body.block))  

    entry_block = Block(
        arg_types=[
            LLVMPointerType(),
            ops_types.ops_block_type,
            IntegerType(32),
            LLVMPointerType(),
            ops_types.ops_arg_type,
        ],
    )

    # add name hints to fixed parameters
    entry_block.args[0].name_hint = 'name'
    entry_block.args[1].name_hint = 'block'
    entry_block.args[2].name_hint = 'dim'
    entry_block.args[3].name_hint = 'range'

    for i in range(4, len(entry_block.args)):
        entry_block.args[i].name_hint = 'ops_arg' + str(i - 3)

    fn = LLVMFuncOp(
        sym_name="ops_par_loop" + kernel_name,
        function_type=LLVMFunctionType(
            inputs=[
                LLVMPointerType(), # char pointer (i8) (kernel name for debugging)
                ops_types.ops_block_type,
                IntegerType(32),
                LLVMPointerType(), # i32
                ops_types.ops_arg_type
            ],
            output=LLVMVoidType(),
        ),
        linkage=LinkageAttr("external"),
        body=[Region([entry_block])],
        other_props={
            "llvm.emit_c_interface": UnitAttr() # needs to be tested
        }
    )

    builder.insert(fn)

    builder1 = Builder(InsertPoint.at_end(entry_block))
    builder1.insert(llvm.ReturnOp())

    return module

def create_par_loop(
    kernel_name_ptr: SSAValue,
    block: SSAValue,
    dim: SSAValue,
    range_ptr: SSAValue,
    args: list[SSAValue],
    kernel_instructions: list # parsed kernel instructions
):
    """Create ops.par_loop in function body"""

    body_block = Block(arg_types=[])
    
    # Manually add operations to the block
    body_block.add_ops(kernel_instructions)
    
    body_region = Region([body_block])
    
    par_loop = ParLoopOp.create(
        operands=[kernel_name_ptr, block, dim, range_ptr, args],
        regions=[body_region]
    )
    
    return par_loop

def add_ops_operations(module: ModuleOp):

    fn = module.body.ops.first
    fn_body = fn.body.blocks.first

    builder = Builder(InsertPoint.at_start(fn_body))

    # create list from parsed kernel here
    result1 = ConstantOp(IntegerAttr(0, IntegerType(64)))
    result2 = ConstantOp(IntegerAttr(1, IntegerType(64)))

    yield_op = YieldOp.create(operands=[result1.results[0], result2.results[0]])
    kernel_ops = [result1, result2, yield_op]

    op = create_par_loop(fn_body.args[0], fn_body.args[1], fn_body.args[2], fn_body.args[3], fn_body.args[4], kernel_ops)

    builder.insert(op)

    return module
