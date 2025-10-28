#include "zset.hpp"
#include <iostream>
#include "lua.hpp"
#include <windows.h>
using namespace std;

int main() {
    #ifdef _WIN32
        system("chcp 65001 >nul");
        SetConsoleOutputCP(CP_UTF8);
    #endif
    // 初始化 Lua
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // 注册 SkipList<int> 类到 Lua
    SkipList<int> temp_obj;  // 使用栈对象，自动管理内存
    lua_register_class(L, &temp_obj);
    
    // 创建全局构造函数
    auto create_skiplist = [](lua_State* L) -> int {
        SkipList<int>* obj = new SkipList<int>();
        lua_push_object(L, obj);
        return 1;
    };
    lua_push_function(L, lua_global_function(create_skiplist));
    lua_setglobal(L, "SkipList");

    // 尝试加载 rank.lua
    const char* lua_paths[] = {
        "rank.lua",
        "../rank.lua",
        "../../rank.lua",
        "build/rank.lua",

    };

    bool loaded = false;
    for (int i = 0; lua_paths[i]; ++i) {
        if (luaL_dofile(L, lua_paths[i]) == LUA_OK) {
            loaded = true;
            break;
        }
        lua_pop(L, 1); // 清除错误栈
    }

    if (!loaded) {
        std::cerr << "Lua error: Cannot find rank.lua in any expected location\n";
        std::cerr << "Tried paths: ";
        for (int i = 0; lua_paths[i]; ++i)
            std::cerr << lua_paths[i] << " ";
        std::cerr << std::endl;
    }

    lua_close(L);
    return 0;
}
