from xdsl.passes import ModulePass
from xdsl.builder import Builder, InsertPoint
from xdsl.ir import SSAValue, Block, Region
from xdsl.dialects.llvm import FuncOp as LLVMFuncOp, LLVMPointerType
from xdsl.dialects.builtin import IntegerType, f64, MemRefType, ModuleOp
from xdsl.dialects.stencil import FieldType, StencilBoundsAttr, TempType
from xdsl.dialects import llvm, func
from xdsl.dialects.func import FuncOp as FuncFuncOp

from .ops_dialect import * 

from kernel_config import KernelConfig

from .ops_types import *

class LowerParLoopPass(ModulePass):
    """
    Lower ops.par_loop to:
    1. Extraction operations (ops.extract_*)
    2. Memory operations (ops_dat data to memref)
    3. Compute operation (ops.compute)
    
    Input:
        ops.par_loop(%kernel, %block, %dim, %range, %ops_arg1) {
            <kernel computation body for stencil accesses>
        }
    """

    name = "lower-ops-par-loop"

    def __init__(self, config: KernelConfig):
        self.config = config
        print(f"LowerParLoopPass initialized with config: {config.name}, bounds: {config.iteration_bounds}")

    
    def apply(self, ctx, module):

        for func in module.walk():
            if not isinstance(func, FuncFuncOp) and not isinstance(func, LLVMFuncOp):
                continue
            
            for op in list(func.walk()):
                if isinstance(op, ParLoopOp):
                    self.lower_par_loop(op, module)
    
    def lower_par_loop(self, par_loop: ParLoopOp, module: ModuleOp):
        """Lower a single ops.par_loop operation"""
        
        builder = Builder(InsertPoint.before(par_loop))
     
        field_operands = []
        reduction_operands = []

        for ops_arg_ptr in par_loop.dats:
            # extract data from each arg_dat

            ops_arg = self.extract_arg(builder, ops_arg_ptr)
            dat = self.extract_arg_dat(builder, ops_arg)
            data = self.extract_arg_dat_data(builder, dat)
            data_ref = self.create_ptr_to_ref(builder, data)
            data_field = self.create_ref_to_field(builder, data_ref)

            field_operands.append(data_field)


        # Process reduction arguments
        for ops_arg_ptr in par_loop.reductions:
            # ops_arg = self.extract_arg(builder, ops_arg_ptr)
            ops_reduction = self.extract_arg_reduction_handle(builder, ops_arg_ptr)
            reduction_data_ptr = self.extract_reduction_data_ptr(builder, ops_reduction)
            reduction_memref = self.create_red_ptr_to_ref(builder, reduction_data_ptr)
            reduction_operands.append(reduction_memref)


        builder.insert(func.CallOp(
            callee=self.config.name + "_impl",
            arguments=[*field_operands, *reduction_operands],
            return_types=[]    
        ))

        # Make the impl function here
        # Then call it with the arguments (field_operands and reduction_operands)
        # Then place the ops.compute op in the impl function

        # ---------------------------

        builder = Builder(InsertPoint.at_end(module.body.block))  

        param_types = [v.type for v in [*field_operands, *reduction_operands]]

        entry_block = Block(arg_types=param_types)

        # add name hints to parameters
        for i in range(len(entry_block.args)):
            entry_block.args[i].name_hint = 'ops_arg' + str(i)

        fn = func.FuncOp(
            name=self.config.name + "_impl",
            function_type=func.FunctionType.from_lists(param_types, []),
            #     inputs=param_types,
            #     outputs=LLVMVoidType(),
            # ),
            # linkage=LinkageAttr("external"),
            region=Region([entry_block]),
        )

        fn_op = builder.insert(fn)

        builder1 = Builder(InsertPoint.at_end(entry_block))

        builder1.insert(ComputeOp.create(
            operands=[*(fn_op.args)], #? 
        ))

        builder1.insert(func.ReturnOp())

        # ---------------------------

        par_loop.detach()
        par_loop.erase()
    
    
    def extract_arg(self, builder, ops_arg_ptr):
        """
        Extract ops_arg from ops_arg*
        """
        op = builder.insert(ExtractArgOp.create(
            operands=[ops_arg_ptr],
            result_types=[ops_arg_type]
        ))

        op.result.name_hint = "arg"
        return op.result

    def extract_arg_dat(self, builder, ops_arg_struct):
        """
        Extract arg_dat from ops_arg
        """
        op = builder.insert(ExtractArgDatOp.create(
            operands=[ops_arg_struct],
            result_types=[ops_dat_type]
        ))

        op.result.name_hint = "dat"
        return op.result
    
    def extract_arg_dat_data(self, builder, ops_dat_struct):
        """
        Extract data from ops_arg_dat
        """
        op = builder.insert(ExtractArgDatDataOp.create(
            operands=[ops_dat_struct],
            result_types=[LLVMPointerType()]
        ))

        op.result.name_hint = "data_ptr"
        return op.result

    
    def create_ptr_to_ref(self, builder, data_ptr):
        """
        Take the data pointer and put it in a placeholder
        to convert to a memref
        """

        sizes = [end - start for start, end in self.config.grid_size]
        op = builder.insert(PointerToMemref.create(
            operands=[data_ptr],
            result_types=[MemRefType(f64, sizes)],
            attributes={"is_reduction": BoolAttr.from_bool(False)}
        ))

        op.result.name_hint = "data_ref"
        return op.result
    

    def create_ref_to_field(self, builder, data_ref):
        """
        Take the data memref and put it in a placeholder
        to convert to a stencil.field
        """

        op = builder.insert(MemrefToStencilField.create(
            operands=[data_ref],
            result_types=[FieldType(StencilBoundsAttr(self.config.grid_size), f64)] 
        ))

        op.result.name_hint = "data_field"
        return op.result

    
    def extract_arg_reduction_handle(self, builder: Builder, ops_arg: SSAValue) -> SSAValue:
        """
        Extract the reduction handle pointer from ops_arg.
        ops_arg.data contains the ops_reduction pointer.
        """
        # Extract ops_arg.data (field 4)
        data_ptr_ptr = builder.insert(llvm.GEPOp.from_mixed_indices(
            ops_arg,
            indices=[0, 4],
            result_type=LLVMPointerType(),
            pointee_type=ops_arg_type
        ))
        ops_reduction_ptr = builder.insert(llvm.LoadOp(data_ptr_ptr, LLVMPointerType()))
        data_ptr_ptr.result.name_hint = "reduction_handle_ptr_ptr"
        ops_reduction_ptr.results[0].name_hint = "reduction_handle"
        return ops_reduction_ptr.results[0]

    def extract_reduction_data_ptr(self, builder: Builder, ops_reduction: SSAValue) -> SSAValue:
        """
        Extract the actual data pointer from ops_reduction.
        ops_reduction->data is where the reduction value is stored.
        """
        # Extract ops_reduction->data (field 0)
        reduction_data_ptr_ptr = builder.insert(llvm.GEPOp.from_mixed_indices(
            ops_reduction,
            indices=[0, 0],
            result_type=LLVMPointerType(),
            pointee_type=ops_reduction_type
        ))
        reduction_data_ptr = builder.insert(llvm.LoadOp(reduction_data_ptr_ptr, LLVMPointerType()))
        reduction_data_ptr_ptr.result.name_hint = "reduction_data_ptr_ptr"
        reduction_data_ptr.results[0].name_hint = "reduction_data_ptr"
        return reduction_data_ptr.results[0]
    
    
    def create_red_ptr_to_ref(self, builder, data_ptr):
        """
        Take the data pointer and put it in a placeholder
        to convert to a memref
        """

        op = builder.insert(PointerToMemref.create(
            operands=[data_ptr],
            result_types=[MemRefType(f64, [])],
            attributes={"is_reduction": BoolAttr.from_bool(True)}
        ))

        op.result.name_hint = "data_ref"
        return op.result