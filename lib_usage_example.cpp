/*
 * 使用 librank.a 静态库的示例代码
 * 
 * 编译命令:
 * g++ -std=c++17 -I. -Ithird_party/luna -Ilua-dev -Ilua-static -o example.exe lib_usage_example.cpp librank.a -lws2_32
 */

#include "zset/zset.hpp"
#include "third_party/luna/luna.h"
#include "lua.hpp"
#include <iostream>

int main() {
    // 初始化 Lua
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // 注册 SkipList 类到 Lua
    SkipList* temp_obj = new SkipList();
    lua_register_class(L, temp_obj);
    delete temp_obj;
    
    // 创建全局构造函数
    auto create_skiplist = [](lua_State* L) -> int {
        SkipList* obj = new SkipList();
        lua_push_object(L, obj);
        return 1;
    };
    lua_push_function(L, lua_global_function(create_skiplist));
    lua_setglobal(L, "SkipList");
    
    // 在 C++ 中直接使用 SkipList
    std::cout << "=== C++ 直接使用 SkipList ===" << std::endl;
    SkipList skiplist;
    skiplist.insert(10);
    skiplist.insert(20);
    skiplist.insert(15);
    
    std::cout << "插入数据后，跳表结构:" << std::endl;
    skiplist.display();
    
    bool found = skiplist.search(15);
    if (found) {
        std::cout << "搜索到数据: 15" << std::endl;
    }
    
    // 加载并执行 Lua 脚本
    std::cout << "\n=== 执行 Lua 脚本 ===" << std::endl;
    if (luaL_dofile(L, "rank.lua") != LUA_OK) {
        std::cerr << "Lua error: " << lua_tostring(L, -1) << std::endl;
        lua_pop(L, 1);
    }
    
    // 清理
    lua_close(L);
    
    return 0;
}
