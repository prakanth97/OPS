// Example IR for a simple stencil (set_zero kernel)

// Phase 1 - Modelling function signature

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.ptr, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>):
    "llvm.return"() : () -> ()
  }) : () -> ()
  
  "llvm.func"() <{sym_name = "_mlir_ciface_ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb1(%0 : !llvm.ptr, %1 : !llvm.ptr, %2 : !llvm.ptr, %3 : !llvm.ptr, %4 : !llvm.ptr):
  
    %5 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
  
    %6 = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
  
    "llvm.call"(%0, %1, %5, %3, %6) <{callee = @ops_par_loop_set_zero, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 5, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
  
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 2 - Add ops.par_loop operation

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.ptr, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>):
    
    "ops.par_loop"(%name, %block, %dim, %range, %ops_arg1) ({
      %0 = arith.constant 0.000000e+00 : f64
      "ops.yield"(%0) : (f64) -> ()
    }) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
  
  "llvm.func"() <{sym_name = "_mlir_ciface_ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb1(%1 : !llvm.ptr, %2 : !llvm.ptr, %3 : !llvm.ptr, %4 : !llvm.ptr, %5 : !llvm.ptr):
    
    %6 = "llvm.load"(%3) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    
    %7 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    
    "llvm.call"(%1, %2, %6, %4, %7) <{callee = @ops_par_loop_set_zero, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 5, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 3 - Lowering ops.par_loop to extract data values

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.ptr, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>):
    %dat = "ops.extract_arg_dat"(%ops_arg1) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    
    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    
    %data_ref = "ops.ptr_to_memref"(%data_ptr) : (!llvm.ptr) -> memref<8x1xf64>
    
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x1xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    
    "ops.compute"(%data_field, %data_ref) ({
      %0 = arith.constant 0.000000e+00 : f64
      "ops.yield"(%0) : (f64) -> ()
    }) : (!stencil.field<[0,8]x[0,8]xf64>, memref<8x1xf64>) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
  
  "llvm.func"() <{sym_name = "_mlir_ciface_ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb1(%1 : !llvm.ptr, %2 : !llvm.ptr, %3 : !llvm.ptr, %4 : !llvm.ptr, %5 : !llvm.ptr):
  
    %6 = "llvm.load"(%3) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
  
    %7 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
  
    "llvm.call"(%1, %2, %6, %4, %7) <{callee = @ops_par_loop_set_zero, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 5, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
  
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 4 - lower ops.compute to the stencil computation

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.ptr, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>):
    %dat = "ops.extract_arg_dat"(%ops_arg1) : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    
    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    
    %data_ref = "ops.ptr_to_memref"(%data_ptr) : (!llvm.ptr) -> memref<8x1xf64>
    
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x1xf64>) -> !stencil.field<[0,8]x[0,8]xf64>
    
    %temp = stencil.load %data_field : !stencil.field<[0,8]x[0,8]xf64> -> !stencil.temp<[0,8]x[0,8]xf64>
    
    %apply = stencil.apply() -> (!stencil.temp<[0,8]x[0,8]xf64>) {
      %0 = arith.constant 0.000000e+00 : f64
      stencil.return %0 : f64
    } to <[0, 0], [8, 8]>
    
    stencil.store %apply to %data_field() : !stencil.temp<[0,8]x[0,8]xf64> to !stencil.field<[0,8]x[0,8]xf64>
    
    "llvm.return"() : () -> ()
  }) : () -> ()
  
  "llvm.func"() <{sym_name = "_mlir_ciface_ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb1(%0 : !llvm.ptr, %1 : !llvm.ptr, %2 : !llvm.ptr, %3 : !llvm.ptr, %4 : !llvm.ptr):
    %5 = "llvm.load"(%2) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
  
    %6 = "llvm.load"(%4) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
  
    "llvm.call"(%0, %1, %5, %3, %6) <{callee = @ops_par_loop_set_zero, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 5, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
  
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 5 - Lower leftover ops operations

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.ptr, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>):
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    
    %0 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    
    %data_ptr = "llvm.load"(%0) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    
    %data_ref = memref.reinterpret_cast %data_ptr to offset: [0], sizes: [8, 8], strides: [8, 1] : !llvm.ptr to memref<8x8xf64>
    
    %data_field = stencil.cast %data_ref : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    
    %temp = stencil.load %data_field : !stencil.field<[0,8]x[0,8]xf64> -> !stencil.temp<[0,8]x[0,8]xf64>
    
    %apply = stencil.apply() -> (!stencil.temp<[0,8]x[0,8]xf64>) {
      %1 = arith.constant 0.000000e+00 : f64
      stencil.return %1 : f64
    } to <[0, 0], [8, 8]>
    
    stencil.store %apply to %data_field() : !stencil.temp<[0,8]x[0,8]xf64> to !stencil.field<[0,8]x[0,8]xf64>
    
    "llvm.return"() : () -> ()
  }) : () -> ()
  
  "llvm.func"() <{sym_name = "_mlir_ciface_ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb1(%1 : !llvm.ptr, %2 : !llvm.ptr, %3 : !llvm.ptr, %4 : !llvm.ptr, %5 : !llvm.ptr):
    %6 = "llvm.load"(%3) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
  
    %7 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
  
    "llvm.call"(%1, %2, %6, %4, %7) <{callee = @ops_par_loop_set_zero, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 5, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
  
    "llvm.return"() : () -> ()
  }) : () -> ()
}

