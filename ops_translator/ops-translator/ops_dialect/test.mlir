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
    
    %data_ref = "ops.ptr_to_memref"(%data_ptr) : (!llvm.ptr) -> memref<8x8xf64>
    
    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x8xf64>) -> !stencil.field<[-1,7]x[-1,0]xf64>
    
    "ops.compute"(%data_field, %data_ref) ({
      %0 = arith.constant 0.000000e+00 : f64
      "ops.yield"(%0) : (f64) -> ()
    }) : (!stencil.field<[-1,7]x[-1,0]xf64>, memref<8x8xf64>) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 4 - lower ops.compute to the stencil computation

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.p, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):

    %dat = "ops.extract_arg_dat"(%ops_arg1) : (!llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>

    %data_ptr = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr

    %data_ref = "ops.ptr_to_memref"(%data_ptr) : (!llvm.ptr) -> memref<8x8xf64>

    %data_field = "ops.memref_to_field"(%data_ref) : (memref<8x8xf64>) -> !stencil.field<[-1,7]x[-1,0]xf64>

    %temp = stencil.load %data_field : !stencil.field<[-1,7]x[-1,0]xf64> -> !stencil.temp<[-1,7]x[-1,0]xf64>

    %apply = stencil.apply() -> (!stencil.temp<[-1,7]x[-1,0]xf64>) {
      %0 = arith.constant 0.000000e+00 : f64
      stencil.return %0 : f64
    } to <[-1, -1], [7, 0]>

    stencil.external_store %apply to %data_ref : !stencil.temp<[-1,7]x[-1,0]xf64> to memref<8x8xf64>

    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 5 - Lower leftover ops operations

builtin.module {
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loop_set_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>):
    
    %dat = "llvm.extractvalue"(%ops_arg1) <{position = array<i64: 0>}> : (!llvm.struct<"struct.ops_arg", (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>, i32, i32, !llvm.ptr, !llvm.ptr, i32, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
    
    %data_ptr = "llvm.extractvalue"(%dat) <{position = array<i64: 10>}> : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
    
    %data_ref = ptr_xdsl.from_ptr %data_ptr : !llvm.ptr -> memref<8x8xf64>
    
    %data_field = stencil.external_load %data_ref : memref<8x8xf64> -> !stencil.field<[-1,7]x[-1,0]xf64>
    
    %temp = stencil.load %data_field : !stencil.field<[-1,7]x[-1,0]xf64> -> !stencil.temp<[-1,7]x[-1,0]xf64>
    
    %apply = stencil.apply() -> (!stencil.temp<[-1,7]x[-1,0]xf64>) {
      %0 = arith.constant 0.000000e+00 : f64
      stencil.return %0 : f64
    } to <[-1, -1], [7, 0]>
    
    stencil.external_store %apply to %data_ref : !stencil.temp<[-1,7]x[-1,0]xf64> to memref<8x8xf64>
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}