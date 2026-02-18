from util import Findable
from strategy import Strategy
from store import Application, Program
from ops_dialect.generate_ir import create_function, add_ops_operations
from xdsl.context import Context
from ops_dialect.lower_par_loop import LowerParLoopPass
from ops_dialect.lower_compute import LowerComputePass
from ops_dialect.lower_extractions import LowerOpsExtractionsPass
from ops_dialect.lower_ptr_to_memref import LowerPtrToMemrefPass
from xdsl.transforms.experimental.convert_stencil_to_ll_mlir import ConvertStencilToLLMLIRPass
from xdsl.transforms.stencil_bufferize import StencilBufferize

from xdsl.printer import Printer
from io import StringIO
from mlir.passmanager import PassManager as MLIRPassManager
from mlir import ir as mlir_ir
from xdsl.passes import PassManager as xDSLPassManager

import ops
from typing import Tuple

"""Abstract class for a lowering pipeline"""

class Pipeline(Findable):
    strategy: Strategy

    def __str__(self) -> str:
        return self.strategy.name
    
    # Function to parse kernel details and return MLIR operations
    def parseKernelC(
        self,
        loop: ops.Loop,
        kernel_idx: int
    ) -> str:
        # To be implemented
        pass

    def parseKernelFortran(
        self,
        loop: ops.Loop,
        kernel_idx: int
    ) -> str:
        # To be implemented
        pass
    
    def runPipeline(
        self,
        loop: ops.Loop,
        program: Program,
        app: Application,
        kernel_idx: int,
        force_soa: bool
    ) -> str:
        # Translate the kernel
        # if (self.lang.name == "C++"):
        #     kernel_module = self.parseKernelC(loop, kernel_idx)

        # elif (self.lang.name == "Fortran"):
        #     kernel_module = self.parseKernelFortran(loop, kernel_idx)

        # TODO: implement kernel function parser
        kernel_module = None

        # Build starting IR
        xdsl_ctx = Context()

        ir_module = create_function(loop.kernel)
        ir_module = add_ops_operations(ir_module)


        pm = xDSLPassManager()
        pm.add_pass(LowerParLoopPass())
        pm.add_pass(LowerComputePass())
        pm.add_pass(LowerOpsExtractionsPass())
        pm.add_pass(LowerPtrToMemrefPass())
        pm.add_pass(StencilBufferize())
        pm.add_pass(ConvertStencilToLLMLIRPass())

        pm.apply(xdsl_ctx, ir_module)

        mlir_module, mlir_ctx = self.convertToMLIRModule(ir_module)

        # Do strategy-specific lowering
        result = self.run_mlir_passes(mlir_module, mlir_ctx)

        return result
    

    def convertToMLIRModule(self, xdsl_module) -> str:
        """Convert an xDSL module to MLIR textual representation."""
        buf = StringIO()
        Printer(stream=buf).print_op(xdsl_module)

        ctx = mlir_ir.Context()
        mlir_module = mlir_ir.Module.parse(buf.getvalue(), context=ctx)

        return mlir_module, ctx


    def run_mlir_passes(
        self,
        mlir_module: str,
        ctx: Context
    ) -> str:
        """Run a list of MLIR passes on the MLIR module."""
        passes = self.passes()

        op = mlir_module.operation

        pm = MLIRPassManager(context=ctx)

        for p in passes:
            pm.add(p)
        pm.run(op)

        return str(mlir_module)


    def matches(self, strat: Strategy) -> bool:
        return self.strategy == strat

    def passes(self):
        pass


# Import and register concrete pipeline implementations
# This happens automatically when the Pipeline class is imported
from pipelines import CPUSequential, OpenMP, GPUCUDA

Pipeline.register(CPUSequential)
Pipeline.register(OpenMP)
Pipeline.register(GPUCUDA)
