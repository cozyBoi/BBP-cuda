#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define N 10000

int arr[N];

int main() {
    srand(time(NULL));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    
    for(int i = 0; i < N; i++){
        arr[i] = rand() % 1000;
    }

    cudaEventRecord(start);
    
    for (unsigned int s=1; s < N; s *= 2) {
        for (unsigned int i=0; i < N; i++) {
            if (i + s < N) { 
                arr[i] = arr[i + s] > arr[i] ? arr[i + s]  : arr[i];
            }
        }
    }
    cudaEventRecord(stop);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("time : %f\n", milliseconds);

    printf("%d\n", arr[0]);
    return 0;
}