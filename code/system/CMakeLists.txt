add_subdirectory(memory)

add_executable(thread thread.c ${base})
target_include_directories(thread PUBLIC
        ${CMAKE_SOURCE_DIR})

        