#include <stdio.h>
#include <stdlib.h>

#define N 3
#define N_2 N*N

__global__ void mm_kernel(float* A, float* B, float* C) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row < N && col < N) {
        for (int i = 0; i < N; ++i) {
            C[row * N + col] += A[row * N + i] * B[i * N + col];
        }
        printf("%d %d %d", row, col, C[row * N + col]);
    } 
}

int main() {
    dim3 dimGrid(1, 1, 1);
    dim3 dimBlock(1, 1, 1);
    float a[N], b[N], C[N_2];
    float*d_a, *d_b, *d_c;
    cudaMalloc((void **)&d_a, N*sizeof(float));
    cudaMalloc((void **)&d_b, N*sizeof(float));
    cudaMalloc((void **)&d_c, N_2*sizeof(float));
    cudaMemcpy(d_a, &a, N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, &b, N*sizeof(float), cudaMemcpyHostToDevice);

    mm_kernel<<<dimGrid, dimBlock>>> (d_a, d_b, d_c);
    
    return 0;
}