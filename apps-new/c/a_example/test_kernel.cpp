#define OPS_2D
#include <ops_seq_v2.h>


const int imax = 6;
const int jmax = 6;

const double pi  = 3.14159;

// void set_zero(ACC<double> &A) {
//   A(0,0) = 0.0;
// }

// void copy(ACC<double> &A, const ACC<double> &Anew) {
//   A(0,0) = Anew(0,0);
// }

// void left_bndcon(ACC<double> &A, const int *idx) {
//   A(0,0) = sin(pi * (idx[1]+1) / (jmax+1));
// }

// void right_bndcon(ACC<double> &A, const int *idx) {
//   A(0,0) = sin(pi * (idx[1]+1) / (jmax+1))*exp(-pi);
// }

void apply_stencil(const ACC<double> &A, ACC<double> &Anew, double *error) {
  Anew(0,0) = 0.25f * ( A(1,0) + A(-1,0)
      + A(0,-1) + A(0,1));
  *error = fmax( *error, fabs(Anew(0,0)-A(0,0)));
}


void demo_kernel_old(const ACC<double> &A, ACC<double> &Anew, double *error, const int *idx) {
  Anew(0,0) = 0.25 * (A(1,0) + A(-1,0) + A(0,-1) + A(0,1)) 
    * sin(pi * idx[0] / imax);
  
  *error = fmax(*error, fabs(Anew(0,0) - A(0,0)));
}

void demo_kernel(const ACC<double> &A, ACC<double> &Anew, double *error, const int *idx) {
  Anew(0,0) = A(1,0) + A(-1,0) + idx[0] * pi;
  
  *error = fmax(*error, fabs(Anew(0,0) - A(0,0)));
}

