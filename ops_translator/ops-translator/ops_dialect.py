from xdsl.ir import Dialect

from xdsl.ir import SSAValue, TypeAttribute, ParametrizedAttribute
from xdsl.irdl import (
    IRDLOperation,
    param_def,
    irdl_op_definition,
    irdl_attr_definition,
    operand_def,
    var_operand_def,
    attr_def,
)

from xdsl.dialects.builtin import (
    StringAttr,
    IntegerAttr,
    SymbolRefAttr,
    DenseIntElementsAttr,
    IndexType,
    VectorType,
    ModuleOp,
)

from xdsl.builder import Builder, InsertPoint
from xdsl.dialects.arith import ConstantOp
from xdsl.dialects.func import FuncOp, ReturnOp

from xdsl.dialects.llvm import LLVMStructType, LLVMArrayType, LLVMPointerType, i32
from xdsl.dialects.llvm import LLVMFunctionType, LLVMPointerType, LLVMVoidType
from xdsl.dialects.llvm import FuncOp, DictionaryAttr, UnitAttr, ArrayAttr, LinkageAttr#, LLVMByValAttr, LLVMAlignAttr, LLVMNoUndefAttr
from xdsl.ir import Attribute

from xdsl.dialects.llvm import LLVMStructType

from xdsl.dialects.builtin import ModuleOp


from xdsl.dialects.func import FuncOp
from xdsl.dialects.builtin import (
    ModuleOp,
    FunctionType,
    StringAttr,
)
from xdsl.ir import Attribute
from xdsl.dialects.builtin import IntegerType
from xdsl.dialects.builtin import OpaqueAttr

# from xdsl.ir import StringAttr, ArrayAttr





@irdl_attr_definition
class OpsBlockType(ParametrizedAttribute, TypeAttribute):
    name = "ops.block"

@irdl_attr_definition
class OpsArgType(ParametrizedAttribute, TypeAttribute):
    name = "ops.arg"

    access_mode: StringAttr = param_def(StringAttr)

    def __init__(self, access_mode: str | StringAttr = "read"):
        if isinstance(access_mode, str):
            access_mode = StringAttr(access_mode)
        super().__init__(access_mode)


@irdl_op_definition
class ParLoopOp(IRDLOperation):
    name = "ops.par_loop"

    # operands
    block = operand_def()
    range_val = operand_def()
    args = var_operand_def()

    # attributes
    kernel = attr_def(SymbolRefAttr)
    kernel_name = attr_def(StringAttr)
    dims = attr_def(IntegerAttr)

    # for pretty printing
    # assembly_format = "$block `(` $args `)` attr-dict `:` `(` type($block) `,` type($args) `)` `->` `(` `)`"
    assembly_format = "`(` $block `,` $range_val `,` $args `)` attr-dict `:` `(` type($block) `,` type($range_val) `,` type($args) `)` `->` `(` `)`"


    def __init__(
        self,
        block: SSAValue,
        range_val: SSAValue,
        args: list[SSAValue],
        *,
        kernel: SymbolRefAttr,
        kernel_name: str,
        dims: int,
    ):
        super().__init__(
            operands=[block, range_val, args],
            attributes={
                "kernel": kernel,
                "kernel_name": StringAttr(kernel_name),
                "dims": IntegerAttr(dims, IndexType()),
            },
        )


def emit_ops_example_ir() -> ModuleOp:
    module = ModuleOp([])

    builder = Builder(InsertPoint.at_end(module.body.block))

    # Create a dummy function
    block_type = OpsBlockType()
    arg_type = OpsArgType("read")

    func = FuncOp(
        "ops_par_loop_example_kernel",
        (
            [block_type, arg_type, arg_type],
            [],
        ),
    )
    builder.insert(func)

    func.args[0].name_hint = "block"
    func.args[1].name_hint = "arg0"
    func.args[2].name_hint = "arg1"

    builder.insertion_point = InsertPoint.at_end(func.body.block)

    block_val = func.args[0]
    ops_args = [func.args[1], func.args[2]]

    range_val = builder.insert(
        ConstantOp(
            DenseIntElementsAttr.from_list(
                VectorType(IndexType(), [4]), [0, 128, 0, 128]
            )
        )
    ).result

    builder.insert(
        ParLoopOp(
            block=block_val,
            range_val=range_val,
            args=ops_args,
            kernel=SymbolRefAttr("example_kernel"),
            kernel_name="example_kernel",
            dims=2,
        )
    )

    builder.insert(ReturnOp())

    return module




