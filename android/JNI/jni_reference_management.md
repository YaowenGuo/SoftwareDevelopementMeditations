# JNI 引用类型管理

JNI 中对象的引用有三种类型：

- 全局引用: 必须调用 `JNIEnv::DeleteGlobalRef` 进行释放才会被释放。
- 全局弱引用: 在 GC 发生时才会释放。
- 局部引用: 出了作用域就会释放。

三者顺序的引用强度是递减变弱的，有点类似于 Java 中的强引用、弱引用、软引用。

## 引用管理

### 局部引用

JNI 调用 Native 方法传进来的参数以及调用 JNI 函数返回值，如果是对象类型都是局部引用。例如

```C++
extern "C" JNIEXPORT void JNICALL
Java_tech_yaowen_rtc_1native_rtc_RTCEngine_call(JNIEnv *env, jclass clazz, jobject application_context, jobject jSignaling) {
    // 该函数被 JNI 调用，实参都是局部引用。

    // 返回类型是对象引用，是局部引用。
    auto jstr = env->NewString("Hello");
}
```

局部引用在超出作用域时，会被自动释放，不比手动释放。**但是局部引用的数量有限制，超出 512 时会报错(我在测试的时候始终无法出发该错误，不知道什么原因。)，因此当局部引用过多时，需要使用 `JNIEnv::DeleteLocalRef(jobject localRef)` 手动释放。例如在 for 循环中调用 `JNIEnv::NewString`。

***对于调用 JNI return 回来的对象，由于作用域不在 JNI 中，并不会自动释放，需要我们自己调用 JNIEnv::DeleteLocalRef***

### 全局引用

可以通过调用 `JNIEnv::NewGlobalRef(jobject obj)` 传递一个局部引用来创建全局应用。全局引用可以用来缓存资源，不必每次都重新加载，例如 jclass。

### 全局弱引用

弱引用通过 `JNIEnv::NewGlobalRef` 创建，可以跟全局引用一样缓存资源，但是每次使用前需要使用 `JNIEnv::IsSameObject(globalWeekRef, nullptr)`判断不为空指针才能继续使用。


### 字符串获取之后也应该释放

```
std::string jstring2str(JNIEnv *env, jstring jstr) {
    const char *charArr = env->GetStringUTFChars(jstr, nullptr);
    std::string str(charArr); // 深拷贝
    env->ReleaseStringUTFChars(jstr, charArr);
    return str;
}
```

**GetStringUTFChars 之后总是要调用 ReleaseStringUTFChars 进行释放，无论是否是拷贝类类型的获取。**

https://stackoverflow.com/questions/5859673/should-you-call-releasestringutfchars-if-getstringutfchars-returned-a-copy