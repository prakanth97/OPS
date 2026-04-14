from xdsl.passes import ModulePass
from xdsl.dialects import llvm, memref, builtin
from xdsl.builder import Builder, InsertPoint
from xdsl.dialects import arith
from xdsl.dialects.builtin import IntegerAttr, i64, DenseArrayBase, IntAttr

from .ops_dialect import * 
from kernel_config import KernelConfig

class LowerPtrToMemrefPass(ModulePass):
    """
    Lower memref.reinterpret_cast from !llvm.ptr to LLVM memref descriptor
    
    Converts: %m = memref.reinterpret_cast %ptr : !llvm.ptr to memref<8x8xf64>
    To: LLVM struct operations that build the memref descriptor
    """
    
    name = "lower-ptr-to-memref"

    def __init__(self, config: KernelConfig):
        self.config = config

    
    def apply(self, ctx, module):
        for op in list(module.walk()):
            if isinstance(op, PointerToMemref):
                # Check if source is llvm.ptr
                if isinstance(op.ptr.type, llvm.LLVMPointerType):
                    self.lower_ptr(op)
    
    def lower_ptr(self, op: PointerToMemref):
        builder = Builder(InsertPoint.before(op))
        ptr = op.ptr
        c0 = builder.insert(arith.ConstantOp(IntegerAttr(0, i64)))

        is_reduction = op.is_reduction is not None and op.is_reduction.value.data

        if is_reduction:
            # 0-d memref: descriptor is just (ptr, ptr, i64) - no sizes/strides arrays
            desc_type = llvm.LLVMStructType.from_type_list([
                llvm.LLVMPointerType(),
                llvm.LLVMPointerType(),
                i64,
            ])
            undef = builder.insert(llvm.UndefOp(desc_type))
            desc = undef.results[0]
            desc = builder.insert(llvm.InsertValueOp(
                DenseArrayBase.from_list(i64, [0]), desc, ptr)).results[0]
            desc = builder.insert(llvm.InsertValueOp(
                DenseArrayBase.from_list(i64, [1]), desc, ptr)).results[0]
            desc = builder.insert(llvm.InsertValueOp(
                DenseArrayBase.from_list(i64, [2]), desc, c0.results[0])).results[0]
        else:
            # n-d memref from grid_size
            sizes = [end - start for start, end in self.config.grid_size]
            rank = len(sizes)

            # compute strides (row-major)
            strides = [1] * rank
            for i in range(rank - 2, -1, -1):
                strides[i] = strides[i + 1] * sizes[i + 1]

            sizes_arr = llvm.LLVMArrayType(IntAttr(rank), i64)
            strides_arr = llvm.LLVMArrayType(IntAttr(rank), i64)
            desc_type = llvm.LLVMStructType.from_type_list([
                llvm.LLVMPointerType(),
                llvm.LLVMPointerType(),
                i64,
                sizes_arr,
                strides_arr,
            ])

            undef = builder.insert(llvm.UndefOp(desc_type))
            desc = undef.results[0]
            desc = builder.insert(llvm.InsertValueOp(
                DenseArrayBase.from_list(i64, [0]), desc, ptr)).results[0]
            desc = builder.insert(llvm.InsertValueOp(
                DenseArrayBase.from_list(i64, [1]), desc, ptr)).results[0]
            desc = builder.insert(llvm.InsertValueOp(
                DenseArrayBase.from_list(i64, [2]), desc, c0.results[0])).results[0]

            for i, (size, stride) in enumerate(zip(sizes, strides)):
                c_size = builder.insert(arith.ConstantOp(IntegerAttr(size, i64)))
                c_stride = builder.insert(arith.ConstantOp(IntegerAttr(stride, i64)))
                desc = builder.insert(llvm.InsertValueOp(
                    DenseArrayBase.from_list(i64, [3, i]), desc, c_size.results[0])).results[0]
                desc = builder.insert(llvm.InsertValueOp(
                    DenseArrayBase.from_list(i64, [4, i]), desc, c_stride.results[0])).results[0]

        memref_val = builder.insert(
            builtin.UnrealizedConversionCastOp(
                operands=[desc],
                result_types=[op.result.type]
            )
        )

        op.result.replace_all_uses_with(memref_val.results[0])
        op.detach()
        op.erase()
