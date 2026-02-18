from xdsl.ir import SSAValue, Block, Region
from xdsl.dialects.builtin import (
    FloatAttr,
    ModuleOp,
    f64
)
from xdsl.builder import Builder, InsertPoint
from xdsl.dialects.arith import ConstantOp
from xdsl.dialects import llvm
from xdsl.dialects.llvm import ( 
    LLVMPointerType, 
    LLVMFunctionType, 
    LLVMVoidType,
    UnitAttr, 
    LinkageAttr,
    FuncOp as LLVMFuncOp
)
from xdsl.dialects.builtin import (
    ModuleOp,
    IntegerType, 
)
from ops_dialect import *
import ops_types


from xdsl.dialects.builtin import ModuleOp, FunctionType, IndexType, IntegerType, NoneType
from xdsl.dialects.func import FuncOp, ReturnOp
from xdsl.ir import Block, Region
from xdsl.builder import Builder, InsertPoint

def create_function_with_wrapper(kernel_name: str) -> ModuleOp:
    module = ModuleOp([])

    builder = Builder(InsertPoint.at_start(module.body.block))  

    param_types = [
        LLVMPointerType(),
        ops_types.ops_block_type,
        IntegerType(32),
        LLVMPointerType(),
        ops_types.ops_arg_type
    ]

    entry_block = Block(arg_types=param_types)

    # add name hints to fixed parameters
    entry_block.args[0].name_hint = 'name'
    entry_block.args[1].name_hint = 'block'
    entry_block.args[2].name_hint = 'dim'
    entry_block.args[3].name_hint = 'range'

    for i in range(4, len(entry_block.args)):
        entry_block.args[i].name_hint = 'ops_arg' + str(i - 3)

    fn = LLVMFuncOp(
        sym_name="ops_par_loop_" + kernel_name,
        function_type=LLVMFunctionType(
            inputs=param_types,
            output=LLVMVoidType(),
        ),
        linkage=LinkageAttr("external"),
        body=[Region([entry_block])],
    )

    builder.insert(fn)

    builder1 = Builder(InsertPoint.at_end(entry_block))
    builder1.insert(llvm.ReturnOp())

    wrapper_fn = generate_c_wrapper(kernel_name, param_types, fn)

    builder.insert(wrapper_fn)

    return module


def generate_c_wrapper(kernel_name: str, param_types: list, main_func: LLVMFuncOp) -> LLVMFuncOp:
    """
    Generate _mlir_ciface_ wrapper that converts pointer arguments to values
    and calls the main function.
    """
    
    wrapper_name = f"_mlir_ciface_ops_par_loop_{kernel_name}"
    
    # All parameters become pointers in the wrapper
    wrapper_param_types = [LLVMPointerType()] * len(param_types)
    
    # Create wrapper entry block
    wrapper_entry = Block(arg_types=wrapper_param_types)
    
    # Create wrapper function
    wrapper_fn = LLVMFuncOp(
        sym_name=wrapper_name,
        function_type=LLVMFunctionType(
            inputs=wrapper_param_types,
            output=LLVMVoidType(),
        ),
        linkage=LinkageAttr("external"),
        body=[Region([wrapper_entry])],
    )
    
    # Build the wrapper body
    builder = Builder(InsertPoint.at_end(wrapper_entry))
    
    # Track which params need loading:
    # - param 0: LLVMPointerType (char*) - pass through
    # - param 1: ops_block_type (pointer) - pass through
    # - param 2: i32 - LOAD
    # - param 3: LLVMPointerType (int*) - pass through
    # - param 4: ops_arg_type (struct) - LOAD
    
    loaded_args = []
    for i, param_type in enumerate(param_types):
        arg_ptr = wrapper_entry.args[i]
                
        # Only load i32 and struct types, pass pointers through
        if isinstance(param_type, (LLVMPointerType,)):
            # Pass through pointers directly
            loaded_args.append(arg_ptr)
        else:
            # Load value types (i32, struct)
            loaded_op = builder.insert(llvm.LoadOp(arg_ptr, param_type))
            loaded_args.append(loaded_op.results[0])
    
    # Call the main function
    builder.insert(llvm.CallOp(
        main_func.sym_name.data,
        *loaded_args,
        # return_type=LLVMVoidType(),
    ))
    
    builder.insert(llvm.ReturnOp())
    
    return wrapper_fn


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
        sym_name="ops_par_loop_" + kernel_name,
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


def create_func_function(kernel_name: str) -> ModuleOp:
    module = ModuleOp([])
    builder = Builder(InsertPoint.at_start(module.body.block))

    # ---- HIGH LEVEL TYPES ----
    # replace raw pointers with abstract values
    name_t = IndexType()                 # opaque debug token
    block_t = IndexType()                # opaque handle
    dim_t = IntegerType(32)
    range_t = IndexType()                # opaque handle
    arg_t = IndexType()                  # opaque handle

    entry_block = Block(arg_types=[name_t, block_t, dim_t, range_t, arg_t])

    # name hints
    entry_block.args[0].name_hint = 'name'
    entry_block.args[1].name_hint = 'block'
    entry_block.args[2].name_hint = 'dim'
    entry_block.args[3].name_hint = 'range'
    entry_block.args[4].name_hint = 'ops_arg1'

    # fn = FuncOp(
    #     name="ops_par_loop_" + kernel_name,
    #     function_type=FunctionType(
    #         inputs=[name_t, block_t, dim_t, range_t, arg_t],
    #         outputs=[]
    #     ),
    #     region=Region([entry_block]),
    # )

    fn = FuncOp(
        name="ops_par_loop_" + kernel_name,
        function_type=FunctionType.from_lists(
            [name_t, block_t, dim_t, range_t, arg_t],
            []
        ),
        region=Region([entry_block]),
    )


    builder.insert(fn)

    # func.return (NOT llvm.return)
    builder1 = Builder(InsertPoint.at_end(entry_block))
    builder1.insert(ReturnOp())

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
    result1 = ConstantOp(FloatAttr(0.0, f64))

    yield_op = YieldOp.create(operands=[result1.results[0]])
    kernel_ops = [result1, yield_op]

    op = create_par_loop(fn_body.args[0], fn_body.args[1], fn_body.args[2], fn_body.args[3], fn_body.args[4], kernel_ops)

    builder.insert(op)

    return module
