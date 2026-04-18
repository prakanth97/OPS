
// 1 - build function
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %8 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
}

// 2 - add ops operations
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    "ops.par_loop"(%0, %1, %2, %3, %4, %5, %7, %6) ({
    ^bb0:
    }) {operandSegmentSizes = array<i32: 1, 1, 1, 1, 2, 1, 1>} : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    %8 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
}

// 3 - lower par loop pass
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %arg = "ops.extract_arg"(%4) : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "ops.extract_arg_dat"(%arg) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    %data_ref = "ops.ptr_to_memref"(%data_ptr) {is_reduction = false} : (!llvm.ptr) -> memref<8x8xf64>
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x8xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    %arg_1 = "ops.extract_arg"(%5) : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "ops.extract_arg_dat"(%arg_1) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    %data_ptr_1 = "ops.extract_arg_dat_data"(%dat_1) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    %data_ref_1 = "ops.ptr_to_memref"(%data_ptr_1) {is_reduction = false} : (!llvm.ptr) -> memref<8x8xf64>
    %data_field_1 = "ops.memref_to_field"(%data_ref_1) : (memref<8x8xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%6) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %data_ref_2 = "ops.ptr_to_memref"(%reduction_data_ptr) {is_reduction = true} : (!llvm.ptr) -> memref<f64>
    func.call @ops_par_loop_demo_kernel_0_impl(%data_field, %data_field_1, %data_ref_2) : (!stencil.field<[0,8]x[0,8]xf64>, !stencil.field<[0,8]x[0,8]xf64>, memref<f64>) -> ()
    %8 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%ops_arg0: !stencil.field<[0,8]x[0,8]xf64>, %ops_arg1: !stencil.field<[0,8]x[0,8]xf64>, %ops_arg2: memref<f64>) {
    "ops.compute"(%ops_arg0, %ops_arg1, %ops_arg2) : (!stencil.field<[0,8]x[0,8]xf64>, !stencil.field<[0,8]x[0,8]xf64>, memref<f64>) -> ()
    func.return
  }
}

// 4 - lower compute pass
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %arg = "ops.extract_arg"(%4) : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "ops.extract_arg_dat"(%arg) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    %data_ref = "ops.ptr_to_memref"(%data_ptr) {is_reduction = false} : (!llvm.ptr) -> memref<8x8xf64>
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x8xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    %arg_1 = "ops.extract_arg"(%5) : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "ops.extract_arg_dat"(%arg_1) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    %data_ptr_1 = "ops.extract_arg_dat_data"(%dat_1) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    %data_ref_1 = "ops.ptr_to_memref"(%data_ptr_1) {is_reduction = false} : (!llvm.ptr) -> memref<8x8xf64>
    %data_field_1 = "ops.memref_to_field"(%data_ref_1) : (memref<8x8xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%6) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %data_ref_2 = "ops.ptr_to_memref"(%reduction_data_ptr) {is_reduction = true} : (!llvm.ptr) -> memref<f64>
    func.call @ops_par_loop_demo_kernel_0_impl(%data_field, %data_field_1, %data_ref_2) : (!stencil.field<[0,8]x[0,8]xf64>, !stencil.field<[0,8]x[0,8]xf64>, memref<f64>) -> ()
    %8 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%ops_arg0: !stencil.field<[0,8]x[0,8]xf64>, %ops_arg1: !stencil.field<[0,8]x[0,8]xf64>, %ops_arg2: memref<f64>) {
    stencil.apply(%0 = %ops_arg0 : !stencil.field<[0,8]x[0,8]xf64>, %1 = %ops_arg1 : !stencil.field<[0,8]x[0,8]xf64>) outs (%ops_arg1 : !stencil.field<[0,8]x[0,8]xf64>) reductions (%ops_arg2 : memref<f64>) {
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
        %18 = arith.cmpf ogt, %16, %17 : f64
        %19 = arith.select %18, %16, %17 : f64
        stencil.yield %19 : f64
      } : f64
      stencil.return %12 : f64
    } to <[1, 1], [7, 7]>
    func.return
  }
}

