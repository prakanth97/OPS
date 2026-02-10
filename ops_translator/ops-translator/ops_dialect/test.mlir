// Phase 1 - Modelling function signature

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loopset_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>):
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 2 - Add ops par loop operation

builtin.module {
  "llvm.func"() <{sym_name = "ops_par_loopset_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>):
    
    "ops.par_loop"(%name, %block, %dim, %range, %ops_arg1) ({
      %0 = arith.constant 0 : i64
      %1 = arith.constant 1 : i64
      "ops.yield"(%0, %1) : (i64, i64) -> ()
    }) : (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>) -> ()
    
    "llvm.return"() : () -> ()
  }) : () -> ()
}


// Phase 3 - Lowering to extract data values

builtin.module {
  
  "llvm.func"() <{llvm.emit_c_interface, sym_name = "ops_par_loopset_zero", function_type = !llvm.func<void (!llvm.ptr, !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, i32, !llvm.ptr, !llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>)>, CConv = #llvm.cconv<ccc>, linkage = #llvm.linkage<"external">, visibility_ = 0 : i64}> ({
  
  ^bb0(%name : !llvm.ptr, %block : !llvm.struct<"struct.ops_block", (i32, i32, !llvm.ptr, !llvm.ptr)>, %dim : i32, %range : !llvm.ptr, %ops_arg1 : !llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>):
  
    %dat = "ops.extract_arg_dat"(%ops_arg1) : (!llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>) -> !llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>
  
    %access_type = "ops.extract_arg_access"(%ops_arg1) : (!llvm.struct<"struct.ops_arg", (i32, i32, !llvm.ptr, !llvm.ptr, i32)>) -> i32
  
    %data = "ops.extract_arg_dat_data"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.ptr
  
    %size = "ops.extract_arg_dat_size"(%dat) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> !llvm.array<5 x i32>
  
    "ops.compute"(%dat) ({
      %0 = arith.constant 0 : i64
      %1 = arith.constant 1 : i64
      "ops.yield"(%0, %1) : (i64, i64) -> ()
    }) : (!llvm.struct<"struct.ops_dat", (i32, !llvm.ptr, i32, i32, i32, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, !llvm.array<5 x i32>, i32, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32, i32, !llvm.ptr, i32, i64, i64, !llvm.array<5 x i32>)>) -> ()
  
    "llvm.return"() : () -> ()
  
  }) : () -> ()
}


// Future phases - lower ops.compute to the stencil computation
