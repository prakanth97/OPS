module {
  llvm.func @ops_par_loop_set_zero(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>) {
    %0 = llvm.mlir.constant(0.000000e+00 : f64) : f64
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(1 : index) : i64
    %3 = llvm.mlir.constant(0 : index) : i64
    %4 = llvm.extractvalue %arg4[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %5 = llvm.getelementptr %4[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %6 = llvm.load %5 : !llvm.ptr -> !llvm.ptr
    %7 = llvm.getelementptr %6[72] : (!llvm.ptr) -> !llvm.ptr, i8
    omp.parallel {
      omp.wsloop {
        omp.loop_nest (%arg5, %arg6) : i64 = (%3, %3) to (%1, %1) step (%2, %2) collapse(2) {
          %8 = llvm.mul %arg5, %1 overflow<nsw, nuw> : i64
          %9 = llvm.add %8, %arg6 overflow<nsw, nuw> : i64
          %10 = llvm.getelementptr inbounds|nuw %7[%9] : (!llvm.ptr, i64) -> !llvm.ptr, f64
          llvm.store %0, %10 : f64, !llvm.ptr
          omp.yield
        }
      }
      omp.terminator
    }
    llvm.return
  }
  llvm.func @_mlir_ciface_ops_par_loop_set_zero(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    %1 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    llvm.call @ops_par_loop_set_zero(%arg0, %arg1, %0, %arg3, %1) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>) -> ()
    llvm.return
  }
}
