from xdsl.passes import ModulePass
from xdsl.pattern_rewriter import PatternRewriter, RewritePattern, op_type_rewrite_pattern
from xdsl.ir import Operation, SSAValue
from xdsl.builder import Builder, InsertPoint

from xdsl.dialects.llvm import FuncOp as LLVMFuncOp
from xdsl.dialects.builtin import IntegerType, f32, f64
from xdsl.dialects.stencil import ApplyOp, TempType, Block, AllocOp, ReturnOp, FieldType, ExternalLoadOp, LoadOp, StencilBoundsAttr, ExternalStoreOp

from ops_dialect import *
from xdsl.dialects.llvm import LLVMFunctionType, LLVMPointerType, LLVMVoidType


import ops_types
class LowerComputePass(ModulePass):
    """
    Lower ops.compute to Stencil operations
    
    Input:
        ops.compute(%data_field, %data_ref) {
            <kernel computation body for stencil accesses>
        }
    """
    
    name = "lower-ops-compute"
    
    def apply(self, ctx, module):

        for func in module.walk():
            if not isinstance(func, LLVMFuncOp):
                continue
            
            for op in list(func.walk()):
                if isinstance(op, ComputeOp):
                    self.lower_par_loop(op)
    
    def lower_par_loop(self, compute_op: ComputeOp):
        """Lower a single ops.compute operation"""
        
        builder = Builder(InsertPoint.before(compute_op))

        bottom_range_bounds = StencilBoundsAttr([(-1, 7), (-1, 0)])
        
        temp_type = TempType(bottom_range_bounds, f64)

        load_op = LoadOp.build(
            operands=[compute_op.operands[0]],
            result_types=[temp_type]
        )

        load_op.results[0].name_hint = "temp"
        builder.insert(load_op)

        # dat = self.extract_arg_dat(builder, ops_arg)
        # access = self.extract_arg_access(builder, ops_arg)

        # args_info.append(dat)

        # self.extract_arg_dat_data(builder, dat)
        # self.extract_arg_dat_size(builder, dat)

        
        # detach compute_op body to use in stencil.apply
        body = compute_op.detach_region(compute_op.body)

        # Replace ops.yield with stencil.return in the body
        block = body.blocks[0]
        for op in list(block.ops):
            if isinstance(op, YieldOp):
                return_op = ReturnOp.get(list(op.operands))
                block.insert_op_before(return_op, op)
                block.erase_op(op)
            
            # Should also add a condition here for ops.access to be lowered to stencil.access


        apply_op = ApplyOp.get(
            [load_op.results[0]],
            body,
            [temp_type],
            bottom_range_bounds
        )

        apply_op.results[0].name_hint = "apply"
        builder.insert(apply_op)

        external_store = ExternalStoreOp.build(operands=[apply_op.results[0], compute_op.operands[1]])
        builder.insert(external_store)

        compute_op.detach()
        compute_op.erase()
    
