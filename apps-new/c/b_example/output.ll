; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

%struct.ident_t = type { i32, i32, i32, i32, ptr }
%struct.ops_arg = type { ptr, ptr, i32, i32, ptr, ptr, i32, i32, i32 }
%struct.ops_dat = type { i32, ptr, i32, i32, i32, [5 x i32], [5 x i32], [5 x i32], [5 x i32], i32, ptr, ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i64, i64, [5 x i32] }

@0 = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@1 = private unnamed_addr constant %struct.ident_t { i32 0, i32 2, i32 0, i32 22, ptr @0 }, align 8
@2 = private unnamed_addr constant %struct.ident_t { i32 0, i32 66, i32 0, i32 22, ptr @0 }, align 8

declare ptr @malloc(i64)

define void @ops_par_loop_set_zero(ptr %0, ptr %1, i32 %2, ptr %3, ptr %4) {  ; <-- Changed last param to ptr
  %structArg = alloca { ptr }, align 8
  %arg_loaded = load %struct.ops_arg, ptr %4, align 8 ; <-- Load here instead
  %6 = extractvalue %struct.ops_arg %arg_loaded, 0
; define void @ops_par_loop_set_zero(ptr %0, ptr %1, i32 %2, ptr %3, %struct.ops_arg %4) {
;   %structArg = alloca { ptr }, align 8
;   %6 = extractvalue %struct.ops_arg %4, 0
  %7 = getelementptr %struct.ops_dat, ptr %6, i32 0, i32 10
  %8 = load ptr, ptr %7, align 8
  %9 = getelementptr i8, ptr %8, i32 72
  br label %entry

entry:                                            ; preds = %5
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(ptr @1)
  br label %omp_parallel

omp_parallel:                                     ; preds = %entry
  %gep_ = getelementptr { ptr }, ptr %structArg, i32 0, i32 0
  store ptr %9, ptr %gep_, align 8
  call void (ptr, i32, ptr, ...) @__kmpc_fork_call(ptr @1, i32 1, ptr @ops_par_loop_set_zero..omp_par, ptr %structArg)
  br label %omp.par.exit

omp.par.exit:                                     ; preds = %omp_parallel
  ret void
}

; Function Attrs: nounwind
define internal void @ops_par_loop_set_zero..omp_par(ptr noalias %tid.addr, ptr noalias %zero.addr, ptr %0) #0 {
omp.par.entry:
  %gep_ = getelementptr { ptr }, ptr %0, i32 0, i32 0
  %loadgep_ = load ptr, ptr %gep_, align 8, !align !1
  %p.lastiter = alloca i32, align 4
  %p.lowerbound = alloca i64, align 8
  %p.upperbound = alloca i64, align 8
  %p.stride = alloca i64, align 8
  %tid.addr.local = alloca i32, align 4
  %1 = load i32, ptr %tid.addr, align 4
  store i32 %1, ptr %tid.addr.local, align 4
  %tid = load i32, ptr %tid.addr.local, align 4
  br label %omp.region.after_alloca2

omp.region.after_alloca2:                         ; preds = %omp.par.entry
  br label %omp.region.after_alloca

omp.region.after_alloca:                          ; preds = %omp.region.after_alloca2
  br label %omp.par.region

omp.par.region:                                   ; preds = %omp.region.after_alloca
  br label %omp.par.region1

omp.par.region1:                                  ; preds = %omp.par.region
  br label %omp.wsloop.region

omp.wsloop.region:                                ; preds = %omp.par.region1
  br label %omp_loop.preheader

omp_loop.preheader:                               ; preds = %omp.wsloop.region
  br label %omp_collapsed.preheader

omp_collapsed.preheader:                          ; preds = %omp_loop.preheader
  store i64 0, ptr %p.lowerbound, align 4
  store i64 63, ptr %p.upperbound, align 4
  store i64 1, ptr %p.stride, align 4
  %omp_global_thread_num15 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_for_static_init_8u(ptr @1, i32 %omp_global_thread_num15, i32 34, ptr %p.lastiter, ptr %p.lowerbound, ptr %p.upperbound, ptr %p.stride, i64 1, i64 0)
  %2 = load i64, ptr %p.lowerbound, align 4
  %3 = load i64, ptr %p.upperbound, align 4
  %4 = sub i64 %3, %2
  %5 = add i64 %4, 1
  br label %omp_collapsed.header

omp_collapsed.header:                             ; preds = %omp_collapsed.inc, %omp_collapsed.preheader
  %omp_collapsed.iv = phi i64 [ 0, %omp_collapsed.preheader ], [ %omp_collapsed.next, %omp_collapsed.inc ]
  br label %omp_collapsed.cond

omp_collapsed.cond:                               ; preds = %omp_collapsed.header
  %omp_collapsed.cmp = icmp ult i64 %omp_collapsed.iv, %5
  br i1 %omp_collapsed.cmp, label %omp_collapsed.body, label %omp_collapsed.exit

omp_collapsed.exit:                               ; preds = %omp_collapsed.cond
  call void @__kmpc_for_static_fini(ptr @1, i32 %omp_global_thread_num15)
  %omp_global_thread_num16 = call i32 @__kmpc_global_thread_num(ptr @1)
  call void @__kmpc_barrier(ptr @2, i32 %omp_global_thread_num16)
  br label %omp_collapsed.after

omp_collapsed.after:                              ; preds = %omp_collapsed.exit
  br label %omp_loop.after

omp_loop.after:                                   ; preds = %omp_collapsed.after
  br label %omp.region.cont3

omp.region.cont3:                                 ; preds = %omp_loop.after
  br label %omp.region.cont

omp.region.cont:                                  ; preds = %omp.region.cont3
  br label %omp.par.pre_finalize

omp.par.pre_finalize:                             ; preds = %omp.region.cont
  br label %.fini

.fini:                                            ; preds = %omp.par.pre_finalize
  br label %omp.par.exit.exitStub

omp_collapsed.body:                               ; preds = %omp_collapsed.cond
  %6 = add i64 %omp_collapsed.iv, %2
  %7 = urem i64 %6, 8
  %8 = udiv i64 %6, 8
  br label %omp_loop.body

omp_loop.body:                                    ; preds = %omp_collapsed.body
  %9 = mul i64 %8, 1
  %10 = add i64 %9, 0
  br label %omp_loop.preheader4

omp_loop.preheader4:                              ; preds = %omp_loop.body
  br label %omp_loop.body7

omp_loop.body7:                                   ; preds = %omp_loop.preheader4
  %11 = mul i64 %7, 1
  %12 = add i64 %11, 0
  br label %omp.loop_nest.region

omp.loop_nest.region:                             ; preds = %omp_loop.body7
  %13 = mul nsw i64 %10, 8
  %14 = add nsw i64 %13, %12
  %15 = getelementptr inbounds double, ptr %loadgep_, i64 %14
  store double 8.000000e+00, ptr %15, align 8
  br label %omp.region.cont14

omp.region.cont14:                                ; preds = %omp.loop_nest.region
  br label %omp_loop.after10

omp_loop.after10:                                 ; preds = %omp.region.cont14
  br label %omp_collapsed.inc

omp_collapsed.inc:                                ; preds = %omp_loop.after10
  %omp_collapsed.next = add i64 %omp_collapsed.iv, 1
  br label %omp_collapsed.header

omp.par.exit.exitStub:                            ; preds = %.fini
  ret void
}

