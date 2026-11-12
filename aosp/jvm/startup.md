# ART 虚拟机创建流程

> 目标：虚拟机的创建过程。`JNI_CreateJavaVM` 是 JNI 规范定义的创建入口。

## JNI 接口层

JNI_CreateJavaVM(JavaVM **pvm, void **penv, void *args)： 创建虚拟机实例。返回 JavaVM 和 JNIEnv 引用。JavaVM 是虚拟机句柄， JNIEnv 是线程上下文句柄，每个线程都有单独的，这也是为什么通过 JNIEnv 调用 Java 方法不能跨线程传递。

> JavaVM 方法

- DestroyJavaVM： 销毁一个虚拟机。
- AttachCurrentThread(): 将当前本地线程附着到虚拟机，并获取该线程的 JNIEnv 指针
- DetachCurrentThread(): 将已附着的本地线程从虚拟机分离
- GetEnv(): 获取当前线程的 JNIEnv 指针。
- AttachCurrentThreadAsDaemon(): 以守护线程模式附着当前本地线程。


> JNIEnv：线程级别的 JNI 函数表

JNIEnv 是 JNI 的核心，提供了大部分 JNI 功能。所有操作 Java 的方法都在这里。例如:

- 版本与类信息
    *   `GetVersion`: 获取 JNI 版本
    *   `FindClass`: 加载本地类定义
    *   `GetSuperclass`: 获取父类
    *   `IsAssignableFrom`: 判断类型兼容性

- 类与对象操作
    *   `DefineClass`: 从原始字节数据中定义一个新类
    *   `AllocObject`: 分配对象而不调用构造方法
    *   `NewObject` / `NewObjectV` / `NewObjectA`: 创建对象并调用构造方法
    *   `GetObjectClass`: 获取对象的类
    *   `IsInstanceOf`: 判断对象是否为特定类的实例

- 字段与方法 ID
    *   `GetFieldID`: 获取实例字段的 ID
    *   `GetMethodID`: 获取实例方法的 ID

- 方法调用
    *   `Call<Type>Method` 系列: 调用 Java 实例方法
    *   `CallNonvirtual<Type>Method` 系列: 调用特定父类的方法
    *   `CallStatic<Type>Method` 系列: 调用 Java 静态方法
...


## ART 虚拟机的创建方式。


```cpp
// frameworks/base/core/jni/AndroidRuntime.cpp
void AndroidRuntime::start(const char* className, const Vector<String8>& options, bool zygote)
{
    ...
    /* start the virtual machine */
    JniInvocation jni_invocation;
    jni_invocation.Init(NULL);
    JNIEnv* env;
    // `startVm()` 内部调用 JNI 规范的 `JNI_CreateJavaVM` 创建虚拟机实例。
    if (startVm(&mJavaVM, &env, zygote, primary_zygote) != 0) {
        return;
    }
    onVmCreated(env);
    ...
    // 调用 com/android/internal/os/ZygoteInit.java 的 main() 方法，进入 Java 世界。
    char* slashClassName = toSlashClassName(className != NULL ? className : "");
    jclass startClass = env->FindClass(slashClassName);
    jmethodID startMeth = env->GetStaticMethodID(startClass, "main", "([Ljava/lang/String;)V"); 

    env->CallStaticVoidMethod(startClass, startMeth, strArray);
    ...
}
```

## Java 虚拟机的内部 Runtime 才是核心
```C++
// art/runtime/jni/java_vm_ext.cc
extern "C" EXPORT jint JNI_CreateJavaVM(JavaVM** p_vm, JNIEnv** p_env, void* vm_args) {
  ScopedTrace trace(__FUNCTION__);
  ...
  RuntimeOptions options;
  for (int i = 0; i < args->nOptions; ++i) {
    JavaVMOption* option = &args->options[i];
    options.push_back(std::make_pair(std::string(option->optionString), option->extraInfo));
  }
  bool ignore_unrecognized = args->ignoreUnrecognized;
  if (!Runtime::Create(options, ignore_unrecognized)) {
    return JNI_ERR;
  }
  ...
  Runtime* runtime = Runtime::Current();
  bool started = runtime->Start();
  if (!started) {
    delete Thread::Current()->GetJniEnv();
    delete runtime->GetJavaVM();
    LOG(WARNING) << "CreateJavaVM failed";
    return JNI_ERR;
  }

  *p_env = Thread::Current()->GetJniEnv();
  *p_vm = runtime->GetJavaVM();
  return JNI_OK;
}

// art/runtime/runtime.cc
bool Runtime::Create(RuntimeArgumentMap&& runtime_options) {
  // TODO: acquire a static mutex on Runtime to avoid racing.
  if (Runtime::instance_ != nullptr) {
    return false;
  }
  instance_ = new Runtime;
  Locks::SetClientCallback(IsSafeToCallAbort);
  if (!instance_->Init(std::move(runtime_options))) {
    // TODO: Currently deleting the instance will abort the runtime on destruction. Now This will
    // leak memory, instead. Fix the destructor. b/19100793.
    // delete instance_;
    instance_ = nullptr;
    return false;
  }
  return true;
}
```

`JNI_CreateJavaVM` 内部会走 `Runtime::Create()` → `Runtime::Init()`：初始化堆/GC、`ClassLinker`、加载启动镜像 `boot.art` / `boot.oat` 等。**这一层已属于 ART 内部**，想深入可从 `art/runtime/runtime.cc` 看起。

| 阶段 | 源码位置 | 关键调用 |
|---|---|---|
| JNI 入口 | `frameworks/base/core/jni/AndroidRuntime.cpp` | `startVm` → `JNI_CreateJavaVM` |
| ART 内部（选修） | `art/runtime/runtime.cc`、`art/runtime/jni/java_vm_ext.cc` | `Runtime::Create / Init`、`JNI_CreateJavaVM` |