// 5 - lower extractions pass
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %arg = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %8 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%8) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %data_ref = "ops.ptr_to_memref"(%data_ptr) {is_reduction = false} : (!llvm.ptr) -> memref<8x8xf64>
    %data_field = stencil.cast %data_ref : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    %arg_1 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %9 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr_1 = "llvm.load"(%9) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %data_ref_1 = "ops.ptr_to_memref"(%data_ptr_1) {is_reduction = false} : (!llvm.ptr) -> memref<8x8xf64>
    %data_field_1 = stencil.cast %data_ref_1 : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%6) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %data_ref_2 = "ops.ptr_to_memref"(%reduction_data_ptr) {is_reduction = true} : (!llvm.ptr) -> memref<f64>
    func.call @ops_par_loop_demo_kernel_0_impl(%data_field, %data_field_1, %data_ref_2) : (!stencil.field<[0,8]x[0,8]xf64>, !stencil.field<[0,8]x[0,8]xf64>, memref<f64>) -> ()
    %10 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%ops_arg0: !stencil.field<[0,8]x[0,8]xf64>, %ops_arg1: !stencil.field<[0,8]x[0,8]xf64>, %ops_arg2: memref<f64>) {
    stencil.apply(%0 = %ops_arg0 : !stencil.field<[0,8]x[0,8]xf64>, %1 = %ops_arg1 : !stencil.field<[0,8]x[0,8]xf64>) outs (%ops_arg1 : !stencil.field<[0,8]x[0,8]xf64>) reductions (%ops_arg2 : memref<f64>) {
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
        %18 = arith.cmpf ogt, %16, %17 : f64
        %19 = arith.select %18, %16, %17 : f64
        stencil.yield %19 : f64
      } : f64
      stencil.return %12 : f64
    } to <[1, 1], [7, 7]>
    func.return
  }
}

// 6 - lower ptr to memref
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %arg = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %8 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%8) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %9 = arith.constant 0 : i64
    %10 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %11 = "llvm.insertvalue"(%10, %data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %12 = "llvm.insertvalue"(%11, %data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %13 = "llvm.insertvalue"(%12, %9) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %14 = arith.constant 8 : i64
    %15 = arith.constant 8 : i64
    %16 = "llvm.insertvalue"(%13, %14) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %17 = "llvm.insertvalue"(%16, %15) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %18 = arith.constant 8 : i64
    %19 = arith.constant 1 : i64
    %20 = "llvm.insertvalue"(%17, %18) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %21 = "llvm.insertvalue"(%20, %19) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref = builtin.unrealized_conversion_cast %21 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field = stencil.cast %data_ref : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    %arg_1 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %22 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr_1 = "llvm.load"(%22) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %23 = arith.constant 0 : i64
    %24 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %25 = "llvm.insertvalue"(%24, %data_ptr_1) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %26 = "llvm.insertvalue"(%25, %data_ptr_1) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %27 = "llvm.insertvalue"(%26, %23) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %28 = arith.constant 8 : i64
    %29 = arith.constant 8 : i64
    %30 = "llvm.insertvalue"(%27, %28) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %31 = "llvm.insertvalue"(%30, %29) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %32 = arith.constant 8 : i64
    %33 = arith.constant 1 : i64
    %34 = "llvm.insertvalue"(%31, %32) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %35 = "llvm.insertvalue"(%34, %33) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref_1 = builtin.unrealized_conversion_cast %35 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field_1 = stencil.cast %data_ref_1 : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%6) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %36 = arith.constant 0 : i64
    %37 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %38 = "llvm.insertvalue"(%37, %reduction_data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %39 = "llvm.insertvalue"(%38, %reduction_data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %40 = "llvm.insertvalue"(%39, %36) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %data_ref_2 = builtin.unrealized_conversion_cast %40 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)> to memref<f64>
    func.call @ops_par_loop_demo_kernel_0_impl(%data_field, %data_field_1, %data_ref_2) : (!stencil.field<[0,8]x[0,8]xf64>, !stencil.field<[0,8]x[0,8]xf64>, memref<f64>) -> ()
    %41 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%ops_arg0: !stencil.field<[0,8]x[0,8]xf64>, %ops_arg1: !stencil.field<[0,8]x[0,8]xf64>, %ops_arg2: memref<f64>) {
    stencil.apply(%0 = %ops_arg0 : !stencil.field<[0,8]x[0,8]xf64>, %1 = %ops_arg1 : !stencil.field<[0,8]x[0,8]xf64>) outs (%ops_arg1 : !stencil.field<[0,8]x[0,8]xf64>) reductions (%ops_arg2 : memref<f64>) {
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
        %18 = arith.cmpf ogt, %16, %17 : f64
        %19 = arith.select %18, %16, %17 : f64
        stencil.yield %19 : f64
      } : f64
      stencil.return %12 : f64
    } to <[1, 1], [7, 7]>
    func.return
  }
}

