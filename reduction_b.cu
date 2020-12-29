#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define THREADS_PER_BLOCK 512
#define BLOCK_NUM 16
#define BLOCK_SIZE 16

__global__ void maxReduction(int *arr, int *res)
{
	__shared__ int tmp[10000];
	int tid = threadIdx.x;
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	tmp[tid] = arr[idx];

  __syncthreads();
	for(int i = 1; i < blockDim.x; i *= 2) {
		if(tid % (2*i) == 0) {
			if(tmp[tid] < tmp[tid+i])
				tmp[tid] = tmp[tid+i];
		}
		__syncthreads();
	}
  
  if(tid == 0)
		res[blockIdx.x] = tmp[0];
}

int main(int argc, char *argv[])
{
    unsigned int size = atoi(argv[1]);

    int *arr, *res;
    arr = (int *) malloc(sizeof(int) * size);
    res = (int *) malloc(sizeof(int) * size);
    
    srand(time(NULL)); 
    for(int i = 0; i < size; i++)
      arr[i] = rand() % size;
  
    int *d_arr, *d_res, *d_tmp;
    cudaMalloc((void**) &d_arr, size * sizeof(int));
    cudaMalloc((void**) &d_res, size * sizeof(int));
    d_tmp = d_arr;

    cudaMemcpy(d_arr, arr, size * sizeof(int), cudaMemcpyHostToDevice);
    
    dim3 dimBlock(BLOCK_SIZE);
    dim3 dimGrid(BLOCK_NUM);
    
    float time;
    cudaEvent_t start, end;
    cudaEventCreate(&start);
    cudaEventCreate(&end);
    
    cudaEventRecord(start);  

    do {
      maxReduction<<<dimGrid, dimBlock>>> (d_tmp, d_res);
      cudaMemcpy(res, d_res, size * sizeof(int), cudaMemcpyDeviceToHost);
      d_tmp = d_res;
      size >>= 1;
    } while (res[1] != 0);

    cudaEventRecord(end);
    cudaEventSynchronize(end);
    cudaEventElapsedTime(&time, start, end);
    printf("Array Size: %d, Elapsed time : %.5f, Result : %d\n", size, time, res[0]);

    cudaFree(d_arr);
    cudaFree(d_res);
    free(arr);
    free(res);
    return 0;
}