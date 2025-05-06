#include <stdio.h>
#include "base/csapp.h"

_Thread_local int testTls = 0;
// 定义线程本地存储的键
pthread_key_t tls_key;
void tls_destructor(void *value) {
    // free(value);
    printf("Thread local storage destroyed\n");
}


/* thread routine */
void* thread(void* vargp) {
    // extern _Thread_local int testTls;
    testTls = 5;
    printf("Sub thread, value of testTls: %d\n", testTls);
    return NULL;
}

int main() {
    pthread_key_create(&tls_key, &tls_destructor);
    pthread_setspecific(tls_key, 0);
    pthread_t tid;
    Pthread_create(&tid, NULL, thread, NULL);
    Pthread_join(tid, NULL);
    printf("Main thread, value of testTls: %d\n", testTls);
    return 0;
}