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

from typing import Optional
from .ops_dialect import *
from .ops_types import *


from xdsl.dialects.builtin import ModuleOp, FunctionType, IndexType, IntegerType, NoneType
from xdsl.dialects.func import FuncOp, ReturnOp
from xdsl.ir import Block, Region
from xdsl.builder import Builder, InsertPoint
from kernel_config import KernelConfig

def create_function_with_wrapper(config: KernelConfig) -> ModuleOp:
    module = ModuleOp([])

    builder = Builder(InsertPoint.at_start(module.body.block))  

    param_types = [
        LLVMPointerType(),  # name
        ops_block_type,     # block
        IntegerType(32),    # dim
        LLVMPointerType(),  # range
    ] + [LLVMPointerType() for _ in config.arg_order]  # ops_args

    entry_block = Block(arg_types=param_types)

    # add name hints to fixed parameters
    entry_block.args[0].name_hint = 'name'
    entry_block.args[1].name_hint = 'block'
    entry_block.args[2].name_hint = 'dim'
    entry_block.args[3].name_hint = 'range'

    for i in range(4, len(entry_block.args)):
        entry_block.args[i].name_hint = 'ops_arg' + str(i - 3)

    fn = LLVMFuncOp(
        sym_name=config.name + "_impl",
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

    wrapper_fn = generate_c_wrapper(config.name, param_types, fn)

    builder.insert(wrapper_fn)

    return module


def generate_c_wrapper(wrapper_name: str, param_types: list, main_func: LLVMFuncOp) -> LLVMFuncOp:
    """
    Generate _mlir_ciface_ wrapper that converts pointer arguments to values
    and calls the main function.
    """
    
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
    # - param 4+: ops_arg_type (struct) - LOAD
    
    loaded_args = []
    for i, param_type in enumerate(param_types):
        arg_ptr = wrapper_entry.args[i]
                
        # Only load i32 and struct types, pass pointers through
        if isinstance(param_type, (LLVMPointerType)):
            # Pass through pointers directly
            loaded_args.append(arg_ptr)
        else:
            # Load value types (i32, struct)
            loaded_op = builder.insert(llvm.LoadOp(arg_ptr, param_type))
            loaded_args.append(loaded_op.results[0])
    
    # Call the main function
    builder.insert(llvm.CallOp(
        main_func.sym_name.data,
        *loaded_args
    ))
    
    builder.insert(llvm.ReturnOp())
    
    return wrapper_fn


def create_par_loop(
    kernel_name_ptr: SSAValue,
    block: SSAValue,
    dim: SSAValue,
    range_ptr: SSAValue,
    dat_ptrs: List[SSAValue],
    idx_ptr: Optional[SSAValue],
    reduction_ptrs: List[SSAValue]
):
    """Create ops.par_loop in function body"""
    
    par_loop = ParLoopOp.build(
        operands=[
            [kernel_name_ptr], 
            [block], 
            [dim], 
            [range_ptr],
            dat_ptrs,
            [idx_ptr] if idx_ptr else [],
            reduction_ptrs
        ],
        regions=[Region([Block()])]
    )
    
    return par_loop

def add_ops_operations(module: ModuleOp, kernel_config: KernelConfig):

    fn = module.body.ops.first
    fn_body = fn.body.blocks.first

    builder = Builder(InsertPoint.at_start(fn_body))

    kernel_name = fn_body.args[0]
    block = fn_body.args[1]
    dim = fn_body.args[2]
    range_ptr = fn_body.args[3]

    dat_args = []
    idx_arg = None
    reduction_args = []

    for arg_info in kernel_config.arg_order:
        fn_arg = fn_body.args[4 + arg_info.index]

        if arg_info.arg_type == "dat":
            dat_args.append(fn_arg)
        elif arg_info.arg_type == "idx":
            idx_arg = fn_arg
        elif arg_info.arg_type == "reduce":
            reduction_args.append(fn_arg)

    op = create_par_loop(
        kernel_name,
        block,
        dim,
        range_ptr,
        dat_args,
        idx_arg,
        reduction_args
    )

    builder.insert(op)

    return module
