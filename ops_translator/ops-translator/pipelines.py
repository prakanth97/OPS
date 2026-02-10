import os
from typing import List
from pipeline import Pipeline
from typing import List, Optional


class CPUSequential(Pipeline):
    """Regular sequential CPU execution"""

    def passes(self) -> List[str]:
        return [
            "convert-scf-to-cf",
            "lower-affine",
            "convert-arith-to-llvm",
            "convert-func-to-llvm",
            "finalize-memref-to-llvm",
            "reconcile-unrealized-casts",
        ]


class CPUOpenMP(Pipeline):
    """OpenMP parallel CPU execution"""
    
    def passes(self) -> List[str]:
        return [
            "convert-bufferization-to-memref",
            "convert-scf-to-openmp",
            "canonicalize",
            "cse",
            "convert-openmp-to-llvm",
            "canonicalize",
            "lower-affine",
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
    
    def __init__(self, gpu_sm: Optional[str] = None):
        self.gpu_sm = gpu_sm or self._detect_gpu_sm()
    
    def passes(self) -> List[str]:
        nvvm_target = f"chip=sm_{self.gpu_sm},triple=nvptx64-nvidia-cuda"
        
        return [
            "convert-bufferization-to-memref",
            "canonicalize",
            "cse",
            "gpu-map-parallel-loops",
            "convert-parallel-loops-to-gpu",
            "gpu-kernel-outlining",
            "convert-gpu-to-nvvm",
            f"nvvm-attach-target={nvvm_target}",
            "convert-scf-to-cf",
            "lower-affine",
            "convert-arith-to-llvm",
            "convert-index-to-llvm=index-bitwidth=64",
            "convert-ub-to-llvm",
            "expand-strided-metadata",
            "convert-nvvm-to-llvm",
            "convert-to-llvm",
            "canonicalize",
            "cse",
            "gpu-module-to-binary",
            "gpu-to-llvm",
            "finalize-memref-to-llvm",
            "convert-func-to-llvm",
            "convert-cf-to-llvm",
            "reconcile-unrealized-casts",
            "canonicalize",
            "cse",
        ]
    
    def _detect_gpu_sm(self) -> str:
        """Auto-detect GPU compute capability"""
        
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
