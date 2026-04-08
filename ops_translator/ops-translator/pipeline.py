from util import Findable
from strategy import Strategy
from store import Application, Program
from ops_dialect.generate_ir import create_function_with_wrapper, add_ops_operations
from xdsl.context import Context
from ops_dialect.lower_par_loop import LowerParLoopPass
from ops_dialect.lower_compute import LowerComputePass
from ops_dialect.lower_extractions import LowerOpsExtractionsPass
from ops_dialect.lower_ptr_to_memref import LowerPtrToMemrefPass
from ops_dialect.lower_index import LowerOpsIndexPass
import xdsl
from xdsl.transforms.experimental.convert_stencil_to_ll_mlir import ConvertStencilToLLMLIRPass
from xdsl.transforms.stencil_bufferize import StencilBufferize
from xdsl.transforms.canonicalize import CanonicalizePass
from kernel_config import KernelConfig, attachKernelInfo
from language import Lang

from xdsl.printer import Printer
from io import StringIO
from mlir.passmanager import PassManager as MLIRPassManager
from mlir import ir as mlir_ir

from mlir.dialects.llvm import translate_module_to_llvmir

from xdsl.passes import PassPipeline as xDSLPassManager

import ops
from typing import Tuple
from kernel_parser import KernelParser

"""Abstract class for a lowering pipeline"""

class Pipeline(Findable):
    strategy: Strategy
    kernel_parser = KernelParser()

    def __str__(self) -> str:
        return self.strategy.name
    
    def runPipeline(
        self,
        loop: ops.Loop,
        program: Program,
        app: Application,
        lang: Lang,
        kernel_config: KernelConfig,
        force_soa: bool
    ) -> str:
        
        # Translate the kernel
        if (lang.name == "C++"):
            kernel_info = self.kernel_parser.parseC(loop, program, app)

        elif (lang.name == "Fortran"):
            # TODO: Work on Fortran parser
            kernel_info = self.kernel_parser.parseFortran(loop, program, app)

        print(kernel_info)

        attachKernelInfo(kernel_config, kernel_info)

        kernel_config.kernel_info = kernel_info

        print("Parsed kernel module:")
        print(kernel_info)

        # self.kernel_parser.kernel_info_to_stencil_ops(kernel_info)
        print(kernel_info)
        # kernel_module = None

        # Build starting IR
        xdsl_ctx = Context()

        ir_module = create_function_with_wrapper(kernel_config)
        ir_module = add_ops_operations(ir_module, kernel_config)


        pm = xDSLPassManager([
            LowerParLoopPass(kernel_config),
            LowerComputePass(kernel_config),
            LowerOpsExtractionsPass(),
            LowerPtrToMemrefPass(),
            # StencilBufferize(), no longer needed!
            ConvertStencilToLLMLIRPass(),
            LowerOpsIndexPass(),
            CanonicalizePass(),
        ])

        pm.apply(xdsl_ctx, ir_module)

        # print(ir_module)

        # with open("demofile.mlir", "w") as f:
        #     f.write(str(ir_module))
        # exit(0)

        


        # return None
        # exit(0)
        # return ir_module
        mlir_module, mlir_ctx = self.convertToMLIRModule(ir_module)

        # print(mlir_module)
        # return None
        # Do strategy-specific lowering
        result = self.run_mlir_passes(mlir_module, mlir_ctx)

        return result
    

    def convertToMLIRModule(self, xdsl_module) -> str:
        """Convert an xDSL module to MLIR module."""
        buf = StringIO()
        Printer(stream=buf).print_op(xdsl_module)

        ctx = mlir_ir.Context()
        
        print("--------------------")
        print(xdsl_module)
        print("--------------------")

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


        with open("demofile.mlir", "w") as f:
            f.write(str(mlir_module))
        # exit(0)
        print(mlir_module)
        print("CHECK POINT --------------")

        # After your lowering passes, before mlir-translate


        # equivalent to running mlir-translate
        res = translate_module_to_llvmir(mlir_module.operation)
        with open("output.mlir", "w") as f:
            f.write(str(mlir_module))
        print("Wrote MLIR to output.mlir")


        # Replace nuw to make compilation valid
        # TODO: work out reason for this - I think compiler / mlir version mismatches
        res = res.replace(" nuw ", " ")

        return res


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
