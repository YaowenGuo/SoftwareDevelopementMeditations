# Java 和 Native 交互


## Java 调用 Native 方法

Java 能够调用动态库中的方法，有两种方式：（有很多博客将其称为静态注册和动态注册，我觉得不合理，通过以下的讲解应该能够发现，通过方法名规则调用的方式根本没有注册，而是 动态库的动态链接而已。）
- 动态链接：就是之前所属的按照方法名规则命名函数的映射方式。
- 注册链接：使用 `JNI::RegisterNatives` 注册方法，以建立方法表。不使用的时候需要使用 `JNI::UnregisterNatives` 取消注册。

> [比较](https://blog.csdn.net/Saintyyu/article/details/90452826):

要比较两种方法，需要了解 Java 调动 Native 方法的流程。在调用 Native 方法之前，大致有两个步骤需要执行：

1. `System.loadLibrary` 根据名字定位并加载共享库到内存。

2. 虚拟机定位 native 方法实现位于加载的共享库之一。例如 Foo.g 方法调用需要定位并链接 native 方法 Java_Foo_g，可能位于 `foo.dll.`。

而 `JNI::RegisterNatives` 提供了代替步骤 2 的方式。JNI 开发者可以通过使用类引用、方法名和方法描述符注册函数指针来手动链接 native 方法，而不是依赖于虚拟机在已经加载的 native 库中搜索方法。


> 动态链接的好处：

简单，按照规则生成函数名即可。

> 注册链接的好处：

1. 注册链接的方法名不必按照规则命名，比较简洁灵活。

2. 可以根据需要动态绑定到不同的方法上。如果原生方法在程序运行中更新了，可以通过调用registerNative 方法进行更新。

3. 通过 registerNatives 方法在类被加载的时候就主动将原生方法链接到调用方，比当方法被使用时再由虚拟机来定位和链接更方便有效；（当我第一次看到这个的时候，我很奇怪为什么高效？动态注册需要在 so 中查找方法，而注册链接需要在注册表中查找。都是查找怎么就高效了？仔细研究发现，高效这个有两个方面，一是虚拟机加载的动态库很多，动态链接查找所有的动态库进行链接比进查找注册的表要慢很多。二是注册可以通过一下 hash 等算法（猜的）加快查找流程。）

4. Java程序需要调用一个原生应用提供的方法时，因为虚拟机只会检索动态库，因而虚拟机是无法定位到原生方法实现的，这个时候就只能使用 registerNatives() 方法进行主动链接。


缺点：注册比较麻烦。**同时，注册链接必须在一个直接链接的方法中进行注册。注册要么在 JNI_OnLoad 中，否则需要自己定义一个动态链接的方法，在类加载的时候进行注册。例如 Object 类，甚至System类、Class类、ClassLoader类、Unsafe 类的 registerNatives 方法，就是用于动态注册的。**

```Java
private static native void registerNatives();
    static {
        registerNatives();
    }
```

**注意：Android 移除了该方法，因此你在安卓版本的 Java 代码中找不到改方法**

### 动态链接调用

动态链接之前已经演示，不再重复。

### 注册链接调用

```C++
JNIEnv::RegisterNatives(
    jclass clazz,
    const JNINativeMethod* methods,
    jint nMethods
);
```
注册方法包含三个参数，第一个参数是 Java native 方法的类名，包使用 `/` 分割，例如 `java.lang.Object` 需要使用 `java/lang/Object`。第二个参数是一个 JNINativeMethod 结构体数组，第三个参数是第二个数组的长度。

JNINativeMethod 的结构为：

```C++
struct {
    const char* name;  // java native 方法名
    const char* signature; // 方法描述符
    void*       fnPtr;  // native 方法指针。
} JNINativeMethod;
```

例如对于如下的方法：

```Java
package tech.yaowen.opengles3_native.base;


class ColorRendererNative {

    private native void surfaceCreated(int color);

    private native void surfaceChanged(int width, int height);

    private native void onDrawFrame();
}
```

```C++
jint register_natives(
    JNIEnv *env,
    const char* clasName,
    const JNINativeMethod* methods,
    int num_methods
) {
    auto jclass = env->FindClass(clasName);
    if (jclass == nullptr) {
        return JNI_ERR;
    }
    return env->RegisterNatives(jclass, methods, num_methods);
}

// 第二列为方法描述符。括号中为参数列表，括号后面为返回值类型。描述符的对应关系在后面的表中。
JNINativeMethod methods[] = {
        {"surfaceCreated", "(I)V",  (void *) surfaceCreated},
        {"surfaceChanged", "(II)V", (void *) surfaceChanged},
        {"onDrawFrame",    "()V",   (void *) onDrawFrame}
};

// 类名
#define COLLOR_RENDER_CLASS "tech/yaowen/opengles3/renderer/ColorRendererNative"

// 注册
register_natives(env, COLLOR_RENDER_CLASS, methods, sizeof(methods) / sizeof(methods[0]);
```

这里涉及到 Java 中数据类型在 JNI 中的表示。

| Java Type          |  Native Typ    |  Descriptor    |     size        |
| ------------------ | -------------- | -------------- | --------------- |
| boolean            |	jboolean      |  Z  *	       | unsigned 8 bits |
| byte               |	jbyte         |  B             | signed 8 bits   |
| char               |	jchar         |  C             | unsigned 16 bits|
| short              |	jshort        |  S	           | signed 16 bits  |
| int                |	jint          |  I	           | signed 32 bits  |
| long               |	jlong         |  J	 *         | signed 64 bits  |
| float              |	jfloat        |  F	           | 32 bits         |
| double             |	jdouble       |  D	           | 64 bits         |
| void               |	void          |  V	           | N/A             |
| java.lang.Class    |	jclass        | Ljava/lang/Class;   | ~          |
| java.lang.String   |	jstring       | Ljava/lang/String;  | ~          |
| java.lang.Throwable|	jthrowable    | Ljava/lang/Throwable| ~          |
| `<object>`         |	jobject       | `L<object name>;`   | ~          |
| boolean[]          |	jbooleanArray |  [Z	                | ~          |
| `<base type>`[]    | `j<type>Array` | `[<Descriptor>`     | ~          |
| Object[]           |	jobjectArray  | [Ljava/lang/Object; | ~          |

描述符标 `*` 的为非类型首字母大写的类型。

数组的描述符以"["和对应的类型描述符来表述。对于二维数组以及三维数组则以"[["和"[[["表示：

| Descriptor            | Java Langauage Type |
| --------------------- | ------------------- |
| [[I	                | int[][]             |
| [[[D   	            | double[][][]        |
| [Ljava/lang/Object;   | Object[]            |


## Native 调用 Java 方法

首先要获得 jclass 对象。

```C++
jclass JNIEnv::FindClass(const char* name);
// 如  auto engineCls = env->FindClass("tech/yaowen/rtc_native/rtc/RTCEngine");
// 或者通过对象获取
jclass JNIEnv::GetObjectClass(jobject obj);
```


然后获得方法 id

```C++
// name 就是 java 的方法名，sig 就是参数列表和返回类型的字符串表示。
jmethodID JNIEnv::GetMethodID(jclass clazz, const char* name, const char* sig)
// 静态方法
jmethodID JNIEnv::GetStaticMethodID(jclass clazz, const char* name, const char* sig)
```

如果是构造方法，使用同样的方法获取，但是 name 是 `<init>`。

调用方法

```C++
void JNIEnv::Call[Static]<return_type>Method(jobject obj, jmethodID methodID, ...);
```

调用构造方法由点特殊，需要调用 `NewObject`。

```C++
jobject JNIEnv::NewObject(jclass clazz, jmethodID methodID, ...);
```
NewObject 也可以使用以下两个方法代替，但是不推荐使用，NewObject 更简单。

```C++
// 仅申请空间
jobject JNIEnv::AllocObject(jclass clazz);
// 调用构造函数初始化
void JNIEnv::CallNonvirtualVoidMethod(jobject obj, jclass clazz, jmethodID methodID, ...);

```