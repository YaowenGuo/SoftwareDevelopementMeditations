#include <stdio.h>
#include <stdlib.h>


/**
 * @brief 测试系统可以申请多少兆内存
 * 
 * @param argc 命令行参数数量
 * @param argv 命令行参数
 * @return int 正常返回 0
 */
int main(int argc, char *argv[]) {
    int sizeOfMb = 1 << 20;
    if (argc > 1) {
        sizeOfMb *= atoi(argv[1]);
        char* memory = (char *)malloc(sizeOfMb);
        free(memory);
        return 0;
    }
    printf("Not specify memory size. Will allocate 1 MB every time.\n");
    for (long allocalTime = 0; 1; ++allocalTime) {
        char* memory = (char *)malloc(sizeOfMb);
        printf("Allocate size: %ld MB", allocalTime);
    }
    return 0;
}