def print_ops_ir():
    module = emit_ops_example_ir()

    # Verify correctness
    # module.verify()

    # Print IR
    print(module)


def create_wrapper_function():

    ops_arg_ty = LLVMStructType(
        StringAttr("struct.ops_arg"),  # struct_name
        ArrayAttr([]),                 # empty → opaque
    )

    fn_type = LLVMFunctionType(
        inputs=[
            LLVMPointerType(),  # char*
            LLVMPointerType(),  # ops_block (ptr)
            i32,                       # int
            LLVMPointerType(),  # int*
            LLVMPointerType(),  # byval ops_arg
        ],
        output=LLVMVoidType()
    )

    arg_attrs = ArrayAttr([
        DictionaryAttr({  # arg 0
            "llvm.noundef": UnitAttr(),
        }),
        DictionaryAttr({  # arg 1
            "llvm.noundef": UnitAttr(),
        }),
        DictionaryAttr({  # arg 2
            "llvm.noundef": UnitAttr(),
        }),
        DictionaryAttr({  # arg 3
            "llvm.noundef": UnitAttr(),
        }),
        DictionaryAttr({  # arg 4
            "llvm.noundef": UnitAttr(),
            "llvm.byval": ops_arg_ty,
            "llvm.align": IntegerAttr(8, 64),
        }),
    ])

    fn = FuncOp(
        sym_name="ops_par_loop_set_zero",
        function_type=fn_type,
        linkage=LinkageAttr("external"),
        visibility=0,  # default visibility
        other_props={
            "arg_attrs": arg_attrs,
        },
    )

    llvm_module = ModuleOp([fn])

    return llvm_module

def create_wrapper_function_func():

    # ---- High-level, ABI-agnostic types ----

    ptr_ty = OpaqueAttr("ptr")  # placeholder pointer-like type
    i32_ty = IntegerType(32)

    # Represent ops_arg *by-value* semantically
    ops_arg_ty = OpaqueAttr("ops.arg")

    fn_type = FunctionType(
        inputs=[
            ptr_ty,     # char*
            ptr_ty,     # ops_block*
            i32_ty,     # int
            ptr_ty,     # int*
            ops_arg_ty, # byval ops_arg (semantic)
        ],
        outputs=[]
    )

    fn = FuncOp(
        name="ops_par_loop_set_zero",
        function_type=fn_type,
    )

    module = ModuleOp([fn])
    return module

def add_ops_constructs(module):

    builder = Builder(InsertPoint.at_end(module.body.block))

    # Create a dummy function
    block_type = OpsBlockType()
    arg_type = OpsArgType("read")

    # get the arguments from the function in the module
    llvm_fn = next(op for op in module.body.block.ops if isinstance(op, FuncOp))


    # entry_block = llvm_fn.body.blocks[0]
    # args = entry_block.args

    args = llvm_fn.body.block.args


    # args = llvm_fn.args


    block_val = args[0]
    ops_args = [args[1], args[2]]

    range_val = builder.insert(
        ConstantOp(
            DenseIntElementsAttr.from_list(
                VectorType(IndexType(), [4]), [0, 128, 0, 128]
            )
        )
    ).result

    builder.insert(
        ParLoopOp(
            block=block_val,
            range_val=range_val,
            args=ops_args,
            kernel=SymbolRefAttr("example_kernel"),
            kernel_name="example_kernel",
            dims=2,
        )
    )

    builder.insert(ReturnOp())

    return module


def main():
    llvm_module = create_wrapper_function_func()
    # llvm_module = add_ops_constructs(llvm_module)

    print(llvm_module)
    # print("=== OPS dialect example IR ===")
    # print_ops_ir()


if __name__ == "__main__":
    main()
