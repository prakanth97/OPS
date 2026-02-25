from xdsl.passes import ModulePass
from xdsl.builder import Builder, InsertPoint

from xdsl.dialects.llvm import FuncOp as LLVMFuncOp, LLVMPointerType
from xdsl.dialects.builtin import IntegerType, f64, MemRefType
from xdsl.dialects.stencil import FieldType, StencilBoundsAttr

from xdsl.dialects.func import FuncOp as FuncFuncOp
from .ops_dialect import * 

from .ops_types import *

class LowerParLoopPass(ModulePass):
    """
    Lower ops.par_loop to:
    1. Extraction operations (ops.extract_*)
    2. Memory operations (ops_dat data to memref)
    3. Compute operation (ops.compute)
    
    Input:
        ops.par_loop(%kernel, %block, %dim, %range, %ops_arg1) {
            <kernel computation body for stencil accesses>
        }
    """

    name = "lower-ops-par-loop"
    
    def apply(self, ctx, module):

        for func in module.walk():
            if not isinstance(func, FuncFuncOp) and not isinstance(func, LLVMFuncOp):
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
        for ops_arg_ptr in par_loop.args:
            # extract data from each arg_dat
            # access = self.extract_arg_access(builder, ops_arg)

            ops_arg = self.extract_arg(builder, ops_arg_ptr)

            dat = self.extract_arg_dat(builder, ops_arg)

            # self.extract_arg_dat_size(builder, dat)

            data = self.extract_arg_dat_data(builder, dat)

            data_ref = self.create_ptr_to_ref(builder, data)

            data_field = self.create_ref_to_field(builder, data_ref)

            args_info.append(data_field)
            args_info.append(data_ref)

        # detach par_loop body to use in ops.compute
        body = par_loop.detach_region(par_loop.body)

        builder.insert(ComputeOp.create(
            operands=[*args_info],
            regions=[body]
        ))

        par_loop.detach()
        par_loop.erase()
    
    def extract_block_info(self, builder, block_struct):
        """
        Extract info from ops_block
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
    
    def extract_arg(self, builder, ops_arg_ptr):
        """
        Extract ops_arg from ops_arg*
        """
        op = builder.insert(ExtractArgOp.create(
            operands=[ops_arg_ptr],
            result_types=[ops_arg_type]
        ))

        op.result.name_hint = "arg"
        return op.result

    def extract_arg_dat(self, builder, ops_arg_struct):
        """
        Extract arg_dat from ops_arg
        """
        op = builder.insert(ExtractArgDatOp.create(
            operands=[ops_arg_struct],
            result_types=[ops_dat_type]
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

        op.result.name_hint = "data_ptr"
        return op.result
    

    def extract_arg_dat_size(self, builder, ops_dat_struct):
        """
        Extract size from ops_arg_dat
        """
        op = builder.insert(ExtractArgDatSizeOp.create(
            operands=[ops_dat_struct],
            result_types=[LLVMArrayType.from_size_and_type(
            OPS_MAX_DIM, i32)]
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

    
    def create_ptr_to_ref(self, builder, data_ptr):
        """
        Take the data pointer and put it in a placeholder
        to convert to a memref
        """

        op = builder.insert(PointerToMemref.create(
            operands=[data_ptr],
            result_types=[MemRefType(f64, [8, 1])] 
        ))

        op.result.name_hint = "data_ref"
        return op.result
    

    def create_ref_to_field(self, builder, data_ref):
        """
        Take the data memref and put it in a placeholder
        to convert to a stencil.field
        """

        op = builder.insert(MemrefToStencilField.create(
            operands=[data_ref],
            result_types=[FieldType(StencilBoundsAttr([(0, 8), (0, 8)]), f64)] 
        ))

        op.result.name_hint = "data_field"
        return op.result
