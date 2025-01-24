cmake_minimum_required(VERSION 3.29)
project(Test VERSION 1.0)
set (CMAKE_EXPORT_COMPILE_COMMANDS ON)

#找到包含所有的cpp文件
file(GLOB base base/*.c)

add_subdirectory(system)
add_executable(test test.c)