// 7 - lower stencil to mlir
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %arg = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %8 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%8) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %9 = arith.constant 0 : i64
    %10 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %11 = "llvm.insertvalue"(%10, %data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %12 = "llvm.insertvalue"(%11, %data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %13 = "llvm.insertvalue"(%12, %9) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %14 = arith.constant 8 : i64
    %15 = arith.constant 8 : i64
    %16 = "llvm.insertvalue"(%13, %14) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %17 = "llvm.insertvalue"(%16, %15) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %18 = arith.constant 8 : i64
    %19 = arith.constant 1 : i64
    %20 = "llvm.insertvalue"(%17, %18) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %21 = "llvm.insertvalue"(%20, %19) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref = builtin.unrealized_conversion_cast %21 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field = "memref.cast"(%data_ref) : (memref<8x8xf64>) -> memref<8x8xf64>
    %arg_1 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %22 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr_1 = "llvm.load"(%22) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %23 = arith.constant 0 : i64
    %24 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %25 = "llvm.insertvalue"(%24, %data_ptr_1) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %26 = "llvm.insertvalue"(%25, %data_ptr_1) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %27 = "llvm.insertvalue"(%26, %23) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %28 = arith.constant 8 : i64
    %29 = arith.constant 8 : i64
    %30 = "llvm.insertvalue"(%27, %28) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %31 = "llvm.insertvalue"(%30, %29) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %32 = arith.constant 8 : i64
    %33 = arith.constant 1 : i64
    %34 = "llvm.insertvalue"(%31, %32) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %35 = "llvm.insertvalue"(%34, %33) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref_1 = builtin.unrealized_conversion_cast %35 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field_1 = "memref.cast"(%data_ref_1) : (memref<8x8xf64>) -> memref<8x8xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%6) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %36 = arith.constant 0 : i64
    %37 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %38 = "llvm.insertvalue"(%37, %reduction_data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %39 = "llvm.insertvalue"(%38, %reduction_data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %40 = "llvm.insertvalue"(%39, %36) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %data_ref_2 = builtin.unrealized_conversion_cast %40 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)> to memref<f64>
    func.call @ops_par_loop_demo_kernel_0_impl(%data_field, %data_field_1, %data_ref_2) : (memref<8x8xf64>, memref<8x8xf64>, memref<f64>) -> ()
    %41 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%ops_arg0: memref<8x8xf64>, %ops_arg1: memref<8x8xf64>, %ops_arg2: memref<f64>) {
    %0 = memref.subview %ops_arg1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %1 = memref.subview %ops_arg0[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %2 = memref.subview %ops_arg1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %3 = arith.constant -1.7976931348623157e+308 : f64
    %4 = arith.constant 1 : index
    %5 = arith.constant 1 : index
    %6 = arith.constant 1 : index
    %7 = arith.constant 1 : index
    %8 = arith.constant 7 : index
    %9 = arith.constant 7 : index
    %10 = "scf.parallel"(%4, %5, %8, %9, %6, %7, %3) <{operandSegmentSizes = array<i32: 2, 2, 2, 1>}> ({
    ^bb0(%11: index, %12: index):
      %13 = arith.constant 1 : index
      %14 = arith.addi %11, %13 : index
      %15 = memref.load %1[%14, %12] : memref<8x8xf64, strided<[8, 1]>>
      %16 = arith.constant -1 : index
      %17 = arith.addi %11, %16 : index
      %18 = memref.load %1[%17, %12] : memref<8x8xf64, strided<[8, 1]>>
      %19 = memref.load %2[%11, %12] : memref<8x8xf64, strided<[8, 1]>>
      %20 = memref.load %1[%11, %12] : memref<8x8xf64, strided<[8, 1]>>
      %21 = arith.addf %15, %18 : f64
      %22, %23 = "ops.get_index"() {dim = 2 : i32} : () -> (i32, i32)
      %24 = arith.constant 3.141590e+00 : f64
      %25 = arith.sitofp %22 : i32 to f64
      %26 = arith.mulf %25, %24 : f64
      %27 = arith.addf %21, %26 : f64
      %28 = arith.subf %19, %20 : f64
      %29 = math.absf %28 : f64
      memref.store %27, %0[%11, %12] : memref<8x8xf64, strided<[8, 1]>>
      scf.reduce(%29 : f64) {
      ^bb1(%30: f64, %31: f64):
        %32 = arith.cmpf ogt, %30, %31 : f64
        %33 = arith.select %32, %30, %31 : f64
        scf.reduce.return %33 : f64
      }
    }) : (index, index, index, index, index, index, f64) -> f64
    memref.store %10, %ops_arg2[] : memref<f64>
    func.return
  }
}

// 8 - lower ops index pass + canonicalize
builtin.module {
  func.func @ops_par_loop_demo_kernel_0(%0: !llvm.ptr, %1: !llvm.ptr, %2: !llvm.ptr, %3: !llvm.ptr, %4: !llvm.ptr, %5: !llvm.ptr, %6: !llvm.ptr, %7: !llvm.ptr) {
    %arg = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat = "llvm.extractvalue"(%arg) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %8 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%8) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %9 = arith.constant 0 : i64
    %10 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %11 = "llvm.insertvalue"(%10, %data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %12 = "llvm.insertvalue"(%11, %data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %13 = "llvm.insertvalue"(%12, %9) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %14 = arith.constant 8 : i64
    %15 = arith.constant 8 : i64
    %16 = "llvm.insertvalue"(%13, %14) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %17 = "llvm.insertvalue"(%16, %15) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %18 = arith.constant 8 : i64
    %19 = arith.constant 1 : i64
    %20 = "llvm.insertvalue"(%17, %18) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %21 = "llvm.insertvalue"(%20, %19) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref = builtin.unrealized_conversion_cast %21 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field = "memref.cast"(%data_ref) : (memref<8x8xf64>) -> memref<8x8xf64>
    %arg_1 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    %dat_1 = "llvm.extractvalue"(%arg_1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %22 = "llvm.getelementptr"(%dat_1) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr_1 = "llvm.load"(%22) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %23 = arith.constant 0 : i64
    %24 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %25 = "llvm.insertvalue"(%24, %data_ptr_1) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %26 = "llvm.insertvalue"(%25, %data_ptr_1) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %27 = "llvm.insertvalue"(%26, %23) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %28 = arith.constant 8 : i64
    %29 = arith.constant 8 : i64
    %30 = "llvm.insertvalue"(%27, %28) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %31 = "llvm.insertvalue"(%30, %29) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %32 = arith.constant 8 : i64
    %33 = arith.constant 1 : i64
    %34 = "llvm.insertvalue"(%31, %32) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %35 = "llvm.insertvalue"(%34, %33) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %data_ref_1 = builtin.unrealized_conversion_cast %35 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x8xf64>
    %data_field_1 = "memref.cast"(%data_ref_1) : (memref<8x8xf64>) -> memref<8x8xf64>
    %reduction_handle_ptr_ptr = "llvm.getelementptr"(%6) <{rawConstantIndices = array<i32: 0, 4>, elem_type = !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_handle = "llvm.load"(%reduction_handle_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr_ptr = "llvm.getelementptr"(%reduction_handle) <{rawConstantIndices = array<i32: 0, 0>, elem_type = !llvm.struct<"struct.ops_reduction_core", (!llvm.ptr, i32, i32, i32, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %reduction_data_ptr = "llvm.load"(%reduction_data_ptr_ptr) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %36 = arith.constant 0 : i64
    %37 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %38 = "llvm.insertvalue"(%37, %reduction_data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %39 = "llvm.insertvalue"(%38, %reduction_data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %40 = "llvm.insertvalue"(%39, %36) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)>
    %data_ref_2 = builtin.unrealized_conversion_cast %40 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64)> to memref<f64>
    func.call @ops_par_loop_demo_kernel_0_impl(%data_field, %data_field_1, %data_ref_2) : (memref<8x8xf64>, memref<8x8xf64>, memref<f64>) -> ()
    %41 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    func.return
  }
  func.func @ops_par_loop_demo_kernel_0_impl(%ops_arg0: memref<8x8xf64>, %ops_arg1: memref<8x8xf64>, %ops_arg2: memref<f64>) {
    %0 = memref.subview %ops_arg1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %1 = memref.subview %ops_arg0[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %2 = memref.subview %ops_arg1[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %3 = arith.constant -1.7976931348623157e+308 : f64
    %4 = arith.constant 1 : index
    %5 = arith.constant 1 : index
    %6 = arith.constant 1 : index
    %7 = arith.constant 1 : index
    %8 = arith.constant 7 : index
    %9 = arith.constant 7 : index
    %10 = "scf.parallel"(%4, %5, %8, %9, %6, %7, %3) <{operandSegmentSizes = array<i32: 2, 2, 2, 1>}> ({
    ^bb0(%11: index, %12: index):
      %13 = arith.constant 1 : index
      %14 = arith.addi %11, %13 : index
      %15 = memref.load %1[%14, %12] : memref<8x8xf64, strided<[8, 1]>>
      %16 = arith.constant -1 : index
      %17 = arith.addi %11, %16 : index
      %18 = memref.load %1[%17, %12] : memref<8x8xf64, strided<[8, 1]>>
      %19 = memref.load %2[%11, %12] : memref<8x8xf64, strided<[8, 1]>>
      %20 = memref.load %1[%11, %12] : memref<8x8xf64, strided<[8, 1]>>
      %21 = arith.addf %15, %18 : f64
      %22 = arith.index_cast %11 : index to i32
      %23 = arith.constant 3.141590e+00 : f64
      %24 = arith.sitofp %22 : i32 to f64
      %25 = arith.mulf %24, %23 : f64
      %26 = arith.addf %21, %25 : f64
      %27 = arith.subf %19, %20 : f64
      %28 = math.absf %27 : f64
      memref.store %26, %0[%11, %12] : memref<8x8xf64, strided<[8, 1]>>
      scf.reduce(%28 : f64) {
      ^bb1(%29: f64, %30: f64):
        %31 = arith.cmpf ogt, %29, %30 : f64
        %32 = arith.select %31, %29, %30 : f64
        scf.reduce.return %32 : f64
      }
    }) : (index, index, index, index, index, index, f64) -> f64
    memref.store %10, %ops_arg2[] : memref<f64>
    func.return
  }
}