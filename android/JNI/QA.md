1. Android 不会挂起执行原生(Native)代码的线程。如果正在进行垃圾回收，或者调试程序已发出挂起请求，则在线程下次调用 JNI 时，Android 会将其挂起。(不是应当结束 JNI 调用后，或者在调用 JNI 前挂起？ ) （https://developer.android.com/training/articles/perf-jni?hl=zh-cn）

2. 在取消加载类之前，类引用、字段 ID 和方法 ID 保证有效。只有在与 ClassLoader 关联的所有类可以进行垃圾回收时，系统才会取消加载类，这种情况很少见，但在 Android 中并非不可能。但请注意，jclass 是类引用，必须通过调用 NewGlobalRef 来保护它（请参阅下一部分）。 什么意思？

在执行 ID 查找的 C/C++ 代码中创建 nativeClassInit 方法。初始化类时，该代码会执行一次。如果要取消加载类之后再重新加载，该代码将再次执行。 创建的是本地方法名是固定的吗？


1. JNI 坑点

[添加多个与构建库。](https://developer.android.com/ndk/guides/prebuilts)

```makefile
LOCAL_PATH := $(call my-dir)

# 每个 so 文件都要独立定义一块，不能一次指定多个文件。
include $(CLEAR_VARS)
LOCAL_MODULE := engine_so # 不能一次指定多个文件。
LOCAL_SRC_FILES := ../../../../../libs/$(TARGET_ARCH_ABI)/libengine.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS) # 重置一些变量，否则路径可能不正确。
LOCAL_MODULE := ffmpeg_so
LOCAL_SRC_FILES := ../../../../../libs/$(TARGET_ARCH_ABI)/libffmpeg.so # 不重置变量会影响这里的路径。
include $(PREBUILT_SHARED_LIBRARY) # 导入
```

**即便声明了 so, 还要在声明依赖该 so 才能被打进包内。否则会被优化排除掉。**

```
LOCAL_SHARED_LIBRARIES := engine_so ffmpeg_so # 添加对与构建库的依赖才能被打进包中。
```


2. 支持分包过滤

```
android {
    ...
    defaultConfig {
        ...
        externalNativeBuild {
            ndkBuild {
                // Passes optional arguments to ndk-build.
                arguments 'NDK_DEBUG=1'

                buildTypes {
                    debug {
                        abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86'
                    }

                    release {
                        abiFilters 'armeabi-v7a'
                    }
                }
            }
        }
    }
}
```

> 1. Class Not Find


> 2. 调用方法分static和非static两种，两种方式的获取 ID 和调用方法需要对应，不能混用。

```
GetStaticMethodID   ---->    CallStatic<type>Method

GetMethodID         ----->   Call<type>Method
```
其中<type>指Int, Long, Char等类型

> 3. Native 无法调用 Java 方法

很可能是线程问题，需要调用 JavaVM::AttachCurrentThread()

```C++
static JavaVM* g_jvm = nullptr;

// Return a |JNIEnv*| usable on this thread.  Attaches to |g_jvm| if necessary.
JNIEnv* AttachCurrentThreadIfNeeded() {
  JNIEnv* jni = GetEnv();
  if (jni)
    return jni;
  RTC_CHECK(!pthread_getspecific(g_jni_ptr))
      << "TLS has a JNIEnv* but not attached?";

  std::string name(GetThreadName() + " - " + GetThreadId());
  JavaVMAttachArgs args;
  args.version = JNI_VERSION_1_6;
  args.name = &name[0];
  args.group = nullptr;
// Deal with difference in signatures between Oracle's jni.h and Android's.
#ifdef _JAVASOFT_JNI_H_  // Oracle's jni.h violates the JNI spec!
  void* env = nullptr;
#else
  JNIEnv* env = nullptr;
#endif
  RTC_CHECK(!g_jvm->AttachCurrentThread(&env, &args))
      << "Failed to attach thread";
  RTC_CHECK(env) << "AttachCurrentThread handed back NULL!";
  jni = reinterpret_cast<JNIEnv*>(env);
  RTC_CHECK(!pthread_setspecific(g_jni_ptr, jni)) << "pthread_setspecific";
  return jni;
}

并使用 attach 之后的 JNIEvn 调用 Call<Type>Method 方法
auto env = AttachCurrentThreadIfNeeded();
evn->CallVoidMethod(....)
```

> 4. 对于从 Java 传递的参数

Java JNI 传递过来的参数，会在函数调用完之后自动释放引用。如果需要在其它线程使用，需要调用 `JNIEnv::NewGlobalRef()` 创建一个全局引用，防止被释放。然后在不使用的时候使用 `JNIEnv::DeleteGlobalRef` 释放引用。

```
2022-04-29 09:36:30.414 22038-22038/? A/DEBUG: signal 6 (SIGABRT), code -1 (SI_QUEUE), fault addr --------
2022-04-29 09:36:30.414 22038-22038/? A/DEBUG: Abort message: 'JNI DETECTED ERROR IN APPLICATION: use of invalid jobject 0x7fc69bf6c8'
```


## FindClass error

在子线程创建的 JNIEnv 调用 `FindClass` 找到字节码，有两种方案可供选择：

1. 在主线程的时候就创建一个 `GlobalRef` 保存起来。

2. 在主线程的时候就创建一个 ClassLoader 的对象，当找不到 class 的时候，调用该 ClassLoader 加载 class.