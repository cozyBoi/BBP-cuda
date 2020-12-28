#include <stdio.h>
#include <stdlib.h>

#define N 10000

__global__ void reduce0(int *g_idata, int *g_odata) {
    extern __shared__ int sdata[];
    // each thread loads one element from global to shared mem
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
    sdata[tid] = g_idata[i];
    __syncthreads();
    // v                                                                            do reduction in shared mem
    for (unsigned int s=blockDim.x/2; s>0; s>>=1) {
        if (tid < s) {
            sdata[tid] = sdata[tid + s] >  sdata[tid] ? sdata[tid + s] : sdata[tid]; 
        }
        __syncthreads(); 
    }
    // write result for this block to global mem
    if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}

int main() {
    dim3 dimGrid(8, 1, 1);
    dim3 dimBlock(8, 1, 1);
    int a[N], b[N], C[N_2];
    int*d_a, *d_b, *d_c;
    cudaMalloc((void **)&d_a, N*sizeof(int));
    cudaMalloc((void **)&d_b, N*sizeof(int));
    cudaMemcpy(d_a, &a, N*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, &b, N*sizeof(int), cudaMemcpyHostToDevice);

    reduce0<<<dimGrid, dimBlock>>> (d_a, d_b);
    

    return 0;
}