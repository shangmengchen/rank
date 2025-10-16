cmake_minimum_required(VERSION 3.15)
project(rank LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(rank
    test.cpp
    zset.cpp
)

target_include_directories(rank PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})


