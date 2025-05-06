# 测试线程
add_executable(thread thread.c ${base})
target_include_directories(thread PUBLIC ${CMAKE_SOURCE_DIR})

# 测试线程本地存储 Thread Local Storage
add_executable(tls tls.c ${base})
target_include_directories(tls PUBLIC ${CMAKE_SOURCE_DIR})