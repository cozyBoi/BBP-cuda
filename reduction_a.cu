#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define N 10000

int arr[N];

int log2_N(int n){
    int a = 1;
    int i = 0;
    for(i = 0; a <= n; i++){}
        a *= 2;
    }
    return i;
}

int main() {
    srand(time(NULL));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    
    for(int i = 0; i < N; i++){
        arr[i] = rand() % 1000;
    }

    cudaEventRecord(start);
    int maxVal = arr[0];
    //int log2_Nnum = log_2(N);
    for (unsigned int s=1; s < N; s *= 2) {
        for (unsigned int i=1; i < N; i++) {
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

    printf("%d\n", maxVal);
    return 0;
}