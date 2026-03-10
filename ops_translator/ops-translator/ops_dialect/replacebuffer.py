from xdsl.passes import ModulePass

class ReplaceStencilBufferWithOriginal(ModulePass):
    name = "replace-stencil-buffer"
    
    def apply(self, ctx, module):
        from xdsl.dialects.stencil import BufferOp, LoadOp, CastOp
        
        # Map: temp -> original field
        temp_to_field = {}
        
        # Find external_load ops and track temp -> field mapping
        for op in module.walk():
            if isinstance(op, LoadOp):
                # %temp = stencil.external_load %field
                temp_to_field[op.results[0]] = op.operands[0]
        
        # Replace stencil.buffer with the original field
        for op in list(module.walk()):
            if isinstance(op, BufferOp):
                # %new_field = stencil.buffer %temp
                temp = op.operands[0]
                
                if temp in temp_to_field:
                    original_field = temp_to_field[temp]
                    # Replace all uses of the buffered field with the original
                    op.results[0].replace_all_uses_with(original_field)
                    op.detach()
                    op.erase()