int main(int argc, const char** argv) {

  ops_init(argc, argv, 1);
  printf("OPS initialized\n");
  
  // block + dataset
  ops_block block = ops_decl_block(2, "grid");
  
  int size[] = {imax, jmax};
  int base[] = {0, 0};
  int d_m[] = {-1, -1};
  int d_p[] = {1, 1};

  ops_decl_const("imax",1,"int",&imax);
  ops_decl_const("jmax",1,"int",&jmax);
  ops_decl_const("pi",1,"double",&pi);
  
  
  double* A = NULL;
  double *Anew=NULL;
  // double *Aalt=NULL;

  ops_dat d_A = ops_decl_dat(block, 1, size, base, d_m, d_p, A, "double", "A");

  ops_dat d_Anew = ops_decl_dat(block, 1, size, base,
                              d_m, d_p, Anew, "double", "Anew");

  // ops_dat d_Aalt = ops_decl_dat(block, 1, size, base,
                              // d_m, d_p, Aalt, "double", "Aalt");
  // 1-point stencil
  int s2d_00[] = {0, 0};
  // printf("DECLARE STENCIL");
  ops_stencil S2D_00 = ops_decl_stencil(2, 1, s2d_00, "0,0");

  int s2d_5pt[] = {0,0, 1,0, -1,0, 0,1, 0,-1};
  ops_stencil S2D_5pt = ops_decl_stencil(2,5,s2d_5pt,"5pt");

  // printf("DECLARE REDUCTION HANDLE");
  ops_reduction h_error = ops_decl_reduction_handle(sizeof(double), "double", "error");

  double error_total = 0.0;

  ops_partition("");
  
  // ---- ranges ----
  int full_range[] = {-1, imax + 1, -1, jmax + 1};
  int bottom_range[] = {-1, imax + 1, -1, 0};
  int top_range[] = {-1, imax + 1, jmax, jmax + 1};
  int interior[] = {0, imax, 0, jmax};
  int left_range[] = {-1, 0, -1, jmax+1};
  int right_range[] = {imax, imax+1, -1, jmax+1};
  
  // ---- target kernel calls ----

  ops_memspace memspace = OPS_HOST;
  
  int dim = 2;
  // ops_arg test_arg = ops_arg_dat(d_A, 1, S2D_00, "double", OPS_WRITE);

  // ops_par_loop(set_zero, "set_zero", block, 2, bottom_range,
  //   ops_arg_dat(d_A, 1, S2D_00, "double", OPS_WRITE));

  // printf("After MLIR call scope\n");
  
  // ops_exit();
  
  // printf("After ops_exit\n");


  ops_par_loop(demo_kernel, "demo_kernel", block, 2, interior,
    ops_arg_dat(d_A, 1, S2D_5pt, "double", OPS_READ),
    ops_arg_dat(d_Anew, 1, S2D_00, "double", OPS_RW),
    ops_arg_reduce(h_error, 1, "double", OPS_MAX),
    ops_arg_idx()
  );
    
  // ops_par_loop(set_five, "set_five", block, 2, top_range,
  //   ops_arg_dat(d_A, 1, S2D_00, "double", OPS_WRITE));
  
  // ops_par_loop(set_five, "set_five", block, 2, left_range,
  // ops_arg_dat(d_A, 1, S2D_00, "double", OPS_WRITE));

  // ops_par_loop(set_five, "set_five", block, 2, right_range,
  // ops_arg_dat(d_A, 1, S2D_00, "double", OPS_WRITE));

  // ops_par_loop(set_two, "set_two", block, 2, interior,
  // ops_arg_dat(d_A, 1, S2D_00, "double", OPS_WRITE));


  // ops_par_loop(increment, "increment", block, 2, full_range,
  // ops_arg_dat(d_A, 1, S2D_00, "double", OPS_RW));

  // printf("RUNNING STENCIL");

  // ops_par_loop(sum, "apply_stencil", block, 2, interior,
  //   ops_arg_dat(d_A,    1, S2D_5pt, "double", OPS_READ),
  //   ops_arg_dat(d_Anew, 1, S2D_00, "double", OPS_WRITE),
  //   ops_arg_reduce(h_sum, 1, "double", OPS_INC)
  // );

  //  // ops_arg_dat(d_Aalt, 1, S2D_00, "double", OPS_WRITE),

  // printf("FINISHED STENCIL");

  // ---- PRINT GRID ----

  // get raw pointer (including halo because we use S2D_00)
  // char *ptr = ops_dat_get_raw_pointer(d_A, 0, S2D_00, &memspace);
  // double *raw = (double*)ptr;

  // true allocated extents (because halo = {-1,+1})

  // ops_reduction_result(h_sum, &sum_total);
  // printf("Sum: %f\n", sum_total);


  // printf("\nGrid contents (using ops_dat_get_raw_pointer):\n\n");
  // int size_x = imax + 2;
  // int size_y = jmax + 2;

  // // print top -> bottom for human readable orientation
  // for (int j = size_y-1; j >= 0; j--) {
  //   for (int i = 0; i < size_x; i++) {
  //       printf("%6.2f ", raw[j*size_x + i]);
  //   }
  //   printf("\n");
  // }

  // printf("\nGrid contents (with halos):\n\n");

  // int xdim = d_A->size[0];

  // int base_x = d_A->base[0];
  // int base_y = d_A->base[1];

  // int halo_x = abs(d_A->d_m[0]);
  // int halo_y = abs(d_A->d_m[1]);

  // int size_x = imax + halo_x + d_A->d_p[0];
  // int size_y = jmax + halo_y + d_A->d_p[1];

  // for (int j = size_y-1; j >= 0; j--) {
  //   for (int i = 0; i < size_x; i++) {

  //     int mem_x = i + base_x - halo_x;
  //     int mem_y = j + base_y - halo_y;

  //     int offset = mem_x + mem_y * xdim;

  //     printf("%6.2f ", raw[offset]);
  //   }
  //   printf("\n");
  // }

  // release pointer back to OPS

  // printf("---- TEST FAIL POINT 1 ----\n");
  // ops_dat_release_raw_data(d_A, 0, OPS_WRITE);

  // free(A);

  // ops_exit();
  printf("---- TEST FAIL POINT 2 ----\n");
}
