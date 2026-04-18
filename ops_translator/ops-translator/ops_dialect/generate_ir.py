from xdsl.ir import SSAValue, Block, Region
from xdsl.builder import Builder, InsertPoint
from xdsl.dialects import llvm, func
from xdsl.dialects.llvm import ( 
    LLVMPointerType, 
    FuncOp as LLVMFuncOp
)
from xdsl.dialects.func import (
    FuncOp,
    FunctionType
)
from xdsl.dialects.builtin import (
    ModuleOp,
    IntegerType, 
)

from typing import Optional
from .ops_dialect import *
from .ops_types import *


from xdsl.dialects.builtin import ModuleOp, FunctionType, IntegerType
from xdsl.dialects.func import FuncOp
from xdsl.ir import Block, Region
from xdsl.builder import Builder, InsertPoint
from kernel_config import KernelConfig


def create_wrapper_func(config: KernelConfig) -> ModuleOp:
    module = ModuleOp([])

    builder = Builder(InsertPoint.at_start(module.body.block))

    wrapper_name = config.name
    # All parameters become pointers in the wrapper

    param_types = [
        LLVMPointerType(),  # name
        ops_block_type,     # block
        IntegerType(32),    # dim
        LLVMPointerType(),  # range
    ] + [LLVMPointerType() for _ in config.arg_order]  # ops_args

    wrapper_param_types = [LLVMPointerType()] * len(param_types)
    
    # Create wrapper entry block
    wrapper_entry = Block(arg_types=wrapper_param_types)
    
    # Create wrapper function
    wrapper_fn = FuncOp(
        name=wrapper_name,
        function_type=FunctionType.from_lists(wrapper_param_types, []),
        region=Region([wrapper_entry]),
    )
    
    # Build the wrapper body
    builder.insert(wrapper_fn)
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

    builder.insert(func.ReturnOp())
    
    return module

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
    print("------------")
    print(fn)
    # exit(0)cl
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
