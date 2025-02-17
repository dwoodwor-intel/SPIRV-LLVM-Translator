; RUN: llvm-as -opaque-pointers=0 < %s -o %t.bc
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: llvm-spirv -r %t.spv -o - | llvm-dis -o %t.ll

; RUN: llc -mtriple=%triple -filetype=asm -fast-isel=false -O0 < %t.ll | FileCheck %s
;
; Generated by:
; clang -emit-llvm -S -g test.cpp

; typedef double         fp_t;
; typedef unsigned long  int_t;
;
; int_t glb_start      = 17;
; int_t glb_end        = 42;
;
; int main()
; {
;   int_t start = glb_start;
;   int_t end   = glb_end;
;
;   fp_t dbl_start = (fp_t) start;
;   fp_t dbl_end   = (fp_t) end;
;
;   return 0;
; }

; SelectionDAG performs CSE on constant pool loads. Make sure line numbers
; from such nodes are not propagated. Doing so results in oscillating line numbers.

; CHECK: .loc 1 12
; CHECK: .loc 1 13
; CHECK-NOT: .loc 1 12

; ModuleID = 't.cpp'
source_filename = "test/DebugInfo/X86/isel-cse-line.ll"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "spir64-unknown-unknown"

@glb_start = global i64 17, align 8, !dbg !0
@glb_end = global i64 42, align 8, !dbg !9

define i32 @main() !dbg !16 {
  %1 = alloca i32, align 4
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  %4 = alloca double, align 8
  %5 = alloca double, align 8
  store i32 0, i32* %1, align 4
  call void @llvm.dbg.declare(metadata i64* %2, metadata !20, metadata !21), !dbg !22
  %6 = load i64, i64* @glb_start, align 8, !dbg !23
  store i64 %6, i64* %2, align 8, !dbg !22
  call void @llvm.dbg.declare(metadata i64* %3, metadata !24, metadata !21), !dbg !25
  %7 = load i64, i64* @glb_end, align 8, !dbg !26
  store i64 %7, i64* %3, align 8, !dbg !25
  call void @llvm.dbg.declare(metadata double* %4, metadata !27, metadata !21), !dbg !28
  %8 = load i64, i64* %2, align 8, !dbg !29
  %9 = uitofp i64 %8 to double, !dbg !29
  store double %9, double* %4, align 8, !dbg !28
  call void @llvm.dbg.declare(metadata double* %5, metadata !30, metadata !21), !dbg !31
  %10 = load i64, i64* %3, align 8, !dbg !32
  %11 = uitofp i64 %10 to double, !dbg !32
  store double %11, double* %5, align 8, !dbg !31
  ret i32 0, !dbg !33
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

attributes #0 = { nounwind readnone }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!13, !14}
!llvm.ident = !{!15}

!0 = distinct !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = !DIGlobalVariable(name: "glb_start", scope: !2, file: !3, line: 4, type: !11, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !3, producer: "clang version 3.9.0 (trunk 268246)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !5, globals: !8)
!3 = !DIFile(filename: "/home/wpieb/test/D12094.cpp", directory: "/home/wpieb/build/llvm/trunk/llvm-RelWithDebInfo")
!4 = !{}
!5 = !{!6}
!6 = !DIDerivedType(tag: DW_TAG_typedef, name: "fp_t", file: !3, line: 1, baseType: !7)
!7 = !DIBasicType(name: "double", size: 64, align: 64, encoding: DW_ATE_float)
!8 = !{!0, !9}
!9 = distinct !DIGlobalVariableExpression(var: !10, expr: !DIExpression())
!10 = !DIGlobalVariable(name: "glb_end", scope: !2, file: !3, line: 5, type: !11, isLocal: false, isDefinition: true)
!11 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_t", file: !3, line: 2, baseType: !12)
!12 = !DIBasicType(name: "long unsigned int", size: 64, align: 64, encoding: DW_ATE_unsigned)
!13 = !{i32 2, !"Dwarf Version", i32 4}
!14 = !{i32 2, !"Debug Info Version", i32 3}
!15 = !{!"clang version 3.9.0 (trunk 268246)"}
!16 = distinct !DISubprogram(name: "main", scope: !3, file: !3, line: 7, type: !17, isLocal: false, isDefinition: true, scopeLine: 8, flags: DIFlagPrototyped, isOptimized: false, unit: !2, retainedNodes: !4)
!17 = !DISubroutineType(types: !18)
!18 = !{!19}
!19 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!20 = !DILocalVariable(name: "start", scope: !16, file: !3, line: 9, type: !11)
!21 = !DIExpression()
!22 = !DILocation(line: 9, column: 9, scope: !16)
!23 = !DILocation(line: 9, column: 17, scope: !16)
!24 = !DILocalVariable(name: "end", scope: !16, file: !3, line: 10, type: !11)
!25 = !DILocation(line: 10, column: 9, scope: !16)
!26 = !DILocation(line: 10, column: 17, scope: !16)
!27 = !DILocalVariable(name: "dbl_start", scope: !16, file: !3, line: 12, type: !6)
!28 = !DILocation(line: 12, column: 8, scope: !16)
!29 = !DILocation(line: 12, column: 27, scope: !16)
!30 = !DILocalVariable(name: "dbl_end", scope: !16, file: !3, line: 13, type: !6)
!31 = !DILocation(line: 13, column: 8, scope: !16)
!32 = !DILocation(line: 13, column: 27, scope: !16)
!33 = !DILocation(line: 15, column: 3, scope: !16)

