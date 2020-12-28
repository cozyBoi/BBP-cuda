#include <stdio.h>
#define N 10000

int main() {
    int arr[N];
    int maxVal = arr[0];
    for(int i = 0; i < N; i++){
        maxVal = maxVal < arr[i] ? arr[i] : maxVal;
    }
    return 0;
}