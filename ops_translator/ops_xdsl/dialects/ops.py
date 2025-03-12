"""

"""

from xdsl.dialects.builtin import IntegerAttr, StringAttr, ArrayAttr, ArrayOfConstraint, AnyAttr, IntAttr, FloatAttr
from xdsl.ir import Data, ParametrizedAttribute, Dialect
from xdsl.irdl import irdl_attr_definition, irdl_op_definition, attr_def, IRDLOperation

"""
Notes:-
- 
"""

@irdl_op_definition
class VarDef(IRDLOperation):
    name = "ops.ir.var_def"

    var = attr_def(AnyAttr())
    type = attr_def(AnyAttr())
