#
# The following environment variables should be predefined:
#
# OPS_INSTALL_PATH
# OPS_COMPILER (gnu,intel,etc)
#

OPS_COMPILER=gnu

OPS_FILES=test_kernel.cpp


APP=a_mlir
MAIN_SRC=test_kernel

include $(OPS_INSTALL_PATH)/../makefiles/Makefile.common
include $(OPS_INSTALL_PATH)/../makefiles/Makefile.mpi
include $(OPS_INSTALL_PATH)/../makefiles/Makefile.cuda
include $(OPS_INSTALL_PATH)/../makefiles/Makefile.hip
include $(OPS_INSTALL_PATH)/../makefiles/Makefile.hdf5


TARGETS=openmp

seq:
	clang -c output.ll -o output.o
	g++ -fopenmp -I$(OPS_INSTALL_PATH)/c/include -c test_kernel.cpp -o test_kernel.o
	g++ -fopenmp -L/usr/lib/llvm-18/lib -lomp test_kernel.o output.o -L$(OPS_INSTALL_PATH)/c/lib/gnu -lops_seq -o program

# Working configuration: libgomp (g++) + libomp (clang IR) coexistence
# Requires manual OpenMP initialization in main code before ops_init()
openmp:
	clang -c output.ll -o output.o
	g++ -fopenmp -I$(OPS_INSTALL_PATH)/c/include -c test_kernel.cpp -o test_kernel.o
	g++ -fopenmp -L/usr/lib/llvm-18/lib test_kernel.o output.o -L$(OPS_INSTALL_PATH)/c/lib/gnu -lops_seq -o program
