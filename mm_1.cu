#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 7000
#define N_2 N*N

#define BLOCK_SIZE 32

float a[N_2], b[N_2];
float c[N_2];
__global__ void mm_kernel(float* A, float* B, float* C) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row < N && col < N) {
        float tmp = 0;
        for (int i = 0; i < N; ++i) {
             tmp += A[row * N + i] * B[i * N + col];
        }
        C[row * N + col] = tmp;
    } 
}

int main() {
    srand(time(NULL));

    //dim3 dimGrid(3, 3, 1);
    //dim3 dimBlock(N/3, N/3, 1);
    

    for(int i = 0; i < N; i++){
        for(int j = 0; j < N; j++){
            a[i*N + j] = rand() % 10 + 1;
            b[i*N + j] = rand() % 10 + 1;
        }
    }
    /*
    printf("a:\n");
    for(int i = 0; i < N; i++){
        for(int j = 0; j < N; j++){
            printf("%f ", a[i*N + j]);
        }
        printf("\n");
    }
    printf("\n");
    printf("\n");

    printf("b:\n");
    for(int i = 0; i < N; i++){
        for(int j = 0; j < N; j++){
            printf("%f ", b[i*N + j]);
        }
        printf("\n");
    }
    printf("\n");
    printf("\n");*/
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);


    float*d_a, *d_b;
    float *d_c;
    cudaMalloc((void **)&d_a, N_2*sizeof(float));
    cudaMalloc((void **)&d_b, N_2*sizeof(float));
    cudaMalloc((void **)&d_c, N_2*sizeof(float));
    cudaMemcpy(d_a, a, N_2*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, N_2*sizeof(float), cudaMemcpyHostToDevice);

    unsigned int grid_rows = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
    unsigned int grid_cols = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;

    dim3 dimGrid(grid_cols, grid_rows, 1); //.x
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE, 1); //.y

    cudaEventRecord(start);
    mm_kernel<<<dimGrid, dimBlock>>> (d_a, d_b, d_c);
    cudaEventRecord(stop);

    cudaMemcpy(c, d_c, N*N*sizeof(float), cudaMemcpyDeviceToHost);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("time : %f\n", milliseconds);

    /*
    for(int i = 0; i < N; i++){
        for(int j = 0; j < N; j++){
            printf("%lf ", c[i*N + j]);
        }
        printf("\n");
    }*/
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    return 0;
}