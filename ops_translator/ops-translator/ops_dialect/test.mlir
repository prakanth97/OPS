// Example IR for a simple stencil (set_zero kernel)

// Phase 1 - Modelling function signature

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 2 - Add ops.par_loop operation

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
    
    "ops.par_loop"(%name, %block, %dim, %range, %ops_arg1) ({
      %0 = arith.constant 0.000000e+00 : f64
      "ops.yield"(%0) : (f64) -> ()
    }) : (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 3 - Lowering ops.par_loop to extract data values

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
    
    %dat = "ops.extract_arg_dat"(%ops_arg1) : (!llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    
    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    
    %data_ref = "ops.ptr_to_memref"(%data_ptr) : (!llvm.ptr) -> memref<8x1xf64>
    
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x1xf64>) -> !stencil.field<[0,8]x[0,1]xf64>
    
    "ops.compute"(%data_field, %data_ref) ({
      %0 = arith.constant 0.000000e+00 : f64
      "ops.yield"(%0) : (f64) -> ()
    }) : (!stencil.field<[0,8]x[0,1]xf64>, memref<8x1xf64>) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 4 - lower ops.compute to the stencil computation

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !2, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
  
    %dat = "ops.extract_arg_dat"(%ops_arg1) : (!llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
  
    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
  
    %data_ref = "ops.ptr_to_memref"(%data_ptr) : (!llvm.ptr) -> memref<8x1xf64>
  
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x1xf64>) -> !stencil.field<[0,8]x[0,1]xf64>
  
    %temp = stencil.load %data_field : !stencil.field<[0,8]x[0,1]xf64> -> !stencil.temp<[0,8]x[0,1]xf64>
  
    %apply = stencil.apply() -> (!stencil.temp<[0,8]x[0,1]xf64>) {
      %0 = arith.constant 0.000000e+00 : f64
      stencil.return %0 : f64
    } to <[0, 0], [8, 1]>
  
    stencil.store %apply to %data_field() : !stencil.temp<[0,8]x[0,1]xf64> to !stencil.field<[0,8]x[0,1]xf64>
  
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 5 - Lower leftover ops operations

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !2, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
    
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    
    %data_ptr = "llvm.extractvalue"(%dat) <{position = array<i64: 10>}> : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    
    %data_ref = memref.reinterpret_cast %data_ptr to offset: [0], sizes: [8, 1], strides: [1, 1] : !llvm.ptr to memref<8x1xf64>
    
    %data_field = stencil.cast %data_ref : memref<8x1xf64> -> !stencil.field<[0,8]x[0,1]xf64>
    
    %temp = stencil.load %data_field : !stencil.field<[0,8]x[0,1]xf64> -> !stencil.temp<[0,8]x[0,1]xf64>
    
    %apply = stencil.apply() -> (!stencil.temp<[0,8]x[0,1]xf64>) {
      %0 = arith.constant 0.000000e+00 : f64
      stencil.return %0 : f64
    } to <[0, 0], [8, 1]>
    
    stencil.store %apply to %data_field() : !stencil.temp<[0,8]x[0,1]xf64> to !stencil.field<[0,8]x[0,1]xf64>
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}

// Phase 5 - Stencil bufferize

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
    
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    
    %data_ptr = "llvm.extractvalue"(%dat) <{position = array<i64: 10>}> : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    
    %data_ref = memref.reinterpret_cast %data_ptr to offset: [0], sizes: [8, 1], strides: [1, 1] : !llvm.ptr to memref<8x1xf64>
    
    %data_field = stencil.cast %data_ref : memref<8x1xf64> -> !stencil.field<[0,8]x[0,1]xf64>
    
    stencil.apply() outs (%data_field : !stencil.field<[0,8]x[0,1]xf64>) {
      %0 = arith.constant 0.000000e+00 : f64
      stencil.return %0 : f64
    } to <[0, 0], [8, 1]>
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 6 - Lower stencil

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
    
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    
    %data_ptr = "llvm.extractvalue"(%dat) <{position = array<i64: 10>}> : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    
    %data_ref = memref.reinterpret_cast %data_ptr to offset: [0], sizes: [8, 1], strides: [1, 1] : !llvm.ptr to memref<8x1xf64>
    
    %data_field = "memref.cast"(%data_ref) : (memref<8x1xf64>) -> memref<8x1xf64>
    
    %0 = memref.subview %data_field[0, 0] [8, 1] [1, 1] : memref<8x1xf64> to memref<8x1xf64, strided<[1, 1]>>
    %1 = arith.constant 0 : index
    %2 = arith.constant 0 : index
    %3 = arith.constant 1 : index
    %4 = arith.constant 1 : index
    %5 = arith.constant 8 : index
    %6 = arith.constant 1 : index
    
    "scf.parallel"(%1, %2, %5, %6, %3, %4) <{operandSegmentSizes = array<i32: 2, 2, 2, 0>}> ({
    ^bb1(%7 : index, %8 : index):
      %9 = arith.constant 0.000000e+00 : f64
      memref.store %9, %0[%7, %8] : memref<8x1xf64, strided<[1, 1]>>
      scf.reduce
    }) : (index, index, index, index, index, index) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}

