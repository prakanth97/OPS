// NV GPU Lowering


// 1 - create mapping
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr) {
    %arg = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %7 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<
    %data_ptr = "llvm.load"(%7) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %8 = arith.constant 0 : i64
    %9 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %10 = "llvm.insertvalue"(%9, %data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.stru
    %11 = "llvm.insertvalue"(%10, %data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.str
    %12 = "llvm.insertvalue"(%11, %8) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.pt
    %13 = arith.constant 8 : i64
    %14 = arith.constant 8 : i64
    %15 = "llvm.insertvalue"(%12, %13) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llv
    %16 = "llvm.insertvalue"(%15, %14) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llv
    %17 = arith.constant 8 : i64
    %18 = arith.constant 1 : i64
    %19 = "llvm.insertvalue"(%16, %17) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llv
    %20 = "llvm.insertvalue"(%19, %18) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llv
    %data_ref = builtin.unrealized_conversion_cast %20 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field = "memref.cast"(%data_ref) : (memref<8x8xf64>) -> memref<8x8xf64>
    %arg_1 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.pt
    %21 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.arr
    %data_ptr_1 = "llvm.load"(%21) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %22 = arith.constant 0 : i64
    %23 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %24 = "llvm.insertvalue"(%23, %data_ptr_1) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.s
    %25 = "llvm.insertvalue"(%24, %data_ptr_1) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.s
    %26 = "llvm.insertvalue"(%25, %22) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.p
    %27 = arith.constant 8 : i64
    %28 = arith.constant 8 : i64
    %29 = "llvm.insertvalue"(%26, %27) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llv
    %30 = "llvm.insertvalue"(%29, %28) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llv
    %31 = arith.constant 8 : i64
    %32 = arith.constant 1 : i64
    %33 = "llvm.insertvalue"(%30, %31) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %34 = "llvm.insertvalue"(%33, %32) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref_1 = builtin.unrealized_conversion_cast %34 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field_1 = "memref.cast"(%data_ref_1) : (memref<8x8xf64>) -> memref<8x8xf64>
    func.call @ops_par_loop_demo_kernel_0_impl(%data_field, %data_field_1) : (memref<8x8xf64>, memref<8x8xf64>) -> ()
    %35 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%ops_arg0: memref<8x8xf64>, %ops_arg1: memref<8x8xf64>) {
    %0 = memref.subview %ops_arg1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %1 = memref.subview %ops_arg0[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %2 = arith.constant 1 : index
    %3 = arith.constant 1 : index
    %4 = arith.constant 1 : index
    %5 = arith.constant 1 : index
    %6 = arith.constant 7 : index
    %7 = arith.constant 7 : index
    "scf.parallel"(%2, %3, %6, %7, %4, %5) <{operandSegmentSizes = array<i32: 2, 2, 2, 0>}> ({
    ^bb0(%8: index, %9: index):
      %10 = arith.constant 1 : index
      %11 = arith.addi %8, %10 : index
      %12 = memref.load %1[%11, %9] : memref<8x8xf64, strided<[8, 1]>>
      %13 = arith.constant -1 : index
      %14 = arith.addi %8, %13 : index
      %15 = memref.load %1[%14, %9] : memref<8x8xf64, strided<[8, 1]>>
      %16 = arith.addf %12, %15 : f64
      %17 = arith.index_cast %8 : index to i32
      %18 = arith.constant 3.141590e+00 : f64
      %19 = arith.sitofp %17 : i32 to f64
      %20 = arith.mulf %19, %18 : f64
      %21 = arith.addf %16, %20 : f64
      memref.store %21, %0[%8, %9] : memref<8x8xf64, strided<[8, 1]>>
      scf.reduce
    }) {mapping = [#gpu.loop_dim_map<processor = block_y, map = (d0) -> (d0), bound = (d0) -> (d0)>, #gpu.loop_dim_map<processor = block_x, map = (d0) -> (d0), bound = (d0) -> (d0)>]} : (index, index, index, index, index, index) -> ()
    func.return
  }
}


// 2 - lower to gpu (this uses an unused reduction)

#map = affine_map<(d0)[s0, s1] -> ((d0 - s0) ceildiv s1)>
#map1 = affine_map<(d0)[s0, s1] -> (d0 * s0 + s1)>
module {
  func.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %2 = llvm.getelementptr %1[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>,
    %3 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %c0_i64 = arith.constant 0 : i64
    %4 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %5 = llvm.insertvalue %3, %4[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %6 = llvm.insertvalue %3, %5[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %7 = llvm.insertvalue %c0_i64, %6[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %c8_i64 = arith.constant 8 : i64
    %c8_i64_0 = arith.constant 8 : i64
    %8 = llvm.insertvalue %c8_i64, %7[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %c8_i64_0, %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %c8_i64_1 = arith.constant 8 : i64
    %c1_i64 = arith.constant 1 : i64
    %10 = llvm.insertvalue %c8_i64_1, %9[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %11 = llvm.insertvalue %c1_i64, %10[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %12 = builtin.unrealized_conversion_cast %11 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %cast = memref.cast %12 : memref<8x8xf64> to memref<8x8xf64>
    %13 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %14 = llvm.extractvalue %13[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %15 = llvm.getelementptr %14[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>
    %16 = llvm.load %15 : !llvm.ptr -> !llvm.ptr
    %c0_i64_2 = arith.constant 0 : i64
    %17 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %18 = llvm.insertvalue %16, %17[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %19 = llvm.insertvalue %16, %18[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %20 = llvm.insertvalue %c0_i64_2, %19[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %c8_i64_3 = arith.constant 8 : i64
    %c8_i64_4 = arith.constant 8 : i64
    %21 = llvm.insertvalue %c8_i64_3, %20[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %22 = llvm.insertvalue %c8_i64_4, %21[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %c8_i64_5 = arith.constant 8 : i64
    %c1_i64_6 = arith.constant 1 : i64
    %23 = llvm.insertvalue %c8_i64_5, %22[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %24 = llvm.insertvalue %c1_i64_6, %23[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %25 = builtin.unrealized_conversion_cast %24 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %cast_7 = memref.cast %25 : memref<8x8xf64> to memref<8x8xf64>
    %26 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %27 = llvm.load %26 : !llvm.ptr -> !llvm.ptr
    %28 = llvm.getelementptr %27[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %29 = llvm.load %28 : !llvm.ptr -> !llvm.ptr
    %c0_i64_8 = arith.constant 0 : i64
    %30 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %31 = llvm.insertvalue %29, %30[0] : !llvm.struct<(ptr, ptr, i64)>
    %32 = llvm.insertvalue %29, %31[1] : !llvm.struct<(ptr, ptr, i64)>
    %33 = llvm.insertvalue %c0_i64_8, %32[2] : !llvm.struct<(ptr, ptr, i64)>
    %34 = builtin.unrealized_conversion_cast %33 : !llvm.struct<(ptr, ptr, i64)> to memref<f64>
    call @ops_par_loop_demo_kernel_0_impl(%cast, %cast_7, %34) : (memref<8x8xf64>, memref<8x8xf64>, memref<f64>) -> ()
    %35 = llvm.load %arg2 : !llvm.ptr -> i32
    return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%arg0: memref<8x8xf64>, %arg1: memref<8x8xf64>, %arg2: memref<f64>) {
    %subview = memref.subview %arg1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %subview_0 = memref.subview %arg0[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %subview_1 = memref.subview %arg1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %cst = arith.constant -1.7976931348623157E+308 : f64
    %c1 = arith.constant 1 : index
    %c1_2 = arith.constant 1 : index
    %c1_3 = arith.constant 1 : index
    %c1_4 = arith.constant 1 : index
    %c7 = arith.constant 7 : index
    %c7_5 = arith.constant 7 : index
    %c1_6 = arith.constant 1 : index
    %0 = affine.apply #map(%c7)[%c1, %c1_3]
    %1 = affine.apply #map(%c7_5)[%c1_2, %c1_4]
    gpu.launch blocks(%arg3, %arg4, %arg5) in (%arg9 = %1, %arg10 = %0, %arg11 = %c1_6) threads(%arg6, %arg7, %arg8) in (%arg12 = %c1_6, %arg13 = %c1_6, %arg14 = %c1_6) {
      %2 = affine.apply #map1(%arg4)[%c1_3, %c1]
      %3 = affine.apply #map1(%arg3)[%c1_4, %c1_2]
      %c1_7 = arith.constant 1 : index
      %4 = arith.addi %2, %c1_7 : index
      %5 = memref.load %subview_0[%4, %3] : memref<8x8xf64, strided<[8, 1]>>
      %c-1 = arith.constant -1 : index
      %6 = arith.addi %2, %c-1 : index
      %7 = memref.load %subview_0[%6, %3] : memref<8x8xf64, strided<[8, 1]>>
      %8 = memref.load %subview_1[%2, %3] : memref<8x8xf64, strided<[8, 1]>>
      %9 = memref.load %subview_0[%2, %3] : memref<8x8xf64, strided<[8, 1]>>
      %10 = arith.addf %5, %7 : f64
      %11 = arith.index_cast %2 : index to i32
      %cst_8 = arith.constant 3.141590e+00 : f64
      %12 = arith.sitofp %11 : i32 to f64
      %13 = arith.mulf %12, %cst_8 : f64
      %14 = arith.addf %10, %13 : f64
      %15 = arith.subf %8, %9 : f64
      %16 = math.absf %15 : f64
      memref.store %14, %subview[%2, %3] : memref<8x8xf64, strided<[8, 1]>>
      %17 = gpu.all_reduce  %16 {
      ^bb0(%arg15: f64, %arg16: f64):
        %18 = arith.cmpf ogt, %arg15, %arg16 : f64
        %19 = arith.select %18, %arg15, %arg16 : f64
        gpu.yield %19 : f64
      } : (f64) -> f64
      gpu.terminator
    } {SCFToGPU_visited}
    return
  }
}

// 3 - after kernel outlining
#map = affine_map<()[s0] -> (s0 + 1)>
module attributes {gpu.container_module} {
  func.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr) {
    %c1_i64 = arith.constant 1 : i64
    %c8_i64 = arith.constant 8 : i64
    %0 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %c0_i64 = arith.constant 0 : i64
    %1 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %2 = llvm.extractvalue %1[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %3 = llvm.getelementptr %2[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %4 = llvm.load %3 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.insertvalue %4, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %4, %5[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %c0_i64, %6[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %c8_i64, %7[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %c8_i64, %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %c8_i64, %9[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %c1_i64, %10[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = builtin.unrealized_conversion_cast %11 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %13 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %14 = llvm.extractvalue %13[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %15 = llvm.getelementptr %14[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %16 = llvm.load %15 : !llvm.ptr -> !llvm.ptr
    %17 = llvm.insertvalue %16, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %16, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %c0_i64, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %c8_i64, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %c8_i64, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %c8_i64, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %c1_i64, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = builtin.unrealized_conversion_cast %23 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    call @ops_par_loop_demo_kernel_0_impl(%12, %24) : (memref<8x8xf64>, memref<8x8xf64>) -> ()
    return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%arg0: memref<8x8xf64>, %arg1: memref<8x8xf64>) {
    %cst = arith.constant 3.141590e+00 : f64
    %c-1 = arith.constant -1 : index
    %c1 = arith.constant 1 : index
    %c6 = arith.constant 6 : index
    gpu.launch_func  @ops_par_loop_demo_kernel_0_impl_kernel::@ops_par_loop_demo_kernel_0_impl_kernel blocks in (%c6, %c6, %c1) threads in (%c1, %c1, %c1)  args(%c1 : index, %arg0 : memref<8x8xf64>, %c-1 : index, %cst : f64, %arg1 : memref<8x8xf64>)
    return
  }
  gpu.module @ops_par_loop_demo_kernel_0_impl_kernel {
    gpu.func @ops_par_loop_demo_kernel_0_impl_kernel(%arg0: index, %arg1: memref<8x8xf64>, %arg2: index, %arg3: f64, %arg4: memref<8x8xf64>) kernel attributes {known_block_size = array<i32: 1, 1, 1>, known_grid_size = array<i32: 6, 6, 1>} {
      %block_id_x = gpu.block_id  x
      %block_id_y = gpu.block_id  y
      %block_id_z = gpu.block_id  z
      %thread_id_x = gpu.thread_id  x
      %thread_id_y = gpu.thread_id  y
      %thread_id_z = gpu.thread_id  z
      %grid_dim_x = gpu.grid_dim  x
      %grid_dim_y = gpu.grid_dim  y
      %grid_dim_z = gpu.grid_dim  z
      %block_dim_x = gpu.block_dim  x
      %block_dim_y = gpu.block_dim  y
      %block_dim_z = gpu.block_dim  z
      %0 = affine.apply #map()[%block_id_y]
      %1 = affine.apply #map()[%block_id_x]
      %2 = arith.addi %0, %arg0 : index
      %3 = memref.load %arg1[%2, %1] : memref<8x8xf64>
      %4 = arith.addi %0, %arg2 : index
      %5 = memref.load %arg1[%4, %1] : memref<8x8xf64>
      %6 = arith.addf %3, %5 : f64
      %7 = arith.index_cast %0 : index to i32
      %8 = arith.sitofp %7 : i32 to f64
      %9 = arith.mulf %8, %arg3 : f64
      %10 = arith.addf %6, %9 : f64
      memref.store %10, %arg4[%0, %1] : memref<8x8xf64>
      gpu.return
    }
  }
}

// 4 - nvvm attach target
module attributes {gpu.container_module} {
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr) {
    %0 = llvm.mlir.constant(1 : i64) : i64
    %1 = llvm.mlir.constant(8 : i64) : i64
    %2 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %3 = llvm.mlir.constant(0 : i64) : i64
    %4 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %6 = llvm.getelementptr %5[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %7 = llvm.load %6 : !llvm.ptr -> !llvm.ptr
    %8 = llvm.insertvalue %7, %2[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %7, %8[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %3, %9[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %1, %10[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %1, %11[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %1, %12[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %0, %13[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = builtin.unrealized_conversion_cast %14 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %16 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %17 = llvm.extractvalue %16[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %18 = llvm.getelementptr %17[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %19 = llvm.load %18 : !llvm.ptr -> !llvm.ptr
    %20 = llvm.insertvalue %19, %2[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %19, %20[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %3, %21[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %1, %22[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %1, %23[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = llvm.insertvalue %1, %24[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %26 = llvm.insertvalue %0, %25[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = builtin.unrealized_conversion_cast %26 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %28 = llvm.extractvalue %14[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.extractvalue %26[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.call @ops_par_loop_demo_kernel_0_impl(%28, %29) : (!llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr) {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg1, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.mlir.constant(0 : index) : i64
    %4 = llvm.insertvalue %3, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.mlir.constant(8 : index) : i64
    %6 = llvm.insertvalue %5, %4[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.mlir.constant(8 : index) : i64
    %8 = llvm.insertvalue %7, %6[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.mlir.constant(8 : index) : i64
    %10 = llvm.insertvalue %9, %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.mlir.constant(1 : index) : i64
    %12 = llvm.insertvalue %11, %10[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = builtin.unrealized_conversion_cast %12 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %15 = llvm.insertvalue %arg0, %14[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.insertvalue %arg0, %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.mlir.constant(8 : index) : i64
    %20 = llvm.insertvalue %19, %18[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.mlir.constant(8 : index) : i64
    %22 = llvm.insertvalue %21, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.mlir.constant(8 : index) : i64
    %24 = llvm.insertvalue %23, %22[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = llvm.mlir.constant(1 : index) : i64
    %26 = llvm.insertvalue %25, %24[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = builtin.unrealized_conversion_cast %26 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %28 = llvm.mlir.constant(6 : index) : i64
    %29 = llvm.mlir.constant(1 : index) : i64
    %30 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %31 = llvm.mlir.constant(-1 : index) : i64
    %32 = builtin.unrealized_conversion_cast %31 : i64 to index
    %33 = builtin.unrealized_conversion_cast %29 : i64 to index
    %34 = builtin.unrealized_conversion_cast %28 : i64 to index
    %35 = gpu.wait async
    %36 = gpu.launch_func async [%35] @ops_par_loop_demo_kernel_0_impl_kernel::@ops_par_loop_demo_kernel_0_impl_kernel blocks in (%34, %34, %33) threads in (%33, %33, %33)  args(%33 : index, %27 : memref<8x8xf64>, %32 : index, %30 : f64, %13 : memref<8x8xf64>)
    gpu.wait [%36]
    llvm.return
  }
  gpu.module @ops_par_loop_demo_kernel_0_impl_kernel [#nvvm.target<O = 3, chip = "sm_89,triple=nvptx64-nvidia-cuda", flags = {fast, ftz}>] {
    gpu.func @ops_par_loop_demo_kernel_0_impl_kernel(%arg0: index, %arg1: memref<8x8xf64>, %arg2: index, %arg3: f64, %arg4: memref<8x8xf64>) kernel attributes {known_block_size = array<i32: 1, 1, 1>, known_grid_size = array<i32: 6, 6, 1>} {
      %0 = llvm.mlir.constant(1 : index) : i64
      %1 = builtin.unrealized_conversion_cast %arg2 : index to i64
      %2 = builtin.unrealized_conversion_cast %arg0 : index to i64
      %block_id_x = gpu.block_id  x
      %3 = builtin.unrealized_conversion_cast %block_id_x : index to i64
      %block_id_y = gpu.block_id  y
      %4 = builtin.unrealized_conversion_cast %block_id_y : index to i64
      %5 = llvm.add %4, %0 : i64
      %6 = builtin.unrealized_conversion_cast %5 : i64 to index
      %7 = llvm.add %3, %0 : i64
      %8 = builtin.unrealized_conversion_cast %7 : i64 to index
      %9 = llvm.add %5, %2 : i64
      %10 = builtin.unrealized_conversion_cast %9 : i64 to index
      %11 = memref.load %arg1[%10, %8] : memref<8x8xf64>
      %12 = llvm.add %5, %1 : i64
      %13 = builtin.unrealized_conversion_cast %12 : i64 to index
      %14 = memref.load %arg1[%13, %8] : memref<8x8xf64>
      %15 = llvm.fadd %11, %14 : f64
      %16 = llvm.trunc %5 : i64 to i32
      %17 = llvm.sitofp %16 : i32 to f64
      %18 = llvm.fmul %17, %arg3 : f64
      %19 = llvm.fadd %15, %18 : f64
      memref.store %19, %arg4[%6, %8] : memref<8x8xf64>
      gpu.return
    }
  }
}

// 5 - convert-gpu-to-nvvm
module attributes {gpu.container_module} {
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr) {
    %0 = llvm.mlir.constant(1 : i64) : i64
    %1 = llvm.mlir.constant(8 : i64) : i64
    %2 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %3 = llvm.mlir.constant(0 : i64) : i64
    %4 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %6 = llvm.getelementptr %5[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %7 = llvm.load %6 : !llvm.ptr -> !llvm.ptr
    %8 = llvm.insertvalue %7, %2[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %7, %8[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %3, %9[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %1, %10[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %1, %11[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %1, %12[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %0, %13[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = builtin.unrealized_conversion_cast %14 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %16 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %17 = llvm.extractvalue %16[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %18 = llvm.getelementptr %17[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %19 = llvm.load %18 : !llvm.ptr -> !llvm.ptr
    %20 = llvm.insertvalue %19, %2[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %19, %20[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %3, %21[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %1, %22[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %1, %23[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = llvm.insertvalue %1, %24[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %26 = llvm.insertvalue %0, %25[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = builtin.unrealized_conversion_cast %26 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %28 = llvm.extractvalue %14[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.extractvalue %26[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.call @ops_par_loop_demo_kernel_0_impl(%28, %29) : (!llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr) {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg1, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.mlir.constant(0 : index) : i64
    %4 = llvm.insertvalue %3, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.mlir.constant(8 : index) : i64
    %6 = llvm.insertvalue %5, %4[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.mlir.constant(8 : index) : i64
    %8 = llvm.insertvalue %7, %6[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.mlir.constant(8 : index) : i64
    %10 = llvm.insertvalue %9, %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.mlir.constant(1 : index) : i64
    %12 = llvm.insertvalue %11, %10[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = builtin.unrealized_conversion_cast %12 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %15 = llvm.insertvalue %arg0, %14[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.insertvalue %arg0, %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.mlir.constant(8 : index) : i64
    %20 = llvm.insertvalue %19, %18[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.mlir.constant(8 : index) : i64
    %22 = llvm.insertvalue %21, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.mlir.constant(8 : index) : i64
    %24 = llvm.insertvalue %23, %22[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = llvm.mlir.constant(1 : index) : i64
    %26 = llvm.insertvalue %25, %24[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = builtin.unrealized_conversion_cast %26 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %28 = llvm.mlir.constant(6 : index) : i64
    %29 = llvm.mlir.constant(1 : index) : i64
    %30 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %31 = llvm.mlir.constant(-1 : index) : i64
    %32 = builtin.unrealized_conversion_cast %31 : i64 to index
    %33 = builtin.unrealized_conversion_cast %29 : i64 to index
    %34 = builtin.unrealized_conversion_cast %28 : i64 to index
    %35 = gpu.wait async
    %36 = gpu.launch_func async [%35] @ops_par_loop_demo_kernel_0_impl_kernel::@ops_par_loop_demo_kernel_0_impl_kernel blocks in (%34, %34, %33) threads in (%33, %33, %33)  args(%33 : index, %27 : memref<8x8xf64>, %32 : index, %30 : f64, %13 : memref<8x8xf64>)
    gpu.wait [%36]
    llvm.return
  }
  gpu.module @ops_par_loop_demo_kernel_0_impl_kernel [#nvvm.target<O = 3, chip = "sm_89,triple=nvptx64-nvidia-cuda", flags = {fast, ftz}>] {
    llvm.func @ops_par_loop_demo_kernel_0_impl_kernel(%arg0: i64, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: f64, %arg10: !llvm.ptr, %arg11: !llvm.ptr, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 1, 1, 1>, gpu.known_grid_size = array<i32: 6, 6, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 1, 1, 1>} {
      %0 = llvm.mlir.constant(8 : index) : i64
      %1 = llvm.mlir.constant(1 : index) : i64
      %2 = nvvm.read.ptx.sreg.ctaid.x range <i32, 0, 6> : i32
      %3 = llvm.sext %2 : i32 to i64
      %4 = nvvm.read.ptx.sreg.ctaid.y range <i32, 0, 6> : i32
      %5 = llvm.sext %4 : i32 to i64
      %6 = llvm.add %5, %1 : i64
      %7 = llvm.add %3, %1 : i64
      %8 = llvm.add %6, %arg0 : i64
      %9 = llvm.mul %8, %0 overflow<nsw, nuw> : i64
      %10 = llvm.add %9, %7 overflow<nsw, nuw> : i64
      %11 = llvm.getelementptr inbounds|nuw %arg2[%10] : (!llvm.ptr, i64) -> !llvm.ptr, f64
      %12 = llvm.load %11 : !llvm.ptr -> f64
      %13 = llvm.add %6, %arg8 : i64
      %14 = llvm.mul %13, %0 overflow<nsw, nuw> : i64
      %15 = llvm.add %14, %7 overflow<nsw, nuw> : i64
      %16 = llvm.getelementptr inbounds|nuw %arg2[%15] : (!llvm.ptr, i64) -> !llvm.ptr, f64
      %17 = llvm.load %16 : !llvm.ptr -> f64
      %18 = llvm.fadd %12, %17 : f64
      %19 = llvm.trunc %6 : i64 to i32
      %20 = llvm.sitofp %19 : i32 to f64
      %21 = llvm.fmul %20, %arg9 : f64
      %22 = llvm.fadd %18, %21 : f64
      %23 = llvm.mul %6, %0 overflow<nsw, nuw> : i64
      %24 = llvm.add %23, %7 overflow<nsw, nuw> : i64
      %25 = llvm.getelementptr inbounds|nuw %arg11[%24] : (!llvm.ptr, i64) -> !llvm.ptr, f64
      llvm.store %22, %25 : f64, !llvm.ptr
      llvm.return
    }
  }
}
