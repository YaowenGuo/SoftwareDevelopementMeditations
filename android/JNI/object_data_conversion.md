# 对象转换

基本类型的数据，Java 和 Native 中通过函数传递时是值拷贝，因此有直接的类型作为对应。例如 java int 类型对应一个 32 位的 jint。之所以没有直接对应 C/C++ 的int，是因为 C 并没有规定 int 的长度，例如在 16 位机器上，int 则是一个 16 位数据，而 Java 的 int 类型固定是 32 位，因此 jni 定义了 jint 保持在不同平台的一致性。

对于复杂类型，Java 都使用引用来持有对象。引用对应一个 jobject 类型。想要获取这些对象，Native 采用不同的管理方式，因此需要做特殊的转换。

## String

### Native 访问 Java 字符串

Java 的字符串在 Native 中是一个 jstring 类型。为了转化为 C 字符串。

```C++

```

## Array


### Native 访问 Java Array

Native 中所有的 Array 类型，都是同一个种类型 `_jarray` 的空继承。因此获取 Array 类型的方法其实是通用的。
```C++
class _jobjectArray : public _jarray {};
class _jbooleanArray : public _jarray {};
...

typedef _jobjectArray*  jobjectArray;
typedef _jbooleanArray* jbooleanArray;
...
```

获取数组长度

```C++
jsize JNIEnv::GetArrayLength(jarray array);
```

获取元素

```C++
jbyte* JNIEnv::GetByteArrayElements(jbyteArray array, jboolean* isCopy);
jint* JNIEnv::GetIntArrayElements(jbyteArray array, jboolean* isCopy);
...
// 获取指定范围内的对象
void JNIEnv::GetBooleanArrayRegion(jbooleanArray array, jsize start, jsize len, jboolean* buf);
void GetByteArrayRegion(jbyteArray array, jsize start, jsize len, jbyte* buf);
...

// 释放
void JNIEnv::ReleaseBooleanArrayElements(jbooleanArray array, jboolean* elems, jint mode);
void JNIEnv::ReleaseByteArrayElements(jbyteArray array, jbyte* elems, jint mode);
```

**凡是获取的非基本类型，都需要释放。**

## 对象

访问对象类型的字段和方法，都需要先获得 class，然后获得到 class 的字段/方法，最后才能通过获得的字段/方法与 jobject 一起访问字段/方法。

先获得类。

```C++
jclass JNIEnv::FindClass(const char* name);
// 如  auto engineCls = env->FindClass("tech/yaowen/rtc_native/rtc/RTCEngine");
```

### Native 访问 Java 对象

先获得字段ID

```C++
jfieldID JNIEnv::GetFieldID(jclass clazz, const char* name, const char* sig);
// 静态字段
jfieldID JNIEnv::GetStaticFieldID(jclass clazz, const char* name, const char* sig)
// 如 auto filedId = env->GetFieldID(engineCls, "connected", "Z");
```

设置
```C++
void JNIEnv::SetObjectField(jobject obj, jfieldID fieldID, jobject value);
void JNIEnv::SetBooleanField(jobject obj, jfieldID fieldID, jboolean value);
...
// 静态字段
void JNIEnv::SetStaticObjectField(jclass clazz, jfieldID fieldID, jobject value);
void JNIEnv::SetStaticBooleanField(jclass clazz, jfieldID fieldID, jboolean value);
```

获取
```C++
jobject JNIEnv::GetObjectField(jobject obj, jfieldID fieldID);
jboolean JNIEnv::GetBooleanField(jobject obj, jfieldID fieldID);
...
// 静态字段通过 jclass 对象获取
jobject JNIEnv::GetStaticObjectField(jclass clazz, jfieldID fieldID);
jboolean JNIEnv::GetStaticBooleanField(jclass clazz, jfieldID fieldID);
...
```