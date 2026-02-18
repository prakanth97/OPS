from xdsl.passes import ModulePass
from xdsl.builder import Builder, InsertPoint

from xdsl.dialects.builtin import i64, DenseArrayBase, MemRefType, f64
from xdsl.dialects import stencil, memref

from ops_dialect import *
from xdsl.dialects.llvm import LLVMPointerType, ExtractValueOp, GEPOp, LoadOp
from xdsl.dialects import ptr

import ops_types

class LowerOpsExtractionsPass(ModulePass):
    """Lower ops.extract_* operations to LLVM operations"""
    
    def apply(self, ctx, module):
        for op in list(module.walk()):
            if isinstance(op, ExtractArgDatOp):
                self.lower_extract_arg_dat(op)
            elif isinstance(op, ExtractArgDatDataOp):
                self.lower_extract_arg_dat_data(op)
            elif isinstance(op, PointerToMemref):
                self.lower_ptr_to_memref(op)
            elif isinstance(op, MemrefToStencilField):
                self.lower_memref_to_field(op)
    
    # def lower_extract_arg_dat(self, op: ExtractArgDatOp):
    #     """
    #     Lower ops.extract_arg_dat to LLVM extractvalue
        
    #     Before: %dat = ops.extract_arg_dat(%ops_arg)
    #     After:  %dat = llvm.extractvalue %ops_arg[0]
    #     """
    #     builder = Builder(InsertPoint.before(op))
        
    #     # ops_arg field 0 is ops_dat (passed by value in the struct)
    #     dat = builder.insert(ExtractValueOp(
    #         DenseArrayBase.from_list(i64, [0]),
    #         op.operands[0],  # The ops_arg struct
    #         op.results[0].type  # Result type (the ops_dat struct)
    #     ))
        
    #     op.results[0].replace_by(dat.results[0])

    #     op.detach()
    #     op.erase()

    def lower_extract_arg_dat(self, op: ExtractArgDatOp):
        """
        Lower ops.extract_arg_dat to LLVM extractvalue
        
        Before: %dat_ptr = ops.extract_arg_dat(%ops_arg)
        After:  %dat_ptr = llvm.extractvalue %ops_arg[0]
        """
        builder = Builder(InsertPoint.before(op))
        
        # ops_arg field 0 is now a pointer to ops_dat (not the struct itself)
        dat_ptr = builder.insert(ExtractValueOp(
            DenseArrayBase.from_list(i64, [0]),
            op.operands[0],  # The ops_arg struct
            LLVMPointerType()  # Result type is now a pointer!
        ))
        
        op.results[0].replace_by(dat_ptr.results[0])
        op.detach()
        op.erase()
        
    def lower_extract_arg_dat_data(self, op: ExtractArgDatDataOp):
        """
        Lower ops.extract_arg_dat_data to LLVM getelementptr + load
        
        Before: %data_ptr = ops.extract_arg_dat_data(%dat_ptr)
        After:  %data_ptr_addr = llvm.getelementptr %dat_ptr[0, 10]
                %data_ptr = llvm.load %data_ptr_addr
        """
        builder = Builder(InsertPoint.before(op))
        
        # Navigate to field 10 (the data pointer) within the ops_dat struct
        data_ptr_addr = builder.insert(GEPOp.from_mixed_indices(
            op.operands[0],  # ops_dat pointer
            indices=[0, 10],  # [0] to dereference, [10] to get field 10
            pointee_type=ops_types.ops_dat_type,  # The struct type being pointed to
            result_type=LLVMPointerType()
        ))
        
        # Load the actual data pointer from that address
        data_ptr = builder.insert(LoadOp(
            data_ptr_addr.results[0],
            LLVMPointerType()
        ))
        
        op.results[0].replace_by(data_ptr.results[0])
        op.detach()
        op.erase()

    def lower_ptr_to_memref(self, op: PointerToMemref):
        
        builder = Builder(InsertPoint.before(op))

        # Convert pointer to memref
        total_size_0 = 8
        total_size_1 = 8

        ref_type = MemRefType(f64, [total_size_0, total_size_1])


        ref = memref.ReinterpretCastOp(
            source=op.operands[0],  # Your !llvm.ptr
            result_type=ref_type,
            # These are attributes, not operands:
            static_offsets=[0],
            static_sizes=[8, 8],
            static_strides=[8, 1],  # Row-major: stride[0] = num_cols, stride[1] = 1
            offsets=[],
            sizes=[],
            strides=[]
        )

        ref.results[0].name_hint = "data_ref"

        builder.insert(ref)
 
        op.results[0].replace_by(ref.results[0])

        op.detach()
        op.erase()


    # def lower_memref_to_field(self, op: MemrefToStencilField):

    #     builder = Builder(InsertPoint.before(op))

    #     external_load = stencil.ExternalLoadOp.get(op.operands[0], op.result_types[0])

    #     builder.insert(external_load)

    #     op.results[0].replace_by(external_load.results[0])
    #     op.detach()
    #     op.erase()

    def lower_memref_to_field(self, op: MemrefToStencilField):
    
        builder = Builder(InsertPoint.before(op))
        
        # Use stencil.cast instead of external_load
        cast = stencil.CastOp(
            operands=[op.operands[0]],
            result_types=[op.result_types[0]]
        )
        
        builder.insert(cast)
        
        op.results[0].replace_by(cast.results[0])
        op.detach()
        op.erase()

