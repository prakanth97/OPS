from generate_ir import create_function, add_ops_operations
from xdsl.context import Context
from lower_par_loop import LowerParLoopPass

def main():

    # initial code for testing set_zero kernel
    llvm_module = create_function("set_zero")

    llvm_module = add_ops_operations(llvm_module)

    new_pass = LowerParLoopPass()
    ctx = Context()

    new_pass.apply(ctx, llvm_module)

    print(llvm_module)

if __name__ == "__main__":
    main()
