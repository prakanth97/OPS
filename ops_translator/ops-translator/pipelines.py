import os
from typing import List
from pipeline import Pipeline
from typing import List, Optional
from strategy import Strategy


class CPUSequential(Pipeline):
    """Regular sequential CPU execution"""

    strategy = Strategy.find("seq")

    def passes(self) -> List[str]:
        return [
            "convert-bufferization-to-memref",
            "convert-scf-to-cf",
            "convert-cf-to-llvm",
            "canonicalize",
            "cse",
            "lower-affine",
            "convert-math-to-llvm",
            "convert-arith-to-llvm",
            "convert-func-to-llvm",
            "expand-strided-metadata",
            "finalize-memref-to-llvm",
            "reconcile-unrealized-casts",
            "canonicalize",
            "cse",
        ]


class OpenMP(Pipeline):
    """OpenMP parallel CPU execution"""

    strategy = Strategy.find("openmp")
    
    def passes(self) -> List[str]:
        return [
            "convert-bufferization-to-memref",
            "convert-scf-to-openmp",
            "canonicalize",
            "cse",

            "convert-openmp-to-llvm",
            "canonicalize",
            "lower-affine",
            "convert-math-to-llvm",
            "expand-strided-metadata",
            "finalize-memref-to-llvm",

            "canonicalize", # extra one
            "convert-scf-to-cf",
            "convert-cf-to-llvm",
            "lower-affine",
            "convert-arith-to-llvm",
            "convert-math-to-llvm",
            "convert-func-to-llvm",
            "reconcile-unrealized-casts",
        ]


class GPUCUDA(Pipeline):
    """NVIDIA CUDA GPU execution"""

    strategy = Strategy.find("gpu_nvvm")
    
    def __init__(self, gpu_sm: Optional[str] = None):
        self._gpu_sm = gpu_sm  # Don't auto-detect on initialisation
    
    @property
    def gpu_sm(self) -> str:
        """Lazy GPU compute capability detection."""
        if self._gpu_sm is None:
            self._gpu_sm = self._detect_gpu_sm()
        return self._gpu_sm
    
    def passes(self) -> List[str]:
        nvvm_target = f"O=3 ftz fast chip=sm_{self.gpu_sm},triple=nvptx64-nvidia-cuda"

        block_sizes: list[int] = [
            target for target, dim in zip([2, 2], ["x", "y"])
        ]

        block_sizes_str = ",".join(map(str, block_sizes))

        return [
            "convert-bufferization-to-memref",
            "canonicalize",
            "cse",
            "reconcile-unrealized-casts",

            f"scf-parallel-loop-tiling{{parallel-loop-tile-sizes={block_sizes_str}}}",
            
            "gpu-map-parallel-loops",
            
            "convert-parallel-loops-to-gpu",
            
            "canonicalize",
            "cse",
            "fold-memref-alias-ops",
            
            "gpu-kernel-outlining",

            "canonicalize",
            "cse",
            "fold-memref-alias-ops",

            "expand-strided-metadata",
            "lower-affine",
            "canonicalize",
            "cse",
            "func.func(gpu-async-region)",
            "canonicalize",
            "cse",
            
            "convert-arith-to-llvm",
            "convert-math-to-llvm",
            "convert-scf-to-cf",
            "convert-cf-to-llvm",
            "canonicalize",
            "cse",

            "convert-func-to-llvm{use-bare-ptr-memref-call-conv}",

            f"nvvm-attach-target{{{nvvm_target}}}",

            "gpu.module(convert-gpu-to-nvvm,canonicalize,cse)",
            "gpu-to-llvm",
            "gpu-module-to-binary",
            "canonicalize",
            "cse",
            
            # "convert-index-to-llvm=index-bitwidth=64",
            # "convert-ub-to-llvm",
            # "convert-nvvm-to-llvm",
            # "convert-to-llvm",
            # "canonicalize",
            # "cse",
            # "finalize-memref-to-llvm",


        ]
    
    def _detect_gpu_sm(self) -> str:
        """Auto-detect GPU compute capability"""
        gpu_sm = 89
        return gpu_sm
        
        # Check environment variable first
        gpu_sm = os.environ.get("OPS_GPU_SM")
        if gpu_sm:
            return gpu_sm
        
        # Try auto-detection
        try:
            import pycuda.driver as cuda
            import pycuda.autoinit
            
            # should we always take device 0?
            dev = cuda.Device(0)
            major, minor = dev.compute_capability()
            return f"{major}{minor}"
        except ModuleNotFoundError:
            raise RuntimeError(
                "PyCUDA is not installed. Install it with `pip install pycuda`.\n"
                "Note: PyCUDA only works if you have an NVIDIA GPU and CUDA installed.\n"
                "If you do not have an NVIDIA GPU, run the script again with '--device cpu'."
            )
        except cuda.Error as e:
            raise RuntimeError(f"Failed to detect GPU compute capability: {e}")
