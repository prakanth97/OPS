from xdsl.passes import ModulePass
from xdsl.pattern_rewriter import PatternRewriter, RewritePattern, op_type_rewrite_pattern
from xdsl.ir import Operation, SSAValue
from xdsl.builder import Builder, InsertPoint

from xdsl.dialects.llvm import FuncOp as LLVMFuncOp
from xdsl.dialects.builtin import IntegerType, f32, f64, Region
from xdsl.dialects.stencil import ApplyOp, TempType, Block, AllocOp, ReturnOp, FieldType, ExternalLoadOp, LoadOp, StencilBoundsAttr, StoreOp, AccessOp
from xdsl.dialects import stencil
from .ops_dialect import ReturnOp as OPSReturnOp
from .ops_dialect import ComputeOp
from xdsl.dialects.llvm import LLVMFunctionType, LLVMPointerType, LLVMVoidType
from xdsl.dialects.func import FuncOp as FuncFuncOp

from kernel_config import KernelConfig
from kernel_parser import KernelParser

from .ops_types import *

class LowerComputePass(ModulePass):
    """
    Lower ops.compute to Stencil operations

    Input:
        ops.compute(%data_field, %data_ref, ...)
    """

    name = "lower-ops-compute"

    def __init__(self, config: KernelConfig):
        self.config = config
        self.kernel_parser = KernelParser()

    
    def apply(self, ctx, module):

        for func in module.walk():
            if not isinstance(func, FuncFuncOp):
                continue

            for op in list(func.walk()):
                if isinstance(op, ComputeOp):
                    self.lower_compute(op)
    
    def lower_compute(self, compute_op: ComputeOp):
        """Lower a single ops.compute operation"""
        
        builder = Builder(InsertPoint.before(compute_op))

        range_bounds = StencilBoundsAttr(self.config.iteration_bounds)
        temp_type = TempType(self.config.grid_size, f64)

        read_field_operands = []
    
        for temp_operand_idx in range(len(self.config.kernel_info.read_fields)):
            # Get the corresponding operand from compute_op
            if temp_operand_idx < len(compute_op.operands):
                read_field_operands.append(compute_op.operands[temp_operand_idx])
            else:
                raise ValueError(f"Missing operand for read field at position {temp_operand_idx}")

        # num_field_operands = len(self.config.kernel_info.read_fields) + len(self.config.kernel_info.write_fields)

        num_field_operands = len(
            set(self.config.kernel_info.read_fields) |
            set(self.config.kernel_info.write_fields)
        )

        reduction_operands = []
        
        for i in range(len(self.config.kernel_info.reductions)):
            reduction_idx = num_field_operands + i
            if reduction_idx < len(compute_op.operands):
                reduction_operands.append(compute_op.operands[reduction_idx])
            else:
                raise ValueError(f"Missing operand for reduction at position {i}")

        body_block = Block(arg_types=[
            temp_type  # One for each read field
            for _ in self.config.kernel_info.read_fields
        ])
        
        stencil_ops = self.kernel_parser.kernel_info_to_stencil_ops(
            kernel_info=self.config.kernel_info,
            temp_args= body_block.args,
            global_consts=self.config.global_consts
        )
        
        # Add all ops to the body block
        for op in stencil_ops:
            body_block.add_op(op)
        body = Region([body_block])

        # Replace ops.return with stencil.return in the body
        block = body.blocks[0]
        for op in list(block.ops):
            if isinstance(op, OPSReturnOp):
                return_op = stencil.ReturnOp.get(list(op.operands))
                block.insert_op_before(return_op, op)
                block.erase_op(op)


        write_field_operands = []
        for write_field_param_name in self.config.kernel_info.write_fields:
            write_field_operand_idx = self.config.kernel_info.param_order.index(write_field_param_name)

            if write_field_operand_idx < len(compute_op.operands):
                write_field_operands.append(compute_op.operands[write_field_operand_idx])
            else:
                raise ValueError(f"Missing operand for write field {write_field_param_name}")

        
        # Build apply op using buffer semantics

        apply_op = ApplyOp.build(
            operands=[read_field_operands, write_field_operands, reduction_operands], # actual FIELDS
            regions=[body],
            result_types=[[]], # no result, as we don't return a temp
            properties={"bounds": range_bounds}
        )

        builder.insert(apply_op)

        compute_op.detach()
        compute_op.erase()
