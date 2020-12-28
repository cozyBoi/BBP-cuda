#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define N 10000

int main() {
    srand(time(NULL));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int arr[N];
    for(int i = 0; i < N; i++){
        arr[i] = rand() % 1000;
    }

    cudaEventRecord(start);
    int maxVal = arr[0];
    for(int i = 0; i < N; i++){
        maxVal = maxVal < arr[i] ? arr[i] : maxVal;
    }
    cudaEventRecord(stop);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("time : %f\n", milliseconds);

    printf("%d\n", maxVal);
    return 0;
}