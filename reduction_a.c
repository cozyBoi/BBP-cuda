#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define N 10000

int main() {
    srand(time(NULL));

    int arr[N];
    for(int i = 0; i < N; i++){
        arr[i] = rand();
    }

    int maxVal = arr[0];
    for(int i = 0; i < N; i++){
        maxVal = maxVal < arr[i] ? arr[i] : maxVal;
    }

    printf("%d\n", maxVal);
    return 0;
}