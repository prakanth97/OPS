from xdsl.passes import ModulePass
from xdsl.pattern_rewriter import PatternRewriter, RewritePattern, op_type_rewrite_pattern
from xdsl.ir import Operation, SSAValue
from xdsl.builder import Builder, InsertPoint

from xdsl.dialects.llvm import FuncOp as LLVMFuncOp
from xdsl.dialects.builtin import IntegerType

from ops_dialect import *
from xdsl.dialects.llvm import LLVMFunctionType, LLVMPointerType, LLVMVoidType


import ops_types
class LowerParLoopPass(ModulePass):
    """
    Lower ops.par_loop to:
    1. Extraction operations (ops.extract_*)
    2. Memory operations (ops_dat data to memref)
    3. Stencil operations (ops.compute to stencil eventually)
    
    Input:
        ops.par_loop(%kernel, %block, %dim, %range, %ops_arg1) {
            <kernel computation body for stencil accesses>
        }
    """
    
    name = "lower-par-loop"
    
    def apply(self, ctx, module):
        # Walk through all ops.par_loop operations
        for func in module.walk():
            if not isinstance(func, LLVMFuncOp):
                continue
            
            for op in list(func.walk()):
                if isinstance(op, ParLoopOp):
                    self.lower_par_loop(op)
    
    def lower_par_loop(self, par_loop: ParLoopOp):
        """Lower a single ops.par_loop operation"""
        
        builder = Builder(InsertPoint.before(par_loop))
        
        # block_info = self.extract_block_info(builder, par_loop.block) 
        # dim_info = self.extract_dim_info(builder, par_loop.dim)
        # range_info = self.extract_range_info(builder, par_loop.range_ptr, dim_info)

        args_info = []
        for ops_arg in par_loop.args:
            # extract data from each arg_dat

            dat = self.extract_arg_dat(builder, ops_arg)
            access = self.extract_arg_access(builder, ops_arg)

            args_info.append(dat)

            self.extract_arg_dat_data(builder, dat)
            self.extract_arg_dat_size(builder, dat)

        # detach par_loop body to use in ops.compute
        body = par_loop.detach_region(par_loop.body)

        compute_op = builder.insert(ComputeOp.create(
            operands=[*args_info],
            regions=[body]
        ))

        par_loop.detach()
        par_loop.erase()
    
    def extract_block_info(self, builder, block_struct):
        """
        Extract info from ops_block
        Returns: extracted values you need from the block
        """

        return builder.insert(ExtractBlockOp.create(
            operands=[block_struct],
            result_types=[IntegerType(32)]
        ))
    
    def extract_dim_info(self, builder, dim_value):
        """
        Extract dimension info
        """
        op = builder.insert(ExtractDimOp.create(
            operands=[dim_value],
            result_types=[IntegerType(32)],
        ))

        op.result.name_hint = "dim"
        return op
    
    def extract_range_info(self, builder, range_ptr, dim_info):
        """
        Extract iteration range
        """
        op = builder.insert(ExtractRangeOp.create(
            operands=[range_ptr, dim_info.results[0]],
            result_types=[IntegerType(32)]
        ))

        op.result.name_hint = "range"
        return op.results
    
    def extract_arg_dat(self, builder, ops_arg_struct):
        """
        Extract arg_dat from ops_arg
        """
        op = builder.insert(ExtractArgDatOp.create(
            operands=[ops_arg_struct],
            result_types=[ops_types.ops_dat_type]
        ))

        op.result.name_hint = "dat"
        return op.result
    
    def extract_arg_dat_data(self, builder, ops_dat_struct):
        """
        Extract data from ops_arg_dat
        """
        op = builder.insert(ExtractArgDatDataOp.create(
            operands=[ops_dat_struct],
            result_types=[LLVMPointerType()]
        ))

        op.result.name_hint = "data"
        return op.results
    

    def extract_arg_dat_size(self, builder, ops_dat_struct):
        """
        Extract size from ops_arg_dat
        """
        op = builder.insert(ExtractArgDatSizeOp.create(
            operands=[ops_dat_struct],
            result_types=[LLVMArrayType.from_size_and_type(
            ops_types.OPS_MAX_DIM, i32)]
        ))

        op.result.name_hint = "size"
        return op.results

    def extract_arg_access(self, builder, ops_arg_struct):
        """
        Extract arg_access from ops_arg
        """
        op = builder.insert(ExtractArgAccessOp.create(
            operands=[ops_arg_struct],
            result_types=[i32]
        ))

        op.result.name_hint = "access_type"
        return op.result
