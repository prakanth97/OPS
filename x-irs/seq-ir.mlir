// SEQUENTIAL LOWERING

// FINAL IR
cse
module {
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %2 = llvm.getelementptr %1[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %3 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %4 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %6 = llvm.getelementptr %5[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %7 = llvm.load %6 : !llvm.ptr -> !llvm.ptr
    %8 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %9 = llvm.load %8 : !llvm.ptr -> !llvm.ptr
    %10 = llvm.getelementptr %9[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %11 = llvm.load %10 : !llvm.ptr -> !llvm.ptr
    llvm.call @ops_par_loop_demo_kernel_0_impl(%3, %7, %11) : (!llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr) {
    %0 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    %1 = llvm.mlir.constant(7 : index) : i64
    %2 = llvm.mlir.constant(-1 : index) : i64
    %3 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.constant(8 : index) : i64
    llvm.br ^bb1(%4, %0 : i64, f64)
  ^bb1(%6: i64, %7: f64):  // 2 preds: ^bb0, ^bb5
    %8 = llvm.icmp "slt" %6, %1 : i64
    llvm.cond_br %8, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%4, %7 : i64, f64)
  ^bb3(%9: i64, %10: f64):  // 2 preds: ^bb2, ^bb4
    %11 = llvm.icmp "slt" %9, %1 : i64
    llvm.cond_br %11, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %12 = llvm.add %6, %4 : i64
    %13 = llvm.mul %12, %5 overflow<nsw, nuw> : i64
    %14 = llvm.add %13, %9 overflow<nsw, nuw> : i64
    %15 = llvm.getelementptr inbounds|nuw %arg0[%14] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %16 = llvm.load %15 : !llvm.ptr -> f64
    %17 = llvm.add %6, %2 : i64
    %18 = llvm.mul %17, %5 overflow<nsw, nuw> : i64
    %19 = llvm.add %18, %9 overflow<nsw, nuw> : i64
    %20 = llvm.getelementptr inbounds|nuw %arg0[%19] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %21 = llvm.load %20 : !llvm.ptr -> f64
    %22 = llvm.mul %6, %5 overflow<nsw, nuw> : i64
    %23 = llvm.add %22, %9 overflow<nsw, nuw> : i64
    %24 = llvm.getelementptr inbounds|nuw %arg1[%23] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %25 = llvm.load %24 : !llvm.ptr -> f64
    %26 = llvm.getelementptr inbounds|nuw %arg0[%23] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %27 = llvm.load %26 : !llvm.ptr -> f64
    %28 = llvm.fadd %16, %21 : f64
    %29 = llvm.trunc %6 : i64 to i32
    %30 = llvm.sitofp %29 : i32 to f64
    %31 = llvm.fmul %30, %3 : f64
    %32 = llvm.fadd %28, %31 : f64
    %33 = llvm.fsub %25, %27 : f64
    %34 = llvm.intr.fabs(%33) : (f64) -> f64
    llvm.store %32, %24 : f64, !llvm.ptr
    %35 = llvm.fcmp "ogt" %10, %34 : f64
    %36 = llvm.select %35, %10, %34 : i1, f64
    %37 = llvm.add %9, %4 : i64
    llvm.br ^bb3(%37, %36 : i64, f64)
  ^bb5:  // pred: ^bb3
    %38 = llvm.add %6, %4 : i64
    llvm.br ^bb1(%38, %10 : i64, f64)
  ^bb6:  // pred: ^bb1
    llvm.store %7, %arg2 : f64, !llvm.ptr
    llvm.return
  }
}
