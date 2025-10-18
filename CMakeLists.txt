cmake_minimum_required(VERSION 3.9)
project(rank LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 设置路径
set(LUNA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/luna")
set(LUA_STATIC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lua-static")
set(LUA_DEV_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lua-dev")

# 包含头文件目录
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${LUNA_DIR})
include_directories(${LUA_DEV_DIR})
include_directories(${LUA_STATIC_DIR})

# 添加 Luna 源文件
set(LUNA_SOURCES
    ${LUNA_DIR}/luna.cpp
    ${LUNA_DIR}/lua_archiver.cpp
    ${LUNA_DIR}/var_int.cpp
    ${LUNA_DIR}/lz4.c
)

# 添加 Lua 源文件（排除 lua.c 和 luac.c）
file(GLOB LUA_SOURCES "${LUA_STATIC_DIR}/*.c")
list(REMOVE_ITEM LUA_SOURCES "${LUA_STATIC_DIR}/lua.c" "${LUA_STATIC_DIR}/luac.c")

# 设置编译选项
if(WIN32)
    add_definitions(-DLUA_USE_WINDOWS)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
endif()

# 创建静态库
add_library(rank_lib STATIC
    zset/zset.cpp
    ${LUNA_SOURCES}
    ${LUA_SOURCES}
)

# 创建可执行文件
add_executable(rank
    zset/test.cpp
)

# 链接库
target_link_libraries(rank rank_lib)
if(WIN32)
    target_link_libraries(rank ws2_32)
endif()


