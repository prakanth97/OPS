// OPENMP Lowering

// omp phase 1

module {
  func.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %c1_i64 = arith.constant 1 : i64
    %c8_i64 = arith.constant 8 : i64
    %1 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %c0_i64 = arith.constant 0 : i64
    %2 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %4 = llvm.getelementptr %3[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %5 = llvm.load %4 : !llvm.ptr -> !llvm.ptr
    %6 = llvm.insertvalue %5, %1[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %5, %6[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %c0_i64, %7[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %c8_i64, %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %c8_i64, %9[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %c8_i64, %10[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %c1_i64, %11[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = builtin.unrealized_conversion_cast %12 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %14 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %15 = llvm.extractvalue %14[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %16 = llvm.getelementptr %15[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %17 = llvm.load %16 : !llvm.ptr -> !llvm.ptr
    %18 = llvm.insertvalue %17, %1[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %17, %18[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %c0_i64, %19[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %c8_i64, %20[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %c8_i64, %21[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %c8_i64, %22[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %c1_i64, %23[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = builtin.unrealized_conversion_cast %24 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %26 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %27 = llvm.load %26 : !llvm.ptr -> !llvm.ptr
    %28 = llvm.getelementptr %27[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %29 = llvm.load %28 : !llvm.ptr -> !llvm.ptr
    %30 = llvm.insertvalue %29, %0[0] : !llvm.struct<(ptr, ptr, i64)> 
    %31 = llvm.insertvalue %29, %30[1] : !llvm.struct<(ptr, ptr, i64)> 
    %32 = llvm.insertvalue %c0_i64, %31[2] : !llvm.struct<(ptr, ptr, i64)> 
    %33 = builtin.unrealized_conversion_cast %32 : !llvm.struct<(ptr, ptr, i64)> to memref<f64>
    call @ops_par_loop_demo_kernel_0_impl(%13, %25, %33) : (memref<8x8xf64>, memref<8x8xf64>, memref<f64>) -> ()
    return
  }
  omp.declare_reduction @__scf_reduction : f64 init {
  ^bb0(%arg0: f64):
    %0 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    omp.yield(%0 : f64)
  } combiner {
  ^bb0(%arg0: f64, %arg1: f64):
    %0 = arith.cmpf ogt, %arg0, %arg1 : f64
    %1 = arith.select %0, %arg0, %arg1 : f64
    omp.yield(%1 : f64)
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%arg0: memref<8x8xf64>, %arg1: memref<8x8xf64>, %arg2: memref<f64>) {
    %cst = arith.constant 3.141590e+00 : f64
    %c-1 = arith.constant -1 : index
    %0 = llvm.mlir.constant(1 : i64) : i64
    %c7 = arith.constant 7 : index
    %c1 = arith.constant 1 : index
    %cst_0 = arith.constant -1.7976931348623157E+308 : f64
    %1 = llvm.alloca %0 x f64 : (i64) -> !llvm.ptr
    llvm.store %cst_0, %1 : f64, !llvm.ptr
    omp.parallel {
      omp.wsloop reduction(@__scf_reduction %1 -> %arg3 : !llvm.ptr) {
        omp.loop_nest (%arg4, %arg5) : index = (%c1, %c1) to (%c7, %c7) step (%c1, %c1) collapse(2) {
          %3 = arith.addi %arg4, %c1 : index
          %4 = memref.load %arg0[%3, %arg5] : memref<8x8xf64>
          %5 = arith.addi %arg4, %c-1 : index
          %6 = memref.load %arg0[%5, %arg5] : memref<8x8xf64>
          %7 = memref.load %arg1[%arg4, %arg5] : memref<8x8xf64>
          %8 = memref.load %arg0[%arg4, %arg5] : memref<8x8xf64>
          %9 = arith.addf %4, %6 : f64
          %10 = arith.index_cast %arg4 : index to i32
          %11 = arith.sitofp %10 : i32 to f64
          %12 = arith.mulf %11, %cst : f64
          %13 = arith.addf %9, %12 : f64
          %14 = arith.subf %7, %8 : f64
          %15 = math.absf %14 : f64
          memref.store %13, %arg1[%arg4, %arg5] : memref<8x8xf64>
          %16 = llvm.load %arg3 : !llvm.ptr -> f64
          %17 = arith.cmpf ogt, %16, %15 : f64
          %18 = arith.select %17, %16, %15 : f64
          llvm.store %18, %arg3 : f64, !llvm.ptr
          omp.yield
        }
      }
      omp.terminator
    }
    %2 = llvm.load %1 : !llvm.ptr -> f64
    memref.store %2, %arg2[] : memref<f64>
    return
  }
}

// phase 2

module {
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.mlir.constant(1 : i64) : i64
    %1 = llvm.mlir.constant(8 : i64) : i64
    %2 = llvm.mlir.constant(0 : i64) : i64
    %3 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %4 = llvm.extractvalue %3[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %5 = llvm.getelementptr %4[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %6 = llvm.load %5 : !llvm.ptr -> !llvm.ptr
    %7 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %8 = llvm.extractvalue %7[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %9 = llvm.getelementptr %8[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %10 = llvm.load %9 : !llvm.ptr -> !llvm.ptr
    %11 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %12 = llvm.load %11 : !llvm.ptr -> !llvm.ptr
    %13 = llvm.getelementptr %12[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %14 = llvm.load %13 : !llvm.ptr -> !llvm.ptr
    llvm.call @ops_par_loop_demo_kernel_0_impl(%6, %6, %2, %1, %1, %1, %0, %10, %10, %2, %1, %1, %1, %0, %14, %14, %2) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64) -> ()
    llvm.return
  }
  omp.declare_reduction @__scf_reduction : f64 init {
  ^bb0(%arg0: f64):
    %0 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    omp.yield(%0 : f64)
  } combiner {
  ^bb0(%arg0: f64, %arg1: f64):
    %0 = llvm.fcmp "ogt" %arg0, %arg1 : f64
    %1 = llvm.select %0, %arg0, %arg1 : i1, f64
    omp.yield(%1 : f64)
  }
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64) {
    %0 = llvm.mlir.constant(8 : index) : i64
    %1 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    %2 = llvm.mlir.constant(1 : index) : i64
    %3 = llvm.mlir.constant(7 : index) : i64
    %4 = llvm.mlir.constant(1 : i64) : i64
    %5 = llvm.mlir.constant(-1 : index) : i64
    %6 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %7 = llvm.alloca %4 x f64 : (i64) -> !llvm.ptr
    llvm.store %1, %7 : f64, !llvm.ptr
    omp.parallel {
      omp.wsloop reduction(@__scf_reduction %7 -> %arg17 : !llvm.ptr) {
        omp.loop_nest (%arg18, %arg19) : i64 = (%2, %2) to (%3, %3) step (%2, %2) collapse(2) {
          %9 = llvm.add %arg18, %2 : i64
          %10 = llvm.mul %9, %0 overflow<nsw, nuw> : i64
          %11 = llvm.add %10, %arg19 overflow<nsw, nuw> : i64
          %12 = llvm.getelementptr inbounds|nuw %arg1[%11] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %13 = llvm.load %12 : !llvm.ptr -> f64
          %14 = llvm.add %arg18, %5 : i64
          %15 = llvm.mul %14, %0 overflow<nsw, nuw> : i64
          %16 = llvm.add %15, %arg19 overflow<nsw, nuw> : i64
          %17 = llvm.getelementptr inbounds|nuw %arg1[%16] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %18 = llvm.load %17 : !llvm.ptr -> f64
          %19 = llvm.mul %arg18, %0 overflow<nsw, nuw> : i64
          %20 = llvm.add %19, %arg19 overflow<nsw, nuw> : i64
          %21 = llvm.getelementptr inbounds|nuw %arg8[%20] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %22 = llvm.load %21 : !llvm.ptr -> f64
          %23 = llvm.mul %arg18, %0 overflow<nsw, nuw> : i64
          %24 = llvm.add %23, %arg19 overflow<nsw, nuw> : i64
          %25 = llvm.getelementptr inbounds|nuw %arg1[%24] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %26 = llvm.load %25 : !llvm.ptr -> f64
          %27 = llvm.fadd %13, %18 : f64
          %28 = llvm.trunc %arg18 : i64 to i32
          %29 = llvm.sitofp %28 : i32 to f64
          %30 = llvm.fmul %29, %6 : f64
          %31 = llvm.fadd %27, %30 : f64
          %32 = llvm.fsub %22, %26 : f64
          %33 = llvm.intr.fabs(%32) : (f64) -> f64
          %34 = llvm.mul %arg18, %0 overflow<nsw, nuw> : i64
          %35 = llvm.add %34, %arg19 overflow<nsw, nuw> : i64
          %36 = llvm.getelementptr inbounds|nuw %arg8[%35] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          llvm.store %31, %36 : f64, !llvm.ptr
          %37 = llvm.load %arg17 : !llvm.ptr -> f64
          %38 = llvm.fcmp "ogt" %37, %33 : f64
          %39 = llvm.select %38, %37, %33 : i1, f64
          llvm.store %39, %arg17 : f64, !llvm.ptr
          omp.yield
        }
      }
      omp.terminator
    }
    %8 = llvm.load %7 : !llvm.ptr -> f64
    llvm.store %8, %arg15 : f64, !llvm.ptr
    llvm.return
  }
}
