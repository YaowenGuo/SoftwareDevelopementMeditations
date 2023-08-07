# 构建目标

Native 代码的构建目标有三种：共享库（静态和动态库）、可执行文件。可执行文件可以直接执行，而共享库则可以继续用于构建其他可执行文件。因此 CMake 设置编译目标只有两个函数。`add_library` 用于构建共享库，`add_executable` 则用于创建可执行程序。

- add_xxx 的 `add` 说明了一个 CMakeLists 可以定义多个构建目标，每个名字都是一个单独的目标。

## ADD_LIBRARY()语法

```
add_library(<name> [STATIC | SHARED | MODULE]
            [EXCLUDE_FROM_ALL]
            source1 [source2 ...])
```

- <name> ：库的名字，直接写名字即可，不要写lib，会自动加上后缀的。
- [STATIC | SHARED | MODULE] ：类型有三种。
    - SHARED,动态库
	- STATIC,静态库
	- MODULE,在使用 dyld 的系统有效,如果不支持 dyld,则被当作 SHARED 对待。
    - 如果没有明确指定库的类型，可以通过BUILD_SHARED_LIBS的值是否为ON来指定库的类型是SHARED还是STATIC，注意：这个参数是全局标志，默认是OFF。
- EXCLUDE_FROM_ALL：这个库不会被默认构建，除非有其他的组件依赖或者手工构建。


由于静态库和动态库的后缀在各个平台上不同，我们不必写后缀，编译工具会根据平台生成不同的后缀和格式。

```
```

### 示例

```
#找到包含所有的cpp文件
file(GLOB allCpp
        base/*.cpp
        main/*.cpp
        )

add_library(hello SHARED ${allCpp})   #共享库
add_library(hello_static STATIC ${allCpp})   #静态库
```

注意，因为默认规则是不能有相同名字的共享库（so）与静态库(a)，所以当生成静态库的时候，共享库会被删除，因为只能允许一个名字存在，相同名字的会被替代（hello），所以需要通过SET_TARGET_PROPERTIES()来解决这个问题，例子：

```
SET_TARGET_PROPERTIES(hello_static PROPERTIES OUTPUT_NAME "hello")
```
这样就可以生成libhello.so与libhello.a了

cmake在构建一个target的时候，会删除之前生成的target，一样是通过设置SET_TARGET_PROPERTIES(hello PROPERTIES CLEAN_DIRECT_OUTPUT 1)来达到目的

## (2)add_executable 

生成可执行文件，用法和上面差不多。


## 生成目录

默认情况下，可执行文件将会在该项目的构建树目录中被创建。可以通过CMAKE_RUNTIME_OUTPUT_DIRECTORY来改变可执行文件的归档路径。

```cmake
# 归档静态库到指定目录
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build/lib)
# 归档动态库到指定目录
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build/lib)
# 归档可执行文件到指定目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build/bin)
```

