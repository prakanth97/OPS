import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent / "ops_dialect"))

from generate_ir import create_function_with_wrapper, add_ops_operations
from xdsl.context import Context
from lower_par_loop import LowerParLoopPass
from lower_compute import LowerComputePass
from lower_extractions import LowerOpsExtractionsPass
from xdsl.transforms.experimental.convert_stencil_to_ll_mlir import ConvertStencilToLLMLIRPass
from xdsl.transforms.stencil_bufferize import StencilBufferize
from lower_ptr_to_memref import LowerPtrToMemrefPass


from xdsl.transforms.convert_ptr_to_llvm import ConvertPtrToLLVMPass

import pipelines



def main():

    # initial code for testing passes to create set_zero kernel

    llvm_module = create_function_with_wrapper("set_zero")
    ctx = Context()

    llvm_module = add_ops_operations(llvm_module)

    new_pass = LowerParLoopPass()
    new_pass.apply(ctx, llvm_module)

    next_pass = LowerComputePass()
    next_pass.apply(ctx, llvm_module)

    yet_another_pass = LowerOpsExtractionsPass()
    yet_another_pass.apply(ctx, llvm_module)

    # try bufferize for when storing the result in input grid
    bufferize_pass = StencilBufferize()
    bufferize_pass.apply(ctx, llvm_module)

    stencil_pass = ConvertStencilToLLMLIRPass()
    stencil_pass.apply(ctx, llvm_module)

    passi = LowerPtrToMemrefPass()
    passi.apply(ctx, llvm_module)


    pipeline = pipelines.CPUSequential()

    mlir_module, mlir_ctx = pipeline.convertToMLIRModule(llvm_module)

    llvm_module = pipeline.run_mlir_passes(mlir_module, mlir_ctx)

    print(llvm_module)


    with open("demofile.txt", "w") as f:
        f.write(str(llvm_module))


if __name__ == "__main__":
    main()
