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

def main():
    print("=== OPS dialect example IR ===")
    print_ops_ir()


if __name__ == "__main__":
    main()
