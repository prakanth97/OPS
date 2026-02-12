from generate_ir import create_function, add_ops_operations
from xdsl.context import Context
from lower_par_loop import LowerParLoopPass
from lower_compute import LowerComputePass
from lower_extractions import LowerOpsExtractionsPass

def main():

    # initial code for testing passes to create set_zero kernel

    llvm_module = create_function("set_zero")
    ctx = Context()

    llvm_module = add_ops_operations(llvm_module)

    new_pass = LowerParLoopPass()
    new_pass.apply(ctx, llvm_module)

    next_pass = LowerComputePass()
    next_pass.apply(ctx, llvm_module)

    yet_another_pass = LowerOpsExtractionsPass()
    yet_another_pass.apply(ctx, llvm_module)

    print(llvm_module)

if __name__ == "__main__":
    main()
