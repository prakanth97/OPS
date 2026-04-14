from xdsl.passes import ModulePass
from xdsl.builder import Builder, InsertPoint

from xdsl.dialects.builtin import i64, DenseArrayBase, MemRefType, f64, IntegerAttr
from xdsl.dialects import stencil, memref

from .ops_dialect import *
from xdsl.dialects.llvm import LLVMPointerType, ExtractValueOp, GEPOp, LoadOp
from xdsl.dialects import arith

from .ops_types import *

class LowerOpsExtractionsPass(ModulePass):
    """Lower ops.extract_* operations to LLVM operations"""
    
    def apply(self, ctx, module):
        for op in list(module.walk()):
            if isinstance(op, ExtractArgOp):
                self.lower_extract_arg(op)
            elif isinstance(op, ExtractArgDatOp):
                self.lower_extract_arg_dat(op)
            elif isinstance(op, ExtractArgDatDataOp):
                self.lower_extract_arg_dat_data(op)
            # elif isinstance(op, PointerToMemref):
            #     self.lower_ptr_to_memref(op)
            elif isinstance(op, MemrefToStencilField):
                self.lower_memref_to_field(op)


    def lower_extract_arg(self, op: ExtractArgOp):
        """
        Lower ops.extract_arg to LLVM load
        
        Before: %arg = ops.extract_arg(%ops_arg)
        After:  %arg = llvm.load ? %ops_arg[0]
        """
        builder = Builder(InsertPoint.before(op))
        
        arg = builder.insert(LoadOp(
            op.operands[0],
            ops_arg_type
        ))
        
        op.results[0].replace_all_uses_with(arg.results[0])
        op.detach()
        op.erase()

    def lower_extract_arg_dat(self, op: ExtractArgDatOp):
        """
        Lower ops.extract_arg_dat to LLVM extractvalue
        
        Before: %dat_ptr = ops.extract_arg_dat(%ops_arg)
        After:  %dat_ptr = llvm.extractvalue %ops_arg[0]
        """
        builder = Builder(InsertPoint.before(op))
        
        # ops_arg field 0 is a pointer to ops_dat (not the struct itself)
        dat_ptr = builder.insert(ExtractValueOp(
            DenseArrayBase.from_list(i64, [0]),
            op.operands[0],  # The ops_arg struct
            LLVMPointerType()
        ))
        
        op.results[0].replace_all_uses_with(dat_ptr.results[0])
        op.detach()
        op.erase()

    def lower_extract_arg_dat_data(self, op: ExtractArgDatDataOp):
        """
        Lower ops.extract_arg_dat_data to LLVM getelementptr + load
        
        Before: %data_ptr = ops.extract_arg_dat_data(%dat_ptr)
        After:  %data_ptr_addr = llvm.getelementptr %dat_ptr[0, 10]
                %data_ptr = llvm.load %data_ptr_addr
                %offset = arith.constant 72
                %adjusted_ptr = llvm.getelementptr %data_ptr[%offset]
        """
        builder = Builder(InsertPoint.before(op))
        
        # Navigate to field 10 (the data pointer) within the ops_dat struct
        data_ptr_addr = builder.insert(GEPOp.from_mixed_indices(
            op.operands[0],  # ops_dat pointer
            indices=[0, 10],  # [0] to dereference, [10] to get field 10
            pointee_type=ops_dat_type,
            result_type=LLVMPointerType()
        ))
        
        # Load the actual data pointer from that address
        data_ptr = builder.insert(LoadOp(
            data_ptr_addr.results[0],
            LLVMPointerType()
        ))
        
        # Add offset to the pointer (72 bytes = 9 doubles for halo offset)
        # TODO: Add base offset to pointer dynamically
        # offset_const = builder.insert(arith.ConstantOp(IntegerAttr(72, i64)))
        
        # adjusted_ptr = builder.insert(GEPOp.from_mixed_indices(
        #     data_ptr.results[0],
        #     indices=[offset_const.results[0]],  # dynamic offset
        #     pointee_type=IntegerType(8),  # i8 for byte-level pointer offset arithmetic
        #     result_type=LLVMPointerType(),
        # ))
        
        op.results[0].replace_all_uses_with(data_ptr.results[0])
        op.detach()
        op.erase()

    # def lower_ptr_to_memref(self, op: PointerToMemref):
        
    #     builder = Builder(InsertPoint.before(op))

    #     # Convert pointer to memref
    #     total_size_0 = 8
    #     total_size_1 = 8

    #     ref_type = MemRefType(f64, [total_size_0, total_size_1])


    #     ref = memref.ReinterpretCastOp(
    #         source=op.operands[0],
    #         result_type=ref_type,
    #         static_offsets=[0],
    #         static_sizes=[8, 8],
    #         static_strides=[8, 1],
    #         offsets=[],
    #         sizes=[],
    #         strides=[]
    #     )

    #     ref.results[0].name_hint = "data_ref"

    #     builder.insert(ref)
 
    #     op.results[0].replace_all_uses_with(ref.results[0])

    #     op.detach()
    #     op.erase()


    def lower_memref_to_field(self, op: MemrefToStencilField):
    
        builder = Builder(InsertPoint.before(op))
        
        cast = stencil.CastOp(
            field=[op.operands[0]],
            bounds= op.result_types[0].bounds,
            res_type=[op.result_types[0]]
        )
        
        builder.insert(cast)
        
        op.results[0].replace_all_uses_with(cast.results[0])
        op.detach()
        op.erase()

