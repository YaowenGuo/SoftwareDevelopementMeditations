#include <stdlib.h>


void testMalloc() {
    int *intP = (int *)malloc(sizeof(int));
    *intP = 2;
}
/**
 * @brief 测试空指针内存访问
 */
int main(int argc, char *argv[]) {
    int *data = (int *)malloc(100 * sizeof(int));
    free(data + 50);
    // data[50] = 2;
    return 0;
}