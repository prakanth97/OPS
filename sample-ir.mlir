// Example kernel!

// KERNEL FUNCTION
//
// void demo_kernel(const ACC<double> &A, ACC<double> &Anew, double *error, const int *idx) {
//     Anew(0,0) = A(1,0) + A(-1,0) + idx[0] * pi;

//     *error = fmax(*error, fabs(Anew(0,0) - A(0,0)));
// }


// PARALLEL LOOP CALL
//
// ops_par_loop(demo_kernel, "demo_kernel", block, 2, interior,
//     ops_arg_dat(d_A, 1, S2D_5pt, "double", OPS_READ),
//     ops_arg_dat(d_Anew, 1, S2D_00, "double", OPS_RW),
//     ops_arg_reduce(h_error, 1, "double", OPS_MAX),
//     ops_arg_idx()
// );


// Function signature with wrapper
builtin.module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%name: !llvm.ptr, %block: !llvm.ptr, %dim: i32, %range: !llvm.ptr, %ops_arg1: !llvm.ptr, %ops_arg2: !llvm.ptr, %ops_arg3: !llvm.ptr, %ops_arg4: !llvm.ptr) {
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %8 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.call"(%0, %1, %8, %3, %4, %5, %6, %7) <{callee = @ops_par_loop_demo_kernel_0_impl, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}


// Add ops.par_loop operation
builtin.module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%name: !llvm.ptr, %block: !llvm.ptr, %dim: i32, %range: !llvm.ptr, %ops_arg1: !llvm.ptr, %ops_arg2: !llvm.ptr, %ops_arg3: !llvm.ptr, %ops_arg4: !llvm.ptr) {
    "ops.par_loop"(%name, %block, %dim, %range, %ops_arg1, %ops_arg2, %ops_arg4, %ops_arg3) ({
    ^bb0:
    }) {operandSegmentSizes = array<i32: 1, 1, 1, 1, 2, 1, 1>} : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %8 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.call"(%0, %1, %8, %3, %4, %5, %6, %7) <{callee = @ops_par_loop_demo_kernel_0_impl, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// Lower par_loops pass
builtin.module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%name: !llvm.ptr, %block: !llvm.ptr, %dim: i32, %range: !llvm.ptr, %ops_arg1: !llvm.ptr, %ops_arg2: !llvm.ptr, %ops_arg3: !llvm.ptr, %ops_arg4: !llvm.ptr) {
    %arg = "ops.extract_arg"(%ops_arg1) : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "ops.extract_arg_dat"(%arg) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    %data_ref = "ops.ptr_to_memref"(%data_ptr) : (!llvm.ptr) -> memref<8x1xf64>
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x1xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    %arg_1 = "ops.extract_arg"(%ops_arg2) : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "ops.extract_arg_dat"(%arg_1) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    %data_ptr_1 = "ops.extract_arg_dat_data"(%dat_1) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    %data_ref_1 = "ops.ptr_to_memref"(%data_ptr_1) : (!llvm.ptr) -> memref<8x1xf64>
    %data_field_1 = "ops.memref_to_field"(%data_ref_1) : (memref<8x1xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%ops_arg3) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    "ops.compute"(%data_field, %data_field_1, %reduction_data_ptr) : (!stencil.field<[0,8]x[0,8]xf64>, !stencil.field<[0,8]x[0,8]xf64>, !llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %8 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.call"(%0, %1, %8, %3, %4, %5, %6, %7) <{callee = @ops_par_loop_demo_kernel_0_impl, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// Lower compute pass
builtin.module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%name: !llvm.ptr, %block: !llvm.ptr, %dim: i32, %range: !llvm.ptr, %ops_arg1: !llvm.ptr, %ops_arg2: !llvm.ptr, %ops_arg3: !llvm.ptr, %ops_arg4: !llvm.ptr) {
    %arg = "ops.extract_arg"(%ops_arg1) : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "ops.extract_arg_dat"(%arg) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    %data_ref = "ops.ptr_to_memref"(%data_ptr) : (!llvm.ptr) -> memref<8x1xf64>
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x1xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    %arg_1 = "ops.extract_arg"(%ops_arg2) : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "ops.extract_arg_dat"(%arg_1) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    %data_ptr_1 = "ops.extract_arg_dat_data"(%dat_1) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    %data_ref_1 = "ops.ptr_to_memref"(%data_ptr_1) : (!llvm.ptr) -> memref<8x1xf64>
    %data_field_1 = "ops.memref_to_field"(%data_ref_1) : (memref<8x1xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%ops_arg3) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    stencil.apply(%0 = %data_field : !stencil.field<[0,8]x[0,8]xf64>, %1 = %data_field_1 : !stencil.field<[0,8]x[0,8]xf64>) outs (%data_field_1 : !stencil.field<[0,8]x[0,8]xf64>) reductions (%reduction_data_ptr : !llvm.ptr) {
      %2 = stencil.access %0[1, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %3 = stencil.access %0[-1, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %4 = stencil.access %1[0, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %5 = stencil.access %0[0, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %6 = arith.addf %2, %3 : f64
      %7, %8 = "ops.get_index"() {dim = 2 : i32} : () -> (i32, i32)
      %9 = arith.constant 3.141590e+00 : f64
      %10 = arith.sitofp %7 : i32 to f64
      %11 = arith.mulf %10, %9 : f64
      %12 = arith.addf %6, %11 : f64
      %13 = arith.subf %4, %5 : f64
      %14 = math.absf %13 : f64
      stencil.reduce %14 init %15 {
      ^bb0(%16: f64, %17: f64):
        %18 = arith.maximumf %16, %17 : f64
        stencil.yield %18 : f64
      } : f64
      stencil.return %12 : f64
    } to <[1, 1], [7, 7]>
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %8 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.call"(%0, %1, %8, %3, %4, %5, %6, %7) <{callee = @ops_par_loop_demo_kernel_0_impl, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// Lower extractions pass
builtin.module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%name: !llvm.ptr, %block: !llvm.ptr, %dim: i32, %range: !llvm.ptr, %ops_arg1: !llvm.ptr, %ops_arg2: !llvm.ptr, %ops_arg3: !llvm.ptr, %ops_arg4: !llvm.ptr) {
    %arg = "llvm.load"(%ops_arg1) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %0 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%0) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %data_ref = memref.reinterpret_cast %data_ptr to offset: [0], sizes: [8, 8], strides: [8, 1] : !llvm.ptr to memref<8x8xf64>
    %data_field = stencil.cast %data_ref : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    %arg_1 = "llvm.load"(%ops_arg2) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %1 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr_1 = "llvm.load"(%1) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    
    // Maybe change this!
    %data_ref_1 = memref.reinterpret_cast %data_ptr_1 to offset: [0], sizes: [8, 8], strides: [8, 1] : !llvm.ptr to memref<8x8xf64>
    %data_field_1 = stencil.cast %data_ref_1 : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%ops_arg3) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    stencil.apply(%2 = %data_field : !stencil.field<[0,8]x[0,8]xf64>, %3 = %data_field_1 : !stencil.field<[0,8]x[0,8]xf64>) outs (%data_field_1 : !stencil.field<[0,8]x[0,8]xf64>) reductions (%reduction_data_ptr : !llvm.ptr) {
      %4 = stencil.access %2[1, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %5 = stencil.access %2[-1, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %6 = stencil.access %3[0, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %7 = stencil.access %2[0, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %8 = arith.addf %4, %5 : f64
      %9, %10 = "ops.get_index"() {dim = 2 : i32} : () -> (i32, i32)
      %11 = arith.constant 3.141590e+00 : f64
      %12 = arith.sitofp %9 : i32 to f64
      %13 = arith.mulf %12, %11 : f64
      %14 = arith.addf %8, %13 : f64
      %15 = arith.subf %6, %7 : f64
      %16 = math.absf %15 : f64
      stencil.reduce %16 init %17 {
      ^bb0(%18: f64, %19: f64):
        %20 = arith.maximumf %18, %19 : f64
        stencil.yield %20 : f64
      } : f64
      stencil.return %14 : f64
    } to <[1, 1], [7, 7]>
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr, %8: !llvm.ptr, %9: !llvm.ptr) {
    %10 = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.call"(%2, %3, %10, %5, %6, %7, %8, %9) <{callee = @ops_par_loop_demo_kernel_0_impl, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}


// Create memref
builtin.module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%name: !llvm.ptr, %block: !llvm.ptr, %dim: i32, %range: !llvm.ptr, %ops_arg1: !llvm.ptr, %ops_arg2: !llvm.ptr, %ops_arg3: !llvm.ptr, %ops_arg4: !llvm.ptr) {
    %arg = "llvm.load"(%ops_arg1) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %0 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%0) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %1 = arith.constant 0 : i64
    %2 = arith.constant 8 : i64
    %3 = arith.constant 1 : i64
    %4 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %5 = "llvm.insertvalue"(%4, %data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %6 = "llvm.insertvalue"(%5, %data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %7 = "llvm.insertvalue"(%6, %1) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %8 = "llvm.insertvalue"(%7, %2) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %9 = "llvm.insertvalue"(%8, %2) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %10 = "llvm.insertvalue"(%9, %2) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %11 = "llvm.insertvalue"(%10, %3) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref = builtin.unrealized_conversion_cast %11 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field = stencil.cast %data_ref : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    %arg_1 = "llvm.load"(%ops_arg2) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %12 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr_1 = "llvm.load"(%12) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %13 = arith.constant 0 : i64
    %14 = arith.constant 8 : i64
    %15 = arith.constant 1 : i64
    %16 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %17 = "llvm.insertvalue"(%16, %data_ptr_1) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %18 = "llvm.insertvalue"(%17, %data_ptr_1) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %19 = "llvm.insertvalue"(%18, %13) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %20 = "llvm.insertvalue"(%19, %14) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %21 = "llvm.insertvalue"(%20, %14) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %22 = "llvm.insertvalue"(%21, %14) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %23 = "llvm.insertvalue"(%22, %15) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref_1 = builtin.unrealized_conversion_cast %23 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field_1 = stencil.cast %data_ref_1 : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%ops_arg3) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    stencil.apply(%24 = %data_field : !stencil.field<[0,8]x[0,8]xf64>, %25 = %data_field_1 : !stencil.field<[0,8]x[0,8]xf64>) outs (%data_field_1 : !stencil.field<[0,8]x[0,8]xf64>) reductions (%reduction_data_ptr : !llvm.ptr) {
      %26 = stencil.access %24[1, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %27 = stencil.access %24[-1, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %28 = stencil.access %25[0, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %29 = stencil.access %24[0, 0] : !stencil.temp<[0,8]x[0,8]xf64>
      %30 = arith.addf %26, %27 : f64
      %31, %32 = "ops.get_index"() {dim = 2 : i32} : () -> (i32, i32)
      %33 = arith.constant 3.141590e+00 : f64
      %34 = arith.sitofp %31 : i32 to f64
      %35 = arith.mulf %34, %33 : f64
      %36 = arith.addf %30, %35 : f64
      %37 = arith.subf %28, %29 : f64
      %38 = math.absf %37 : f64
      stencil.reduce %38 init %39 {
      ^bb0(%40: f64, %41: f64):
        %42 = arith.maximumf %40, %41 : f64
        stencil.yield %42 : f64
      } : f64
      stencil.return %36 : f64
    } to <[1, 1], [7, 7]>
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%24: !llvm.ptr, %25: !llvm.ptr, %26: !llvm.ptr, %27: !llvm.ptr, %28: !llvm.ptr, %29: !llvm.ptr, %30: !llvm.ptr, %31: !llvm.ptr) {
    %32 = "llvm.load"(%26) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.call"(%24, %25, %32, %27, %28, %29, %30, %31) <{callee = @ops_par_loop_demo_kernel_0_impl, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// Convert stencil to llmlir pass
builtin.module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%name: !llvm.ptr, %block: !llvm.ptr, %dim: i32, %range: !llvm.ptr, %ops_arg1: !llvm.ptr, %ops_arg2: !llvm.ptr, %ops_arg3: !llvm.ptr, %ops_arg4: !llvm.ptr) {
    %arg = "llvm.load"(%ops_arg1) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %0 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%0) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %1 = arith.constant 0 : i64
    %2 = arith.constant 8 : i64
    %3 = arith.constant 1 : i64
    %4 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %5 = "llvm.insertvalue"(%4, %data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %6 = "llvm.insertvalue"(%5, %data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %7 = "llvm.insertvalue"(%6, %1) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %8 = "llvm.insertvalue"(%7, %2) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %9 = "llvm.insertvalue"(%8, %2) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %10 = "llvm.insertvalue"(%9, %2) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %11 = "llvm.insertvalue"(%10, %3) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref = builtin.unrealized_conversion_cast %11 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field = "memref.cast"(%data_ref) : (memref<8x8xf64>) -> memref<8x8xf64>
    %arg_1 = "llvm.load"(%ops_arg2) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %12 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr_1 = "llvm.load"(%12) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %13 = arith.constant 0 : i64
    %14 = arith.constant 8 : i64
    %15 = arith.constant 1 : i64
    %16 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %17 = "llvm.insertvalue"(%16, %data_ptr_1) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %18 = "llvm.insertvalue"(%17, %data_ptr_1) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %19 = "llvm.insertvalue"(%18, %13) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %20 = "llvm.insertvalue"(%19, %14) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %21 = "llvm.insertvalue"(%20, %14) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %22 = "llvm.insertvalue"(%21, %14) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %23 = "llvm.insertvalue"(%22, %15) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref_1 = builtin.unrealized_conversion_cast %23 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field_1 = "memref.cast"(%data_ref_1) : (memref<8x8xf64>) -> memref<8x8xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%ops_arg3) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %24 = memref.subview %data_field_1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %25 = memref.subview %data_field[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %26 = memref.subview %data_field_1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %27 = arith.constant -1.7976931348623157e+308 : f64
    %28 = arith.constant 1 : index
    %29 = arith.constant 1 : index
    %30 = arith.constant 1 : index
    %31 = arith.constant 1 : index
    %32 = arith.constant 7 : index
    %33 = arith.constant 7 : index
    %34 = "scf.parallel"(%28, %29, %32, %33, %30, %31, %27) <{operandSegmentSizes = array<i32: 2, 2, 2, 1>}> ({
    ^bb0(%35: index, %36: index):
      %37 = arith.constant 1 : index
      %38 = arith.addi %35, %37 : index
      %39 = memref.load %25[%38, %36] : memref<8x8xf64, strided<[8, 1]>>
      %40 = arith.constant -1 : index
      %41 = arith.addi %35, %40 : index
      %42 = memref.load %25[%41, %36] : memref<8x8xf64, strided<[8, 1]>>
      %43 = memref.load %26[%35, %36] : memref<8x8xf64, strided<[8, 1]>>
      %44 = memref.load %25[%35, %36] : memref<8x8xf64, strided<[8, 1]>>
      %45 = arith.addf %39, %42 : f64
      %46, %47 = "ops.get_index"() {dim = 2 : i32} : () -> (i32, i32)
      %48 = arith.constant 3.141590e+00 : f64
      %49 = arith.sitofp %46 : i32 to f64
      %50 = arith.mulf %49, %48 : f64
      %51 = arith.addf %45, %50 : f64
      %52 = arith.subf %43, %44 : f64
      %53 = math.absf %52 : f64
      memref.store %51, %24[%35, %36] : memref<8x8xf64, strided<[8, 1]>>
      scf.reduce(%53 : f64) {
      ^bb1(%54: f64, %55: f64):
        %56 = arith.maximumf %54, %55 : f64
        scf.reduce.return %56 : f64
      }
    }) : (index, index, index, index, index, index, f64) -> f64
    "llvm.store"(%34, %reduction_data_ptr) <{ordering = 0 : i64}> : (f64, !llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%57: !llvm.ptr, %58: !llvm.ptr, %59: !llvm.ptr, %60: !llvm.ptr, %61: !llvm.ptr, %62: !llvm.ptr, %63: !llvm.ptr, %64: !llvm.ptr) {
    %65 = "llvm.load"(%59) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.call"(%57, %58, %65, %60, %61, %62, %63, %64) <{callee = @ops_par_loop_demo_kernel_0_impl, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}


// Lower OPS index pass + canonicalize
builtin.module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%name: !llvm.ptr, %block: !llvm.ptr, %dim: i32, %range: !llvm.ptr, %ops_arg1: !llvm.ptr, %ops_arg2: !llvm.ptr, %ops_arg3: !llvm.ptr, %ops_arg4: !llvm.ptr) {
    %arg = "llvm.load"(%ops_arg1) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %0 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%0) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %1 = arith.constant 0 : i64
    %2 = arith.constant 8 : i64
    %3 = arith.constant 1 : i64
    %4 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %5 = "llvm.insertvalue"(%4, %data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %6 = "llvm.insertvalue"(%5, %data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %7 = "llvm.insertvalue"(%6, %1) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %8 = "llvm.insertvalue"(%7, %2) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %9 = "llvm.insertvalue"(%8, %2) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %10 = "llvm.insertvalue"(%9, %2) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %11 = "llvm.insertvalue"(%10, %3) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref = builtin.unrealized_conversion_cast %11 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field = "memref.cast"(%data_ref) : (memref<8x8xf64>) -> memref<8x8xf64>
    %arg_1 = "llvm.load"(%ops_arg2) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %12 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr_1 = "llvm.load"(%12) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %13 = arith.constant 0 : i64
    %14 = arith.constant 8 : i64
    %15 = arith.constant 1 : i64
    %16 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %17 = "llvm.insertvalue"(%16, %data_ptr_1) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %18 = "llvm.insertvalue"(%17, %data_ptr_1) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %19 = "llvm.insertvalue"(%18, %13) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %20 = "llvm.insertvalue"(%19, %14) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %21 = "llvm.insertvalue"(%20, %14) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %22 = "llvm.insertvalue"(%21, %14) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %23 = "llvm.insertvalue"(%22, %15) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref_1 = builtin.unrealized_conversion_cast %23 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field_1 = "memref.cast"(%data_ref_1) : (memref<8x8xf64>) -> memref<8x8xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%ops_arg3) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %24 = memref.subview %data_field_1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %25 = memref.subview %data_field[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %26 = memref.subview %data_field_1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %27 = arith.constant -1.7976931348623157e+308 : f64
    %28 = arith.constant 1 : index
    %29 = arith.constant 1 : index
    %30 = arith.constant 1 : index
    %31 = arith.constant 1 : index
    %32 = arith.constant 7 : index
    %33 = arith.constant 7 : index
    %34 = "scf.parallel"(%28, %29, %32, %33, %30, %31, %27) <{operandSegmentSizes = array<i32: 2, 2, 2, 1>}> ({
    ^bb0(%35: index, %36: index):
      %37 = arith.constant 1 : index
      %38 = arith.addi %35, %37 : index
      %39 = memref.load %25[%38, %36] : memref<8x8xf64, strided<[8, 1]>>
      %40 = arith.constant -1 : index
      %41 = arith.addi %35, %40 : index
      %42 = memref.load %25[%41, %36] : memref<8x8xf64, strided<[8, 1]>>
      %43 = memref.load %26[%35, %36] : memref<8x8xf64, strided<[8, 1]>>
      %44 = memref.load %25[%35, %36] : memref<8x8xf64, strided<[8, 1]>>
      %45 = arith.addf %39, %42 : f64
      %46 = arith.index_cast %35 : index to i32
      %47 = arith.constant 3.141590e+00 : f64
      %48 = arith.sitofp %46 : i32 to f64
      %49 = arith.mulf %48, %47 : f64
      %50 = arith.addf %45, %49 : f64
      %51 = arith.subf %43, %44 : f64
      %52 = math.absf %51 : f64
      memref.store %50, %24[%35, %36] : memref<8x8xf64, strided<[8, 1]>>
      scf.reduce(%52 : f64) {
      ^bb1(%53: f64, %54: f64):
        %55 = arith.maximumf %53, %54 : f64
        scf.reduce.return %55 : f64
      }
    }) : (index, index, index, index, index, index, f64) -> f64
    "llvm.store"(%34, %reduction_data_ptr) <{ordering = 0 : i64}> : (f64, !llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%56: !llvm.ptr, %57: !llvm.ptr, %58: !llvm.ptr, %59: !llvm.ptr, %60: !llvm.ptr, %61: !llvm.ptr, %62: !llvm.ptr, %63: !llvm.ptr) {
    %64 = "llvm.load"(%58) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    "llvm.call"(%56, %57, %64, %59, %60, %61, %62, %63) <{callee = @ops_par_loop_demo_kernel_0_impl, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 8, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}

// Convert to MLIR module
module {
  llvm.func @ops_par_loop_demo_kernel_0_impl(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %2 = llvm.getelementptr %1[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %3 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %c0_i64 = arith.constant 0 : i64
    %c8_i64 = arith.constant 8 : i64
    %c1_i64 = arith.constant 1 : i64
    %4 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %5 = llvm.insertvalue %3, %4[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %3, %5[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %c0_i64, %6[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %c8_i64, %7[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %c8_i64, %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %c8_i64, %9[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %c1_i64, %10[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = builtin.unrealized_conversion_cast %11 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %cast = memref.cast %12 : memref<8x8xf64> to memref<8x8xf64>
    %13 = llvm.load %arg5 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %14 = llvm.extractvalue %13[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %15 = llvm.getelementptr %14[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %16 = llvm.load %15 : !llvm.ptr -> !llvm.ptr
    %c0_i64_0 = arith.constant 0 : i64
    %c8_i64_1 = arith.constant 8 : i64
    %c1_i64_2 = arith.constant 1 : i64
    %17 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %18 = llvm.insertvalue %16, %17[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %16, %18[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %c0_i64_0, %19[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %c8_i64_1, %20[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %c8_i64_1, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %c8_i64_1, %22[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %c1_i64_2, %23[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = builtin.unrealized_conversion_cast %24 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> to memref<8x8xf64>
    %cast_3 = memref.cast %25 : memref<8x8xf64> to memref<8x8xf64>
    %26 = llvm.getelementptr %arg6[0, 4] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    %27 = llvm.load %26 : !llvm.ptr -> !llvm.ptr
    %28 = llvm.getelementptr %27[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_reduction_core", (ptr, i32, i32, i32, i32, ptr, ptr, ptr)>
    %29 = llvm.load %28 : !llvm.ptr -> !llvm.ptr
    %subview = memref.subview %cast_3[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %subview_4 = memref.subview %cast[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %subview_5 = memref.subview %cast_3[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %cst = arith.constant -1.7976931348623157E+308 : f64
    %c1 = arith.constant 1 : index
    %c1_6 = arith.constant 1 : index
    %c1_7 = arith.constant 1 : index
    %c1_8 = arith.constant 1 : index
    %c7 = arith.constant 7 : index
    %c7_9 = arith.constant 7 : index
    %30 = scf.parallel (%arg8, %arg9) = (%c1, %c1_6) to (%c7, %c7_9) step (%c1_7, %c1_8) init (%cst) -> f64 {
      %c1_10 = arith.constant 1 : index
      %31 = arith.addi %arg8, %c1_10 : index
      %32 = memref.load %subview_4[%31, %arg9] : memref<8x8xf64, strided<[8, 1]>>
      %c-1 = arith.constant -1 : index
      %33 = arith.addi %arg8, %c-1 : index
      %34 = memref.load %subview_4[%33, %arg9] : memref<8x8xf64, strided<[8, 1]>>
      %35 = memref.load %subview_5[%arg8, %arg9] : memref<8x8xf64, strided<[8, 1]>>
      %36 = memref.load %subview_4[%arg8, %arg9] : memref<8x8xf64, strided<[8, 1]>>
      %37 = arith.addf %32, %34 : f64
      %38 = arith.index_cast %arg8 : index to i32
      %cst_11 = arith.constant 3.141590e+00 : f64
      %39 = arith.sitofp %38 : i32 to f64
      %40 = arith.mulf %39, %cst_11 : f64
      %41 = arith.addf %37, %40 : f64
      %42 = arith.subf %35, %36 : f64
      %43 = math.absf %42 : f64
      memref.store %41, %subview[%arg8, %arg9] : memref<8x8xf64, strided<[8, 1]>>
      scf.reduce(%43 : f64) {
      ^bb0(%arg10: f64, %arg11: f64):
        %44 = arith.maximumf %arg10, %arg11 : f64
        scf.reduce.return %44 : f64
      }
    }
    llvm.store %30, %29 : f64, !llvm.ptr
    llvm.return
  }
  llvm.func @ops_par_loop_demo_kernel_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    llvm.call @ops_par_loop_demo_kernel_0_impl(%arg0, %arg1, %0, %arg3, %arg4, %arg5, %arg6, %arg7) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    llvm.return
  }
}
