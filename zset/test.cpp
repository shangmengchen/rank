#include "zset.hpp"
#include <iostream>
#include "lua.hpp"

using namespace std;

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
    
    // 加载并执行 Lua 脚本
    // 尝试多个可能的路径
    const char* lua_paths[] = {
        "rank.lua",           // 当前目录
        "../rank.lua",        // 上级目录
        "../../rank.lua",     // 上两级目录
        "build/rank.lua",     // build 子目录
        nullptr
    };
    
    bool script_loaded = false;
    for (int i = 0; lua_paths[i] != nullptr; i++) {
        if (luaL_dofile(L, lua_paths[i]) == LUA_OK) {
            script_loaded = true;
            break;
        }
        // 清除错误信息
        lua_pop(L, 1);
    }
    
    if (!script_loaded) {
        cerr << "Lua error: Cannot find rank.lua in any expected location" << endl;
        cerr << "Tried paths: ";
        for (int i = 0; lua_paths[i] != nullptr; i++) {
            cerr << lua_paths[i] << " ";
        }
        cerr << endl;
    }
    
    // 清理
    lua_close(L);
    
    return 0;
}