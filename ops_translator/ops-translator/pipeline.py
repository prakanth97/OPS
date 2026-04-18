from util import Findable
from strategy import Strategy
from store import Application, Program
from ops_dialect.generate_ir import create_wrapper_func, add_ops_operations
from xdsl.context import Context
from ops_dialect.lower_par_loop import LowerParLoopPass
from ops_dialect.lower_compute import LowerComputePass
from ops_dialect.lower_extractions import LowerOpsExtractionsPass
from ops_dialect.lower_ptr_to_memref import LowerPtrToMemrefPass
from ops_dialect.lower_index import LowerOpsIndexPass
from xdsl.transforms.experimental.convert_stencil_to_ll_mlir import ConvertStencilToLLMLIRPass
from xdsl.transforms.canonicalize import CanonicalizePass
from xdsl.transforms.gpu_map_parallel_loops import GpuMapParallelLoopsPass
from kernel_config import KernelConfig
from language import Lang
from xdsl.transforms.scf_parallel_loop_tiling import ScfParallelLoopTilingPass
from xdsl.printer import Printer
from io import StringIO
from mlir.passmanager import PassManager as MLIRPassManager
from mlir import ir as mlir_ir

from mlir.dialects.llvm import translate_module_to_llvmir

from xdsl.passes import PassPipeline as xDSLPassManager

import ops
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
            # TODO: Fortran parser creation - currently out of scope
            kernel_info = self.kernel_parser.parseFortran(loop, program, app)

        kernel_config.kernel_info = kernel_info

        # Build starting IR
        xdsl_ctx = Context()

        ir_module = create_wrapper_func(kernel_config)
        ir_module = add_ops_operations(ir_module, kernel_config)

        pm = xDSLPassManager([
            LowerParLoopPass(kernel_config),
            LowerComputePass(kernel_config),
            LowerOpsExtractionsPass(),
            LowerPtrToMemrefPass(kernel_config),
            # StencilBufferize(), not needed as OPS has grid memory predefined!
            ConvertStencilToLLMLIRPass(),
            LowerOpsIndexPass(),
            CanonicalizePass()
        ])

        pm.apply(xdsl_ctx, ir_module)


        # OPTIONAL: Print IR to file for debugging purposes
        # with open("demofile.mlir", "w") as f:
        #     f.write(str(ir_module))


        if (self.strategy.name == "gpu_nvvm"):
            pm = xDSLPassManager([
                # This GPU pass exists within xDSL
                # Only run if the GPU strategy is chosen
                GpuMapParallelLoopsPass(),
            ])

            pm.apply(xdsl_ctx, ir_module)

        # Once all xDSL passes are applied, convert the IR to an MLIR module
        mlir_module, mlir_ctx = self.convertToMLIRModule(ir_module)

        result = self.run_mlir_passes(mlir_module, mlir_ctx)

        return result
    

    def convertToMLIRModule(self, xdsl_module) -> str:
        """Convert an xDSL module to MLIR module."""
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

        # Final translation step
        res = translate_module_to_llvmir(mlir_module.operation)

        # Replace nuw to make compilation valid
        # TODO: work out reason for this - I think compiler / mlir version mismatches with clang version
        res = res.replace(" nuw ", " ")
        res = res.replace("nocreateundeforpoison ", "")

        return res


    def matches(self, strat: Strategy) -> bool:
        return self.strategy == strat

    def passes(self):
        # Used by derived classes to return strategy-specific passes
        pass


# Import and register concrete pipeline implementations
# This happens automatically when the Pipeline class is imported
from pipelines import CPUSequential, OpenMP, GPUCUDA

Pipeline.register(CPUSequential)
Pipeline.register(OpenMP)
Pipeline.register(GPUCUDA)
