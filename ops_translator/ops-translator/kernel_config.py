from dataclasses import dataclass
from typing import List, Tuple, Literal, Any
from ops import Loop, Dat, ArgReduce, ArgIdx, Arg, ArgDat
from kernel_parser import KernelInfo
from store import Program

@dataclass
class ArgInfo:
    """Information about a single ops_arg"""
    index: int  # Position in original args list
    arg_type: Literal["dat", "idx", "reduce"]
    arg: Arg  # The actual arg object

@dataclass
class KernelConfig:
    name: str
    iteration_bounds: List[Tuple[int, int]]
    grid_size: List[int]
    kernel_info: KernelInfo
    dats: List[Dat]
    reductions: List[ArgReduce]
    has_idx: bool
    arg_order: List[ArgInfo]
    global_consts: dict[str, Any]

def generateKernelConfig(function_name: str, loop: Loop, program: Program) -> KernelConfig:
    
    print("LOOP")
    print(loop)
    
    # All dats in use should have the same size - use first dat to determine size
    dat = loop.dats[0]
    
    # Physical grid size (includes halos)
    physical_size = [
        (0, dat.size[i] + abs(dat.d_m[i]) + dat.d_p[i])
        for i in range(loop.ndim)
    ][::-1]  # Swap to match stencil column-major order
        
    print(f"Logical size: {dat.size}")
    print(f"Halos d_m: {dat.d_m}, d_p: {dat.d_p}")
    print(f"Physical size: {physical_size}")
    
    # Normalize iteration bounds to physical coordinates
    # The bounds are in logical space, we need to shift by d_m
    normalized_bounds = normalize_bounds_with_halos(
        loop.range.bounds, 
        loop.ndim,
        dat.d_m
    )

    reduction_args = [arg for arg in loop.args if isinstance(arg, ArgReduce)]
    has_idx = any(isinstance(arg, ArgIdx) for arg in loop.args)

    arg_order = []
    print("LOOP ARGS AHHH")
    print(loop.args)
    for i, arg in enumerate(loop.args):
        if isinstance(arg, ArgDat):
            arg_order.append(ArgInfo(i, "dat", arg))
        elif isinstance(arg, ArgIdx):
            arg_order.append(ArgInfo(i, "idx", arg))
        elif isinstance(arg, ArgReduce):
            arg_order.append(ArgInfo(i, "reduce", arg))

    print(" ")
    print("ARG ORDER")
    print(arg_order)

    return KernelConfig(
        name=function_name,
        iteration_bounds=normalized_bounds,
        grid_size=physical_size,
        dats=loop.dats,
        kernel_info=None,
        reductions=reduction_args,
        has_idx=has_idx,
        arg_order=arg_order,
        global_consts=program.const_values
    )

    # Example bounds
    # [(0, 8), (0, 1)] # this does just the first column

    # [(0, 1), (0, 8)] # should do bottom row

    # [(7, 8), (0, 8)] # should do top row

    # [(0, 8), (7, 8)] # last col


    # OPS bound representation
    #  [(xmin, xmax), (ymin, ymax)]

    # Stencil bound representation
    # [ymin, ymax, xmin, xmax]


def normalize_bounds_with_halos(bounds: List[int], dim: int, d_m: List[int]) -> List[Tuple[int, int]]:
    """
    Convert logical bounds to physical bounds accounting for halos.
    
    Example: 
    - Logical bounds: [-1, 7, -1, 0] (includes halo regions)
    - d_m (halo offset): [1, 1]
    - Physical: shift everything by d_m to get actual array indices
    """
    normalized = []
    
    for i in range(dim):
        logical_lower = bounds[2 * i]
        logical_upper = bounds[2 * i + 1]
        
        # Shift by halo offset to get physical coordinates
        physical_lower = logical_lower + abs(d_m[i])
        physical_upper = logical_upper + abs(d_m[i])
        
        normalized.append((physical_lower, physical_upper))
    
    # Swap for column-major (stencil dialect)
    return normalized[::-1]

def attachKernelInfo(config: KernelConfig, info: KernelInfo):
    config.kernel_info = info