// Phase 5 - Stencil bufferize

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.ptr, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>):
    
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    
    %0 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    
    %data_ptr = "llvm.load"(%0) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    
    %data_ref = memref.reinterpret_cast %data_ptr to offset: [0], sizes: [8, 8], strides: [8, 1] : !llvm.ptr to memref<8x8xf64>
    
    %data_field = stencil.cast %data_ref : memref<8x8xf64> -> !stencil.field<[0,8]x[0,8]xf64>
    
    stencil.apply() outs (%data_field : !stencil.field<[0,8]x[0,8]xf64>) {
      %1 = arith.constant 0.000000e+00 : f64
      stencil.return %1 : f64
    } to <[0, 0], [8, 8]>
    
    "llvm.return"() : () -> ()
  }) : () -> ()
  
  "llvm.func"() <{sym_name = "_mlir_ciface_ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb1(%1 : !llvm.ptr, %2 : !llvm.ptr, %3 : !llvm.ptr, %4 : !llvm.ptr, %5 : !llvm.ptr):
  
    %6 = "llvm.load"(%3) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
  
    %7 = "llvm.load"(%5) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
  
    "llvm.call"(%1, %2, %6, %4, %7) <{callee = @ops_par_loop_set_zero, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 5, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
  
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 6 - Lower stencil

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.ptr, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>):
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
    %0 = "llvm.getelementptr"(%dat) <{rawConstantIndices = array<i32: 0, 10>, elem_type = !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, noWrapFlags = 0 : i32}> : (!llvm.ptr) -> !llvm.ptr
    %data_ptr = "llvm.load"(%0) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.ptr
    %data_ref = memref.reinterpret_cast %data_ptr to offset: [0], sizes: [8, 8], strides: [8, 1] : !llvm.ptr to memref<8x8xf64>
    %data_field = "memref.cast"(%data_ref) : (memref<8x8xf64>) -> memref<8x8xf64>
    %1 = memref.subview %data_field[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %2 = arith.constant 0 : index
    %3 = arith.constant 0 : index
    %4 = arith.constant 1 : index
    %5 = arith.constant 1 : index
    %6 = arith.constant 8 : index
    %7 = arith.constant 8 : index
    "scf.parallel"(%2, %3, %6, %7, %4, %5) <{operandSegmentSizes = array<i32: 2, 2, 2, 0>}> ({
    ^bb1(%8 : index, %9 : index):
      %10 = arith.constant 0.000000e+00 : f64
      memref.store %10, %1[%8, %9] : memref<8x8xf64, strided<[8, 1]>>
      scf.reduce
    }) : (index, index, index, index, index, index) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
  "llvm.func"() <{sym_name = "_mlir_ciface_ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb2(%11 : !llvm.ptr, %12 : !llvm.ptr, %13 : !llvm.ptr, %14 : !llvm.ptr, %15 : !llvm.ptr):
    %16 = "llvm.load"(%13) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    %17 = "llvm.load"(%15) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    "llvm.call"(%11, %12, %16, %14, %17) <{callee = @ops_par_loop_set_zero, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 5, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
}

// Phase 7 - Lower the data pointer to memref

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.ptr, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>):
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> !llvm.ptr
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
    %12 = memref.subview %data_field[0, 0] [8, 8] [1, 1] : memref<8x8xf64> to memref<8x8xf64, strided<[8, 1]>>
    %13 = arith.constant 0 : index
    %14 = arith.constant 0 : index
    %15 = arith.constant 1 : index
    %16 = arith.constant 1 : index
    %17 = arith.constant 8 : index
    %18 = arith.constant 8 : index
    "scf.parallel"(%13, %14, %17, %18, %15, %16) <{operandSegmentSizes = array<i32: 2, 2, 2, 0>}> ({
    ^bb1(%19 : index, %20 : index):
      %21 = arith.constant 0.000000e+00 : f64
      memref.store %21, %12[%19, %20] : memref<8x8xf64, strided<[8, 1]>>
      scf.reduce
    }) : (index, index, index, index, index, index) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
  "llvm.func"() <{sym_name = "_mlir_ciface_ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb2(%22 : !llvm.ptr, %23 : !llvm.ptr, %24 : !llvm.ptr, %25 : !llvm.ptr, %26 : !llvm.ptr):
    %27 = "llvm.load"(%24) <{ordering = 0 : i64}> : (!llvm.ptr) -> i32
    %28 = "llvm.load"(%26) <{ordering = 0 : i64}> : (!llvm.ptr) -> !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>
    "llvm.call"(%22, %23, %27, %25, %28) <{callee = @ops_par_loop_set_zero, fastmathFlags = #llvm.fastmath<none>, CConv = #llvm.cconv<ccc>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 5, 0>, TailCallKind = #llvm.tailcallkind<none>}> : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.ptr, !llvm.ptr, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32, i32)>) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
}


//////////////////////////////////////////////////////
/////////////////////////// MLIR PIPELINE (sequential)
//////////////////////////////////////////////////////


module {
  llvm.func @ops_par_loop_set_zero(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>) {
    %0 = llvm.mlir.constant(0.000000e+00 : f64) : f64
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(1 : index) : i64
    %3 = llvm.mlir.constant(0 : index) : i64
    %4 = llvm.extractvalue %arg4[0] : !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)> 
    %5 = llvm.getelementptr %4[0, 10] : (!llvm.ptr) -> !llvm.ptr, !llvm.struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>
    %6 = llvm.load %5 : !llvm.ptr -> !llvm.ptr
    llvm.br ^bb1(%3 : i64)
  ^bb1(%7: i64):  // 2 preds: ^bb0, ^bb5
    %8 = llvm.icmp "slt" %7, %1 : i64
    llvm.cond_br %8, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%3 : i64)
  ^bb3(%9: i64):  // 2 preds: ^bb2, ^bb4
    %10 = llvm.icmp "slt" %9, %1 : i64
    llvm.cond_br %10, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %11 = llvm.mul %7, %1 overflow<nsw, nuw> : i64
    %12 = llvm.add %11, %9 overflow<nsw, nuw> : i64
    %13 = llvm.getelementptr inbounds|nuw %6[%12] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    llvm.store %0, %13 : f64, !llvm.ptr
    %14 = llvm.add %9, %2 : i64
    llvm.br ^bb3(%14 : i64)
  ^bb5:  // pred: ^bb3
    %15 = llvm.add %7, %2 : i64
    llvm.br ^bb1(%15 : i64)
  ^bb6:  // pred: ^bb1
    llvm.return
  }
  llvm.func @_mlir_ciface_ops_par_loop_set_zero(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr) {
    %0 = llvm.load %arg2 : !llvm.ptr -> i32
    %1 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>
    llvm.call @ops_par_loop_set_zero(%arg0, %arg1, %0, %arg3, %1) : (!llvm.ptr, !llvm.ptr, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32)>) -> ()
    llvm.return
  }
}
