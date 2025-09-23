#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main();

void print_addr(const char *who) {
    printf("[%s] main address: %p\n", who, (void*)main);
    fflush(stdout);
}

int main() {
    print_addr("parent");

    // for (int i = 0; i < 10; ++i) {
    //     pid_t pid = fork();
    //     if (pid < 0) {
    //         perror("fork");
    //         exit(1);
    //     }
    //     if (pid == 0) {
    //         // child process
    //         print_addr("child");
    //         exit(0);
    //     }
    // }

    // // Wait for children to finish
    // for (int i = 0; i < 10; ++i) {
    //     wait(NULL);
    // }

    return 0;
}