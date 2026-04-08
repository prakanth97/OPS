from xdsl.passes import ModulePass
from xdsl.dialects import scf, arith
from xdsl.dialects.builtin import IntegerType
from xdsl.builder import Builder, InsertPoint
from ops_dialect.ops_dialect import GetIndexOp

class LowerOpsIndexPass(ModulePass):
    """
    Lower ops.get_index to actual loop induction variables.
    
    This pass must run AFTER ConvertStencilToLLMLIR, which generates scf.parallel loops.
    It replaces ops.get_index operations with the actual loop indices.
    """
    
    name = "lower-ops-index"
    
    def apply(self, ctx, module):
        
        # Find all scf.parallel operations
        for op in module.walk():
            if isinstance(op, scf.ParallelOp):
                self.lower_index_in_parallel(op)
    
    def lower_index_in_parallel(self, parallel_op: scf.ParallelOp):
        """Replace ops.get_index with loop induction variables inside scf.parallel"""
        
        # Get the loop induction variables (block arguments)
        body_block = parallel_op.body.blocks[0]
        loop_indices = list(body_block.args)  # [%i, %j] or [%i, %j, %k, ...]
        
        # Find all ops.get_index operations in the body
        ops_to_replace = []
        for op in body_block.walk():
            if isinstance(op, GetIndexOp):
                ops_to_replace.append(op)
        
        # Replace each ops.get_index
        for get_index_op in ops_to_replace:
            builder = Builder(InsertPoint.before(get_index_op))
            
            # Cast each loop index from 'index' type to i32
            casted_indices = []
            dim = get_index_op.attributes["dim"].value.data
            
            for i in range(dim):
                # loop_indices[i] is type 'index', need to cast to i32
                cast_op = arith.IndexCastOp(
                    loop_indices[i],
                    IntegerType(32)
                )
                builder.insert(cast_op)
                casted_indices.append(cast_op.results[0])
            
            # Replace all uses of ops.get_index results with casted indices
            for i, result in enumerate(get_index_op.results):
                result.replace_by(casted_indices[i])
            
            # Remove the ops.get_index operation
            get_index_op.detach()
            get_index_op.erase()