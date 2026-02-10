from xdsl.dialects.builtin import StringAttr, IntegerType
from xdsl.dialects.llvm import LLVMStructType, LLVMArrayType, LLVMPointerType, i32, ArrayAttr

# Max dimensions - as specified in the C/Fortran libraries
OPS_MAX_DIM = 5

ops_block_type = LLVMStructType(
        StringAttr("struct.ops_block"),  # struct_name
        ArrayAttr([
            IntegerType(32),   # index
            IntegerType(32),   # dims
            LLVMPointerType(), # name (char *)
            LLVMPointerType()  # OPS_instance struct (shouldn't be important)
        ]),
    )


ops_dat_type = LLVMStructType(
    StringAttr("struct.ops_dat"),
    ArrayAttr([
    i32,                                    # 0:  int index
    LLVMPointerType(),                      # 1:  ops_block block (pointer)
    i32,                                    # 2:  int dim
    i32,                                    # 3:  int type_size
    i32,                                    # 4:  int elem_size
    LLVMArrayType.from_size_and_type(       # 5:  int size[OPS_MAX_DIM]
        OPS_MAX_DIM, i32
    ),
    LLVMArrayType.from_size_and_type(       # 6:  int base[OPS_MAX_DIM]
        OPS_MAX_DIM, i32
    ),
    LLVMArrayType.from_size_and_type(       # 7:  int d_m[OPS_MAX_DIM]
        OPS_MAX_DIM, i32
    ),
    LLVMArrayType.from_size_and_type(       # 8:  int d_p[OPS_MAX_DIM]
        OPS_MAX_DIM, i32
    ),
    i32,                                    # 9:  int x_pad
    LLVMPointerType(),                      # 10: char* data
    LLVMPointerType(),                      # 11: char* data_d
    LLVMPointerType(),                      # 12: char const* name
    LLVMPointerType(),                      # 13: char const* type
    i32,                                    # 14: int dirty_hd
    i32,                                    # 15: int locked_hd
    i32,                                    # 16: int user_managed
    i32,                                    # 17: int is_hdf5
    LLVMPointerType(),                      # 18: char const* hdf5_file
    i32,                                    # 19: int e_dat
    IntegerType(64),                        # 20: size_t mem
    IntegerType(64),                        # 21: size_t base_offset
    LLVMArrayType.from_size_and_type(       # 22: int stride[OPS_MAX_DIM]
        OPS_MAX_DIM, i32
    ),
])
)


ops_arg_type = LLVMStructType(
    StringAttr("struct.ops_arg"),
    ArrayAttr([
        ops_dat_type,
        # TODO: model ops_stencil
        IntegerType(32),   # dim
        IntegerType(32),   # elem_size
        LLVMPointerType(), # data (char *)
        LLVMPointerType(), # data_d (char *) - data on device for CUDA
        IntegerType(32),    # ops_access type
        # TODO: model ops_arg_type
        IntegerType(32)    # opt
    ])
)