define void @_mlir_ciface_ops_par_loop_set_zero(ptr %0, ptr %1, ptr %2, ptr %3, ptr %4) {
  %6 = load i32, ptr %2, align 4
  call void @ops_par_loop_set_zero(ptr %0, ptr %1, i32 %6, ptr %3, ptr %4)  ;// <-- Pass ptr directly
  ret void
}

; define void @_mlir_ciface_ops_par_loop_set_zero(ptr %0, ptr %1, ptr %2, ptr %3, ptr %4) {
;   %6 = load i32, ptr %2, align 4
;   %7 = load %struct.ops_arg, ptr %4, align 8
;   call void @ops_par_loop_set_zero(ptr %0, ptr %1, i32 %6, ptr %3, %struct.ops_arg %7)
;   ret void
; }

; Function Attrs: nounwind
declare i32 @__kmpc_global_thread_num(ptr) #0

; Function Attrs: nounwind
declare void @__kmpc_for_static_init_8u(ptr, i32, i32, ptr, ptr, ptr, ptr, i64, i64) #0

; Function Attrs: nounwind
declare void @__kmpc_for_static_fini(ptr, i32) #0

; Function Attrs: convergent nounwind
declare void @__kmpc_barrier(ptr, i32) #1

; Function Attrs: nounwind
declare !callback !2 void @__kmpc_fork_call(ptr, i32, ptr, ...) #0

attributes #0 = { nounwind }
attributes #1 = { convergent nounwind }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = !{i64 1}
!2 = !{!3}
!3 = !{i64 2, i64 -1, i64 -1, i1 true}
