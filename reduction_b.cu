#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 10000
#define BLOCK_SIZE 16
__global__ void reduce0(int *g_idata, int *g_odata) {
    __shared__ int sdata[16];
    // each thread loads one element from global to shared mem
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
    sdata[tid] = g_idata[i];
    __syncthreads();
    for (unsigned int s=1; s < blockDim.x; s *= 2) {
        int index = 2 * s * tid;
        if (index < blockDim.x) { 
            sdata[index] = sdata[index + s] > sdata[index] ? sdata[index + s]  : sdata[index];
        }
        __syncthreads();
     }
    // write result for this block to global mem
    if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}

int a[N], b[N];
int main() {
    srand(time(NULL));
    
    
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    for(int i = 0; i < N; i++){
        a[i] = rand() % 1000;
        //printf("%d ", a[i]);
    }
    //printf("\n");

    unsigned int grid_rows = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
    unsigned int grid_cols = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;

    dim3 dimGrid(grid_cols, grid_rows, 1); //.x
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE, 1); //.y

    
    int*d_a, *d_b;
    cudaMalloc((void **)&d_a, N*sizeof(int));
    cudaMalloc((void **)&d_b, N*sizeof(int));
    cudaMemcpy(d_a, a, N*sizeof(int), cudaMemcpyHostToDevice);


    cudaEventRecord(start);
    reduce0<<<dimGrid, dimBlock>>> (d_a, d_b);
    cudaEventRecord(stop);

    cudaMemcpy(b, d_b, N*sizeof(int), cudaMemcpyDeviceToHost);

    while(1){
        reduce0<<<dimGrid, dimBlock>>> (d_b, d_b);
    
        cudaMemcpy(b, d_b, N*sizeof(int), cudaMemcpyDeviceToHost);

        if(b[1] == 0) break;
    }
    
    /*
    printf("a: ");
    for(int i = 0;i < N; i++){
        printf("%d ", a[i]);
    }
    printf("\n");*/

    /*
    printf("b: ");
    for(int i = 0;i < N; i++){
        printf("%d ", b[i]);
    }
    printf("\n");*/
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("time : %f\n", milliseconds);
    printf("max : %d\n", b[0]);
    return 0;
}