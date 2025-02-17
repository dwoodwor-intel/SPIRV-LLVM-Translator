; RUN: llvm-as -opaque-pointers=0 %s -o %t.bc
; RUN: llvm-spirv %t.bc -spirv-text -o - | FileCheck %s --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: llvm-spirv -r %t.spv --spirv-target-env=SPV-IR -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-SPV-IR
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM

target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir"

; Function Attrs: convergent nounwind
define spir_kernel void @k(i32 addrspace(1)* %a) #0 !kernel_arg_addr_space !4 !kernel_arg_access_qual !5 !kernel_arg_type !6 !kernel_arg_type_qual !7 !kernel_arg_base_type !6 !spirv.ParameterDecorations !10 {
entry:
  ret void
}

; CHECK-SPIRV: Decorate [[PId:[0-9]+]] Volatile
; CHECK-SPIRV: Decorate [[PId]] FuncParamAttr 4
; CHECK-SPIRV: FunctionParameter {{[0-9]+}} [[PId]]

!llvm.module.flags = !{!0}
!opencl.ocl.version = !{!1}
!opencl.spir.version = !{!2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, i32 0}
!2 = !{i32 1, i32 2}
!3 = !{!"clang version 14.0.0"}
!4 = !{i32 0, i32 0, i32 0}
!5 = !{!"none"}
!6 = !{!"int*"}
!7 = !{!"volatile"}
!8 = !{i32 38, i32 4} ; FuncParamAttr NoAlias
!9 = !{!8}
!10 = !{!9}

; CHECK-SPV-IR: define spir_kernel void @k(i32 addrspace(1)* noalias %a)
; CHECK-SPV-IR-SAME: !kernel_arg_type_qual ![[KernelArgTypeQual:[0-9]+]]
; CHECK-SPV-IR-SAME: !spirv.ParameterDecorations ![[ParamDecoListId:[0-9]+]]
; CHECK-SPV-IR-DAG: ![[ParamDecoListId]] = !{![[ParamDecoId:[0-9]+]]}
; CHECK-SPV-IR-DAG: ![[ParamDecoId]] = !{![[VolatileDecoId:[0-9]+]], ![[NoAliasDecoId:[0-9]+]]}
; CHECK-SPV-IR-DAG: ![[NoAliasDecoId]] = !{i32 38, i32 4}
; CHECK-SPV-IR-DAG: ![[VolatileDecoId]] = !{i32 21}
; CHECK-SPV-IR-DAG: ![[KernelArgTypeQual]] = !{!"volatile restrict"}

; CHECK-LLVM-NOT: !spirv.ParameterDecorations
; CHECK-LLVM: define spir_kernel void @k(i32 addrspace(1)* noalias %a) {{.*}} !kernel_arg_type_qual ![[KernelArgTypeQual:[0-9]+]] {{.*}} {
; CHECK-LLVM-DAG: ![[KernelArgTypeQual]] = !{!"volatile restrict"}
