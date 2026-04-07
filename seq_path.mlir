// Sequential path

// Not much to explain here, just show final IR
module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.mlir.constant(8 : index) : i64
    %1 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    %2 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %3 = llvm.mlir.constant(-1 : index) : i64
    %4 = llvm.mlir.constant(7 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %7 = llvm.extractvalue %6[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %8 = llvm.getelementptr %7[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %9 = llvm.load %8 : !llvm.ptr -> !llvm.ptr
    %10 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %11 = llvm.extractvalue %10[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %12 = llvm.getelementptr %11[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %13 = llvm.load %12 : !llvm.ptr -> !llvm.ptr
    %14 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %15 = llvm.load %14 : !llvm.ptr -> !llvm.ptr
    %16 = llvm.getelementptr %15[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %17 = llvm.load %16 : !llvm.ptr -> !llvm.ptr
    llvm.br ^bb1(%5, %1 : i64, f64)
  ^bb1(%18: i64, %19: f64):  // 2 preds: ^bb0, ^bb5
    %20 = llvm.icmp "slt" %18, %4 : i64
    llvm.cond_br %20, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%5, %19 : i64, f64)
  ^bb3(%21: i64, %22: f64):  // 2 preds: ^bb2, ^bb4
    %23 = llvm.icmp "slt" %21, %4 : i64
    llvm.cond_br %23, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %24 = llvm.add %18, %5 : i64
    %25 = llvm.mul %24, %0 overflow<nsw, nuw> : i64
    %26 = llvm.add %25, %21 overflow<nsw, nuw> : i64
    %27 = llvm.getelementptr inbounds|nuw %9[%26] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %28 = llvm.load %27 : !llvm.ptr -> f64
    %29 = llvm.add %18, %3 : i64
    %30 = llvm.mul %29, %0 overflow<nsw, nuw> : i64
    %31 = llvm.add %30, %21 overflow<nsw, nuw> : i64
    %32 = llvm.getelementptr inbounds|nuw %9[%31] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %33 = llvm.load %32 : !llvm.ptr -> f64
    %34 = llvm.mul %18, %0 overflow<nsw, nuw> : i64
    %35 = llvm.add %34, %21 overflow<nsw, nuw> : i64
    %36 = llvm.getelementptr inbounds|nuw %13[%35] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %37 = llvm.load %36 : !llvm.ptr -> f64
    %38 = llvm.getelementptr inbounds|nuw %9[%35] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %39 = llvm.load %38 : !llvm.ptr -> f64
    %40 = llvm.fadd %28, %33 : f64
    %41 = llvm.trunc %18 : i64 to i32
    %42 = llvm.sitofp %41 : i32 to f64
    %43 = llvm.fmul %42, %2 : f64
    %44 = llvm.fadd %40, %43 : f64
    %45 = llvm.fsub %37, %39 : f64
    %46 = llvm.intr.fabs(%45) : (f64) -> f64
    llvm.store %44, %36 : f64, !llvm.ptr
    %47 = llvm.intr.maximum(%22, %46) : (f64, f64) -> f64
    %48 = llvm.add %21, %5 : i64
    llvm.br ^bb3(%48, %47 : i64, f64)
  ^bb5:  // pred: ^bb3
    %49 = llvm.add %18, %5 : i64
    llvm.br ^bb1(%49, %22 : i64, f64)
  ^bb6:  // pred: ^bb1
    llvm.store %19, %17 : f64, !llvm.ptr
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    llvm.call @ops_par_loop_demo_kernel_0_impl(%arg0, %arg1, %0, %arg3, %arg4, %arg5, %arg6, %arg7) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// after mlir-translate

module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.mlir.constant(8 : index) : i64
    %1 = llvm.mlir.constant(-1.7976931348623157E+308 : f64) : f64
    %2 = llvm.mlir.constant(3.141590e+00 : f64) : f64
    %3 = llvm.mlir.constant(-1 : index) : i64
    %4 = llvm.mlir.constant(7 : index) : i64
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %7 = llvm.extractvalue %6[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %8 = llvm.getelementptr %7[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %9 = llvm.load %8 : !llvm.ptr -> !llvm.ptr
    %10 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %11 = llvm.extractvalue %10[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %12 = llvm.getelementptr %11[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %13 = llvm.load %12 : !llvm.ptr -> !llvm.ptr
    %14 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %15 = llvm.load %14 : !llvm.ptr -> !llvm.ptr
    %16 = llvm.getelementptr %15[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %17 = llvm.load %16 : !llvm.ptr -> !llvm.ptr
    llvm.br ^bb1(%5, %1 : i64, f64)
  ^bb1(%18: i64, %19: f64):  // 2 preds: ^bb0, ^bb5
    %20 = llvm.icmp "slt" %18, %4 : i64
    llvm.cond_br %20, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%5, %19 : i64, f64)
  ^bb3(%21: i64, %22: f64):  // 2 preds: ^bb2, ^bb4
    %23 = llvm.icmp "slt" %21, %4 : i64
    llvm.cond_br %23, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %24 = llvm.add %18, %5 : i64
    %25 = llvm.mul %24, %0 overflow<nsw, nuw> : i64
    %26 = llvm.add %25, %21 overflow<nsw, nuw> : i64
    %27 = llvm.getelementptr inbounds|nuw %9[%26] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %28 = llvm.load %27 : !llvm.ptr -> f64
    %29 = llvm.add %18, %3 : i64
    %30 = llvm.mul %29, %0 overflow<nsw, nuw> : i64
    %31 = llvm.add %30, %21 overflow<nsw, nuw> : i64
    %32 = llvm.getelementptr inbounds|nuw %9[%31] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %33 = llvm.load %32 : !llvm.ptr -> f64
    %34 = llvm.mul %18, %0 overflow<nsw, nuw> : i64
    %35 = llvm.add %34, %21 overflow<nsw, nuw> : i64
    %36 = llvm.getelementptr inbounds|nuw %13[%35] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %37 = llvm.load %36 : !llvm.ptr -> f64
    %38 = llvm.getelementptr inbounds|nuw %9[%35] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    %39 = llvm.load %38 : !llvm.ptr -> f64
    %40 = llvm.fadd %28, %33 : f64
    %41 = llvm.trunc %18 : i64 to i32
    %42 = llvm.sitofp %41 : i32 to f64
    %43 = llvm.fmul %42, %2 : f64
    %44 = llvm.fadd %40, %43 : f64
    %45 = llvm.fsub %37, %39 : f64
    %46 = llvm.intr.fabs(%45) : (f64) -> f64
    llvm.store %44, %36 : f64, !llvm.ptr
    %47 = llvm.intr.maximum(%22, %46) : (f64, f64) -> f64
    %48 = llvm.add %21, %5 : i64
    llvm.br ^bb3(%48, %47 : i64, f64)
  ^bb5:  // pred: ^bb3
    %49 = llvm.add %18, %5 : i64
    llvm.br ^bb1(%49, %22 : i64, f64)
  ^bb6:  // pred: ^bb1
    llvm.store %19, %17 : f64, !llvm.ptr
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    llvm.call @ops_par_loop_demo_kernel_0_impl(%arg0, %arg1, %0, %arg3, %arg4, %arg5, %arg6, %arg7) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}
