#include <sys/prctl.h>
#include <sys/mman.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>

int main() {
    // 使用 mmap 创建一段匿名内存映射
    size_t length = 1024 * 1024; // 1 MB
    void *addr = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (addr == MAP_FAILED) {
        perror("mmap failed");
        return 1;
    }

    printf("Memory mapped at: %p\n", addr);

    // 尝试为这段匿名内存设置名称
    int ret = prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, (unsigned long)addr, length, "mimalloc_test");
    // prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, p, size, "mimalloc");
    if (ret == -1) {
        perror("prctl(PR_SET_VMA_ANON_NAME) failed");
        munmap(addr, length);
        return 1;
    }

    printf("prctl succeeded. Check /proc/%d/maps now. Press Enter to exit...\n", getpid());
    getchar(); // 暂停，等待用户输入

    munmap(addr, length);
    return 0;
}
