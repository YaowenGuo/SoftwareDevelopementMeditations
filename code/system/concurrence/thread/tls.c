#include <stdio.h>
#include "base/csapp.h"

thread_local int testTls = 0;
// 定义线程本地存储的键
pthread_key_t tls_key;
void tls_destructor(void *value) {
    printf("Thread local storage destroyed\n");
    free(value);
}


/* thread routine */
void* thread1(void* vargp) {
    char *data = (char *)malloc(100);
    pthread_setspecific(tls_key, (void *)data);
    testTls = 5;
    printf("Sub thread, value of testTls: %d\n", testTls);
    return NULL;
}

/* thread routine */
void* thread2(void* vargp) {
    testTls = 10;
    printf("Sub thread, value of testTls: %d\n", testTls);
    return NULL;
}

int main() {
    if (pthread_key_create(&tls_key, tls_destructor) != 0) {
        perror("pthread_key_create");
        return 1;
    }

    pthread_t tid1, tid2;
    Pthread_create(&tid1, NULL, thread1, NULL);
    Pthread_create(&tid2, NULL, thread2, NULL);
    Pthread_join(tid1, NULL);
    Pthread_join(tid2, NULL);
    printf("Main thread, value of testTls: %d\n", testTls);
    return 0;
}

// #include <pthread.h>
// #include <stdio.h>
// #include <stdlib.h>
// #include <unistd.h>

// // 定义一个全局的 pthread_key_t 变量
// pthread_key_t key;

// // 定义一个清理函数，会在每个线程退出时调用
// void cleanup(void *value) {
//     printf("Cleanup function called for thread %ld, value: %s\n",
//            (long)pthread_self(), (char *)value);
//     free(value);
// }

// // 定义一个线程函数，模拟线程的工作
// void *thread_function(void *arg) {
//     char *data = (char *)malloc(100);
//     sprintf(data, "Data for thread %ld", (long)pthread_self());
//     pthread_setspecific(key, data);
//     printf("Thread %ld is running\n", (long)pthread_self());
//     sleep(1);
//     return NULL;
// }

// int main() {
//     // 创建一个 pthread_key_t 变量，并设置清理函数
//     if (pthread_key_create(&key, cleanup) != 0) {
//         perror("pthread_key_create");
//         return 1;
//     }

//     // 创建多个线程并启动
//     pthread_t threads[5];
//     for (int i = 0; i < 5; i++) {
//         if (pthread_create(&threads[i], NULL, thread_function, NULL) != 0) {
//             perror("pthread_create");
//             return 1;
//         }
//     }

//     // 等待所有线程完成
//     for (int i = 0; i < 5; i++) {
//         if (pthread_join(threads[i], NULL) != 0) {
//             perror("pthread_join");
//             return 1;
//         }
//     }

//     printf("All threads completed\n");

//     // 销毁 pthread_key_t 变量
//     if (pthread_key_delete(key) != 0) {
//         perror("pthread_key_delete");
//         return 1;
//     }

//     return 0;
// }