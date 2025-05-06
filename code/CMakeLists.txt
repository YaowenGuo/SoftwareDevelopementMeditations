cmake_minimum_required(VERSION 3.29)
project(Test VERSION 1.0)
set (CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_C_STANDARD 23)  # 设置C语言标准为C23
set(CMAKE_C_STANDARD_REQUIRED ON)  # 确保编译器支持C23标准
set(CMAKE_C_EXTENSIONS OFF)  # 禁用编译器特定的扩展，确保严格遵循C23标准

# 找到包含所有的cpp文件
file(GLOB base base/*.c)

add_subdirectory(system)
add_executable(test test.c)
