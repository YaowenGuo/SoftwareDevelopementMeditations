#include "base/csapp.h"
void* thread(void* vargp);

int main() {
    pthread_t tid;
    Pthread_create(&tid, NULL, thread, NULL);
    sleep(5);
    exit(0);
}

/* thread routine */
void* thread(void* vargp) {
    Pthread_detach(pthread_self());
    printf("Hello, world!\n");
    while (1) {
    };
    return NULL;
}