// Phase 7 - Lower the data pointer to memref

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
    
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    
    %data_ptr = "llvm.extractvalue"(%dat) <{position = array<i64: 10>}> : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    
    %0 = arith.constant 0 : i64
    %1 = arith.constant 8 : i64
    %2 = arith.constant 1 : i64
    
    %3 = "llvm.mlir.undef"() : () -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %4 = "llvm.insertvalue"(%3, %data_ptr) <{position = array<i64: 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %5 = "llvm.insertvalue"(%4, %data_ptr) <{position = array<i64: 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %6 = "llvm.insertvalue"(%5, %0) <{position = array<i64: 2>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %7 = "llvm.insertvalue"(%6, %1) <{position = array<i64: 3, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %8 = "llvm.insertvalue"(%7, %2) <{position = array<i64: 3, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %9 = "llvm.insertvalue"(%8, %2) <{position = array<i64: 4, 0>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    %10 = "llvm.insertvalue"(%9, %2) <{position = array<i64: 4, 1>}> : (!llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>, i64) -> !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)>
    
    %data_ref = builtin.unrealized_conversion_cast %10 : !llvm.struct<(!llvm.ptr, !llvm.ptr, i64, !llvm.array<2 x i64>, !llvm.array<2 x i64>)> to memref<8x1xf64>
    
    %data_field = "memref.cast"(%data_ref) : (memref<8x1xf64>) -> memref<8x1xf64>
    
    %11 = memref.subview %data_field[0, 0] [8, 1] [1, 1] : memref<8x1xf64> to memref<8x1xf64, strided<[1, 1]>>
    %12 = arith.constant 0 : index
    %13 = arith.constant 0 : index
    %14 = arith.constant 1 : index
    %15 = arith.constant 1 : index
    %16 = arith.constant 8 : index
    %17 = arith.constant 1 : index
    
    "scf.parallel"(%12, %13, %16, %17, %14, %15) <{operandSegmentSizes = array<i32: 2, 2, 2, 0>}> ({
    ^bb1(%18 : index, %19 : index):
      %20 = arith.constant 0.000000e+00 : f64
      memref.store %20, %11[%18, %19] : memref<8x1xf64, strided<[1, 1]>>
      scf.reduce
    }) : (index, index, index, index, index, index) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}


//////////////////////////////////////////////////////
/////////////////////////// MLIR PIPELINE (sequential)
//////////////////////////////////////////////////////


module {
  llvm.func @ops_par_loop_set_zero(%arg0: !llvm.ptr, %arg1: !llvm.struct<"struct.ops_block", (i32, i32, ptr, ptr)>, %arg2: i32, %arg3: !llvm.ptr, %arg4: !llvm.struct<"struct.ops_arg", (struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>, i32, i32, ptr, ptr, i32, i32)>) {
    %0 = llvm.mlir.constant(0.000000e+00 : f64) : f64
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(1 : index) : i64
    %3 = llvm.mlir.constant(0 : index) : i64
    %4 = llvm.extractvalue %arg4[0, 10] : !llvm.struct<"struct.ops_arg", (struct<"struct.ops_dat", (i32, ptr, i32, i32, i32, array<5 x i32>, array<5 x i32>, array<5 x i32>, array<5 x i32>, i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, array<5 x i32>)>, i32, i32, ptr, ptr, i32, i32)> 
    llvm.br ^bb1(%3 : i64)
  ^bb1(%5: i64):  // 2 preds: ^bb0, ^bb5
    %6 = llvm.icmp "slt" %5, %1 : i64
    llvm.cond_br %6, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%3 : i64)
  ^bb3(%7: i64):  // 2 preds: ^bb2, ^bb4
    %8 = llvm.icmp "slt" %7, %2 : i64
    llvm.cond_br %8, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %9 = llvm.add %5, %7 overflow<nsw, nuw> : i64
    %10 = llvm.getelementptr inbounds|nuw %4[%9] : (!llvm.ptr, i64) -> !llvm.ptr, f64
    llvm.store %0, %10 : f64, !llvm.ptr
    %11 = llvm.add %7, %2 : i64
    llvm.br ^bb3(%11 : i64)
  ^bb5:  // pred: ^bb3
    %12 = llvm.add %5, %2 : i64
    llvm.br ^bb1(%12 : i64)
  ^bb6:  // pred: ^bb1
    llvm.return
  }
}

