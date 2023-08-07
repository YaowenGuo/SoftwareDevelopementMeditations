[include_directories 和 target_include_directories 的区别](https://stackoverflow.com/questions/31969547/what-is-the-difference-between-include-directories-and-target-include-directorie)

```cmake
target_include_directories(MathFunctions
          INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
          )
```
`INTERFACE` 用于表述任何链接 MathFunctions 的目标都需要包括当前的源目录，而MathFunctions 库自己不需要。

当外部库使用 `target_link_libraries` 添加了本库时，不在需要导入头文件，这些头文件会被自动导入到目标库中。例如：
```cmake
add_subdirectory(MathFunctions)
list(APPEND EXTRA_LIBS MathFunctions)
target_link_libraries(Tutorial PUBLIC ${EXTRA_LIBS})
```
在此，`Tutorial` 不需要再指定导入 `MathFunctions` 中的头文件，其头文件自动通过`依赖传递` 到目标的源文件中，而不用使用 `target_include_directories` 去包含 `MathFunctions` 中的头文件。
