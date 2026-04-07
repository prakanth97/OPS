// Convert to openMP

module {
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
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %cst = arith.constant 3.141590e+00 : f64
    %c-1 = arith.constant -1 : index
    %0 = llvm.mlir.constant(1 : i64) : i64
    %c7 = arith.constant 7 : index
    %c1 = arith.constant 1 : index
    %cst_0 = arith.constant -1.7976931348623157E+308 : f64
    %1 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %c1_i64 = arith.constant 1 : i64
    %c8_i64 = arith.constant 8 : i64
    %c0_i64 = arith.constant 0 : i64
    %2 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %4 = llvm.getelementptr %3[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %5 = llvm.load %4 : !llvm.ptr -> !llvm.ptr
    %6 = llvm.insertvalue %5, %1[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %5, %6[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %c0_i64, %7[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %c8_i64, %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %c8_i64, %9[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %c8_i64, %10[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
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
    %22 = llvm.insertvalue %c8_i64, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %c8_i64, %22[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %c1_i64, %23[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = builtin.unrealized_conversion_cast %24 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %26 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %27 = llvm.load %26 : !llvm.ptr -> !llvm.ptr
    %28 = llvm.getelementptr %27[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %29 = llvm.load %28 : !llvm.ptr -> !llvm.ptr
    %30 = llvm.alloca %0 x f64 : (i64) -> !llvm.ptr
    llvm.store %cst_0, %30 : f64, !llvm.ptr
    omp.parallel {
      omp.wsloop reduction(@__scf_reduction %30 -> %arg8 : !llvm.ptr) {
        omp.loop_nest (%arg9, %arg10) : index = (%c1, %c1) to (%c7, %c7) step (%c1, %c1) collapse(2) {
          %32 = arith.addi %arg9, %c1 : index
          %33 = memref.load %13[%32, %arg10] : memref<8x8xf64>
          %34 = arith.addi %arg9, %c-1 : index
          %35 = memref.load %13[%34, %arg10] : memref<8x8xf64>
          %36 = memref.load %25[%arg9, %arg10] : memref<8x8xf64>
          %37 = memref.load %13[%arg9, %arg10] : memref<8x8xf64>
          %38 = arith.addf %33, %35 : f64
          %39 = arith.index_cast %arg9 : index to i32
          %40 = arith.sitofp %39 : i32 to f64
          %41 = arith.mulf %40, %cst : f64
          %42 = arith.addf %38, %41 : f64
          %43 = arith.subf %36, %37 : f64
          %44 = math.absf %43 : f64
          memref.store %42, %25[%arg9, %arg10] : memref<8x8xf64>
          %45 = llvm.load %arg8 : !llvm.ptr -> f64
          %46 = arith.cmpf ogt, %45, %44 : f64
          %47 = arith.select %46, %45, %44 : f64
          llvm.store %47, %arg8 : f64, !llvm.ptr
          omp.yield
        }
      }
      omp.terminator
    }
    %31 = llvm.load %30 : !llvm.ptr -> f64
    llvm.store %31, %29 : f64, !llvm.ptr
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    llvm.call @ops_par_loop_demo_kernel_0_impl(%arg0, %arg1, %0, %arg3, %arg4, %arg5, %arg6, %arg7) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// Convert to LLVM
module {
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
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.mlir.constant(8 : index) : i64
    %1 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %2 = llvm.mlir.constant(-1 : index) : i64
    %3 = llvm.mlir.constant(1 : i64) : i64
    %4 = llvm.mlir.constant(7 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    %7 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %8 = llvm.extractvalue %7[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %9 = llvm.getelementptr %8[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %10 = llvm.load %9 : !llvm.ptr -> !llvm.ptr
    %11 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %12 = llvm.extractvalue %11[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %13 = llvm.getelementptr %12[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %14 = llvm.load %13 : !llvm.ptr -> !llvm.ptr
    %15 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %16 = llvm.load %15 : !llvm.ptr -> !llvm.ptr
    %17 = llvm.getelementptr %16[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %18 = llvm.load %17 : !llvm.ptr -> !llvm.ptr
    %19 = llvm.alloca %3 x f64 : (i64) -> !llvm.ptr
    llvm.store %6, %19 : f64, !llvm.ptr
    omp.parallel {
      omp.wsloop reduction(@__scf_reduction %19 -> %arg8 : !llvm.ptr) {
        omp.loop_nest (%arg9, %arg10) : i64 = (%5, %5) to (%4, %4) step (%5, %5) collapse(2) {
          %21 = llvm.add %arg9, %5 : i64
          %22 = llvm.mul %21, %0 overflow<nsw, nuw> : i64
          %23 = llvm.add %22, %arg10 overflow<nsw, nuw> : i64
          %24 = llvm.getelementptr inbounds|nuw %10[%23] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %25 = llvm.load %24 : !llvm.ptr -> f64
          %26 = llvm.add %arg9, %2 : i64
          %27 = llvm.mul %26, %0 overflow<nsw, nuw> : i64
          %28 = llvm.add %27, %arg10 overflow<nsw, nuw> : i64
          %29 = llvm.getelementptr inbounds|nuw %10[%28] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %30 = llvm.load %29 : !llvm.ptr -> f64
          %31 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %32 = llvm.add %31, %arg10 overflow<nsw, nuw> : i64
          %33 = llvm.getelementptr inbounds|nuw %14[%32] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %34 = llvm.load %33 : !llvm.ptr -> f64
          %35 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %36 = llvm.add %35, %arg10 overflow<nsw, nuw> : i64
          %37 = llvm.getelementptr inbounds|nuw %10[%36] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %38 = llvm.load %37 : !llvm.ptr -> f64
          %39 = llvm.fadd %25, %30 : f64
          %40 = llvm.trunc %arg9 : i64 to i32
          %41 = llvm.sitofp %40 : i32 to f64
          %42 = llvm.fmul %41, %1 : f64
          %43 = llvm.fadd %39, %42 : f64
          %44 = llvm.fsub %34, %38 : f64
          %45 = llvm.intr.fabs(%44) : (f64) -> f64
          %46 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %47 = llvm.add %46, %arg10 overflow<nsw, nuw> : i64
          %48 = llvm.getelementptr inbounds|nuw %14[%47] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          llvm.store %43, %48 : f64, !llvm.ptr
          %49 = llvm.load %arg8 : !llvm.ptr -> f64
          %50 = llvm.fcmp "ogt" %49, %45 : f64
          %51 = llvm.select %50, %49, %45 : i1, f64
          llvm.store %51, %arg8 : f64, !llvm.ptr
          omp.yield
        }
      }
      omp.terminator
    }
    %20 = llvm.load %19 : !llvm.ptr -> f64
    llvm.store %20, %18 : f64, !llvm.ptr
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    llvm.call @ops_par_loop_demo_kernel_0_impl(%arg0, %arg1, %0, %arg3, %arg4, %arg5, %arg6, %arg7) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// Final


module {
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
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.mlir.constant(8 : index) : i64
    %1 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %2 = llvm.mlir.constant(-1 : index) : i64
    %3 = llvm.mlir.constant(1 : i64) : i64
    %4 = llvm.mlir.constant(7 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    %7 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %8 = llvm.extractvalue %7[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %9 = llvm.getelementptr %8[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %10 = llvm.load %9 : !llvm.ptr -> !llvm.ptr
    %11 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %12 = llvm.extractvalue %11[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %13 = llvm.getelementptr %12[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %14 = llvm.load %13 : !llvm.ptr -> !llvm.ptr
    %15 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %16 = llvm.load %15 : !llvm.ptr -> !llvm.ptr
    %17 = llvm.getelementptr %16[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %18 = llvm.load %17 : !llvm.ptr -> !llvm.ptr
    %19 = llvm.alloca %3 x f64 : (i64) -> !llvm.ptr
    llvm.store %6, %19 : f64, !llvm.ptr
    omp.parallel {
      omp.wsloop reduction(@__scf_reduction %19 -> %arg8 : !llvm.ptr) {
        omp.loop_nest (%arg9, %arg10) : i64 = (%5, %5) to (%4, %4) step (%5, %5) collapse(2) {
          %21 = llvm.add %arg9, %5 : i64
          %22 = llvm.mul %21, %0 overflow<nsw, nuw> : i64
          %23 = llvm.add %22, %arg10 overflow<nsw, nuw> : i64
          %24 = llvm.getelementptr inbounds|nuw %10[%23] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %25 = llvm.load %24 : !llvm.ptr -> f64
          %26 = llvm.add %arg9, %2 : i64
          %27 = llvm.mul %26, %0 overflow<nsw, nuw> : i64
          %28 = llvm.add %27, %arg10 overflow<nsw, nuw> : i64
          %29 = llvm.getelementptr inbounds|nuw %10[%28] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %30 = llvm.load %29 : !llvm.ptr -> f64
          %31 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %32 = llvm.add %31, %arg10 overflow<nsw, nuw> : i64
          %33 = llvm.getelementptr inbounds|nuw %14[%32] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %34 = llvm.load %33 : !llvm.ptr -> f64
          %35 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %36 = llvm.add %35, %arg10 overflow<nsw, nuw> : i64
          %37 = llvm.getelementptr inbounds|nuw %10[%36] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %38 = llvm.load %37 : !llvm.ptr -> f64
          %39 = llvm.fadd %25, %30 : f64
          %40 = llvm.trunc %arg9 : i64 to i32
          %41 = llvm.sitofp %40 : i32 to f64
          %42 = llvm.fmul %41, %1 : f64
          %43 = llvm.fadd %39, %42 : f64
          %44 = llvm.fsub %34, %38 : f64
          %45 = llvm.intr.fabs(%44) : (f64) -> f64
          %46 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %47 = llvm.add %46, %arg10 overflow<nsw, nuw> : i64
          %48 = llvm.getelementptr inbounds|nuw %14[%47] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          llvm.store %43, %48 : f64, !llvm.ptr
          %49 = llvm.load %arg8 : !llvm.ptr -> f64
          %50 = llvm.fcmp "ogt" %49, %45 : f64
          %51 = llvm.select %50, %49, %45 : i1, f64
          llvm.store %51, %arg8 : f64, !llvm.ptr
          omp.yield
        }
      }
      omp.terminator
    }
    %20 = llvm.load %19 : !llvm.ptr -> f64
    llvm.store %20, %18 : f64, !llvm.ptr
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    llvm.call @ops_par_loop_demo_kernel_0_impl(%arg0, %arg1, %0, %arg3, %arg4, %arg5, %arg6, %arg7) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// FINAL IR before compilation

module {
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
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.mlir.constant(8 : index) : i64
    %1 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %2 = llvm.mlir.constant(-1 : index) : i64
    %3 = llvm.mlir.constant(1 : i64) : i64
    %4 = llvm.mlir.constant(7 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    %7 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %8 = llvm.extractvalue %7[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %9 = llvm.getelementptr %8[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %10 = llvm.load %9 : !llvm.ptr -> !llvm.ptr
    %11 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %12 = llvm.extractvalue %11[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %13 = llvm.getelementptr %12[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %14 = llvm.load %13 : !llvm.ptr -> !llvm.ptr
    %15 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %16 = llvm.load %15 : !llvm.ptr -> !llvm.ptr
    %17 = llvm.getelementptr %16[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %18 = llvm.load %17 : !llvm.ptr -> !llvm.ptr
    %19 = llvm.alloca %3 x f64 : (i64) -> !llvm.ptr
    llvm.store %6, %19 : f64, !llvm.ptr
    omp.parallel {
      omp.wsloop reduction(@__scf_reduction %19 -> %arg8 : !llvm.ptr) {
        omp.loop_nest (%arg9, %arg10) : i64 = (%5, %5) to (%4, %4) step (%5, %5) collapse(2) {
          %21 = llvm.add %arg9, %5 : i64
          %22 = llvm.mul %21, %0 overflow<nsw, nuw> : i64
          %23 = llvm.add %22, %arg10 overflow<nsw, nuw> : i64
          %24 = llvm.getelementptr inbounds|nuw %10[%23] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %25 = llvm.load %24 : !llvm.ptr -> f64
          %26 = llvm.add %arg9, %2 : i64
          %27 = llvm.mul %26, %0 overflow<nsw, nuw> : i64
          %28 = llvm.add %27, %arg10 overflow<nsw, nuw> : i64
          %29 = llvm.getelementptr inbounds|nuw %10[%28] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %30 = llvm.load %29 : !llvm.ptr -> f64
          %31 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %32 = llvm.add %31, %arg10 overflow<nsw, nuw> : i64
          %33 = llvm.getelementptr inbounds|nuw %14[%32] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %34 = llvm.load %33 : !llvm.ptr -> f64
          %35 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %36 = llvm.add %35, %arg10 overflow<nsw, nuw> : i64
          %37 = llvm.getelementptr inbounds|nuw %10[%36] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          %38 = llvm.load %37 : !llvm.ptr -> f64
          %39 = llvm.fadd %25, %30 : f64
          %40 = llvm.trunc %arg9 : i64 to i32
          %41 = llvm.sitofp %40 : i32 to f64
          %42 = llvm.fmul %41, %1 : f64
          %43 = llvm.fadd %39, %42 : f64
          %44 = llvm.fsub %34, %38 : f64
          %45 = llvm.intr.fabs(%44) : (f64) -> f64
          %46 = llvm.mul %arg9, %0 overflow<nsw, nuw> : i64
          %47 = llvm.add %46, %arg10 overflow<nsw, nuw> : i64
          %48 = llvm.getelementptr inbounds|nuw %14[%47] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          llvm.store %43, %48 : f64, !llvm.ptr
          %49 = llvm.load %arg8 : !llvm.ptr -> f64
          %50 = llvm.fcmp "ogt" %49, %45 : f64
          %51 = llvm.select %50, %49, %45 : i1, f64
          llvm.store %51, %arg8 : f64, !llvm.ptr
          omp.yield
        }
      }
      omp.terminator
    }
    %20 = llvm.load %19 : !llvm.ptr -> f64
    llvm.store %20, %18 : f64, !llvm.ptr
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    llvm.call @ops_par_loop_demo_kernel_0_impl(%arg0, %arg1, %0, %arg3, %arg4, %arg5, %arg6, %arg7) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}
