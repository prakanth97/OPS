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


TARGETS=seq


# seq:
# 	clang -c output.ll -o output.o
# 	g++ -fopenmp -I$(OPS_INSTALL_PATH)/c/include -c test_kernel.cpp -o test_kernel.o
# 	g++ -fopenmp -L/usr/lib/llvm-18/lib -lomp test_kernel.o output.o -L$(OPS_INSTALL_PATH)/c/lib/gnu -lops_seq -o program

# Working configuration: libgomp (g++) + libomp (clang IR) coexistence
# Requires manual OpenMP initialization in main code before ops_init()
# openmp:
# 	clang -c output.ll -o output.o
# 	g++ -fopenmp -I$(OPS_INSTALL_PATH)/c/include -c test_kernel_ops.cpp -o test_kernel_ops.o
# 	g++ -fopenmp -L/usr/lib/llvm-18/lib test_kernel.o output.o -L$(OPS_INSTALL_PATH)/c/lib/gnu -lops_seq -o program

.PHONY: seq openmp clean
CXXFLAGS=-g -O0 -fopenmp

seq:
	# Compile LLVM files in seq/ to .o
	for f in seq/*.ll; do \
		clang++ $(CXXFLAGS) -c $$f -o $${f%}.o; \
	done

# 	llvm-link seq/ops_par_loop_set_five_0.ll seq/ops_par_loop_set_five_0.ll -S -o combined.ll

# 	clang++ -c combined.ll -o combined.o

	clang++ $(CXXFLAGS) -c seq/base.cpp -o seq/base.o

	# Compile C++ kernel
	clang++ $(CXXFLAGS) -I$(OPS_INSTALL_PATH)/c/include -c test_kernel_ops.cpp -o test_kernel_ops.o

	# Link everything together
	clang++ $(CXXFLAGS) \
		-L/usr/lib/llvm-18/lib \
		test_kernel_ops.o \
		$$(ls seq/*.o) \
		-L$(OPS_INSTALL_PATH)/c/lib/gnu -lops_seq \
		-o program


openmp:
	# Compile LLVM files in openmp/ to .o
	for f in openmp/*.ll; do \
		clang++ -c $$f -o $${f%}.o; \
	done

	g++ -c openmp/base.cpp -o openmp/base.o

	# Compile C++ kernel
	g++ -fopenmp -I$(OPS_INSTALL_PATH)/c/include -c test_kernel_ops.cpp -o test_kernel_ops.o

	# Link everything together
	g++ -fopenmp \
		-L/usr/lib/llvm-18/lib \
		test_kernel_ops.o \
		$$(ls openmp/*.o) \
		-L$(OPS_INSTALL_PATH)/c/lib/gnu -lops_seq \
		-o program

clean:
	rm -f test_kernel_ops.o openmp/*.o seq/*.o program
