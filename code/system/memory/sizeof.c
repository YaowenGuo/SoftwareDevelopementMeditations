#include <stdio.h>
#include <stdlib.h>

int main() {
    int x[10] = {0};
    int* xCopy = (int*)malloc(sizeof(x));
    // 这里只申请了 int * 的大小，而不是 int[10].
    int* intP = (int*)malloc(sizeof(xCopy));
    printf("%d\n", sizeof(xCopy));

    // int *x = (int *)malloc(10 * sizeof(int));
    // printf("%d\n", sizeof(x));
    return 0;
}