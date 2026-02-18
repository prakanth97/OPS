from xdsl.passes import ModulePass
from xdsl.dialects import llvm, memref, builtin
from xdsl.builder import Builder, InsertPoint
from xdsl.dialects import arith
from xdsl.dialects.builtin import IntegerAttr, i64, DenseArrayBase, IntAttr


class LowerPtrToMemrefPass(ModulePass):
    """
    Lower memref.reinterpret_cast from !llvm.ptr to LLVM memref descriptor
    
    Converts: %m = memref.reinterpret_cast %ptr : !llvm.ptr to memref<8x8xf64>
    To: LLVM struct operations that build the memref descriptor
    """
    
    name = "lower-ptr-to-memref"
    
    def apply(self, ctx, module):
        for op in list(module.walk()):
            if isinstance(op, memref.ReinterpretCastOp):
                # Check if source is llvm.ptr
                if isinstance(op.source.type, llvm.LLVMPointerType):
                    self.lower_ptr_cast(op)
    
    def lower_ptr_cast(self, op: memref.ReinterpretCastOp):
        """Replace ptr→memref cast with descriptor construction"""
        
        builder = Builder(InsertPoint.before(op))
        
        # Get the pointer
        ptr = op.source
        
        # For memref<8x8xf64>, we need descriptor:
        # struct { ptr, ptr, i64, i64, i64, i64, i64 }
        #          ^base ^align ^off ^sz0 ^sz1 ^st0 ^st1
        
        # Create constants
        c0 = builder.insert(arith.ConstantOp(IntegerAttr(0, i64)))
        c8 = builder.insert(arith.ConstantOp(IntegerAttr(8, i64)))
        c1 = builder.insert(arith.ConstantOp(IntegerAttr(1, i64)))
        
        
        # Build descriptor
        # desc_type = llvm.LLVMStructType.from_type_list([
        #     llvm.LLVMPointerType(),  # allocated ptr
        #     llvm.LLVMPointerType(),  # aligned ptr  
        #     i64,                     # offset
        #     i64,                     # size[0]
        #     i64,                     # size[1]
        #     i64,                     # stride[0]
        #     i64,                     # stride[1]
        # ])

        sizes_arr = llvm.LLVMArrayType(IntAttr(2), i64)
        strides_arr = llvm.LLVMArrayType(IntAttr(2), i64)

        desc_type = llvm.LLVMStructType.from_type_list([
            llvm.LLVMPointerType(),  # allocated
            llvm.LLVMPointerType(),  # aligned
            i64,                     # offset
            sizes_arr,               # sizes[rank]
            strides_arr              # strides[rank]
        ])

        
        # Create undef and insert values
        undef = builder.insert(llvm.UndefOp(desc_type))
        
        # desc = undef.results[0]
        # desc = builder.insert(llvm.InsertValueOp(
        #     DenseArrayBase.from_list(i64, [0]), desc, ptr#, desc_type
        # )).results[0]
        # desc = builder.insert(llvm.InsertValueOp(
        #     DenseArrayBase.from_list(i64, [1]), desc, ptr#, desc_type
        # )).results[0]
        # desc = builder.insert(llvm.InsertValueOp(
        #     DenseArrayBase.from_list(i64, [2]), desc, c0.results[0]#, desc_type
        # )).results[0]
        # desc = builder.insert(llvm.InsertValueOp(
        #     DenseArrayBase.from_list(i64, [3]), desc, c8.results[0]#, desc_type
        # )).results[0]
        # desc = builder.insert(llvm.InsertValueOp(
        #     DenseArrayBase.from_list(i64, [4]), desc, c1.results[0]#, desc_type
        # )).results[0]
        # desc = builder.insert(llvm.InsertValueOp(
        #     DenseArrayBase.from_list(i64, [5]), desc, c8.results[0]#, desc_type
        # )).results[0]
        # desc = builder.insert(llvm.InsertValueOp(
        #     DenseArrayBase.from_list(i64, [6]), desc, c1.results[0]#, desc_type
        # )).results[0]

        desc = undef.results[0]

        # allocated
        desc = builder.insert(llvm.InsertValueOp(
            DenseArrayBase.from_list(i64, [0]), desc, ptr)).results[0]

        # aligned
        desc = builder.insert(llvm.InsertValueOp(
            DenseArrayBase.from_list(i64, [1]), desc, ptr)).results[0]

        # offset
        # note: the offset is not applied here, as when the memref is later casted to
        # a stencil.field, the offset is not preserved
        # instead, the offset is applied to the actual base pointer when loading it in
        desc = builder.insert(llvm.InsertValueOp(
            DenseArrayBase.from_list(i64, [2]), desc, c0.results[0])).results[0]

        # sizes
        desc = builder.insert(llvm.InsertValueOp(
            DenseArrayBase.from_list(i64, [3,0]), desc, c8.results[0])).results[0]
        desc = builder.insert(llvm.InsertValueOp(
            DenseArrayBase.from_list(i64, [3,1]), desc, c8.results[0])).results[0]

        # strides
        desc = builder.insert(llvm.InsertValueOp(
            DenseArrayBase.from_list(i64, [4,0]), desc, c8.results[0])).results[0]
        desc = builder.insert(llvm.InsertValueOp(
            DenseArrayBase.from_list(i64, [4,1]), desc, c1.results[0])).results[0]

        
        # Cast descriptor to memref type
        # memref_val = builder.insert(builtin.UnrealizedConversionCastOp(
        #     desc,
        #     result_types=[op.result.type]
        # ))

        memref_val = builder.insert(
            builtin.UnrealizedConversionCastOp(
                operands=[desc],
                result_types=[op.result.type]
            )
        )

        
        # Replace uses
        op.result.replace_by(memref_val.results[0])
        op.detach()
        op.erase()