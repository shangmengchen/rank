# Rank 静态库使用指南

## 概述

`librank.a` 是一个包含以下组件的静态库：
- **Luna 库**: C++/Lua 绑定框架
- **Lua 5.4.2**: 完整的 Lua 解释器
- **LZ4**: 压缩库
- **SkipList**: 跳表数据结构实现

## 库内容

### 核心组件
- `SkipList` 类：高性能的跳表数据结构
- Luna 绑定系统：简化 C++/Lua 交互
- Lua 解释器：完整的 Lua 5.4.2 运行时
- 序列化支持：数据压缩和序列化功能

### 头文件依赖
使用库时需要包含以下头文件：
```cpp
#include "zset/zset.hpp"           // SkipList 类
#include "third_party/luna/luna.h" // Luna 绑定
#include "lua.hpp"                 // Lua 接口
```

## 编译方法

### 方法一：使用批处理脚本
```bash
# 构建库和示例
.\build.bat

# 编译自定义程序
g++ -std=c++17 -I. -Ithird_party/luna -Ilua-dev -Ilua-static -o myapp.exe myapp.cpp librank.a -lws2_32
```

### 方法二：使用 CMake
```cmake
# 在你的 CMakeLists.txt 中
add_executable(myapp myapp.cpp)
target_link_libraries(myapp rank_lib)
if(WIN32)
    target_link_libraries(myapp ws2_32)
endif()
```

### 方法三：手动编译
```bash
# 基本编译命令
g++ -std=c++17 -I. -Ithird_party/luna -Ilua-dev -Ilua-static -o myapp.exe myapp.cpp librank.a -lws2_32

# 调试版本
g++ -std=c++17 -g -I. -Ithird_party/luna -Ilua-dev -Ilua-static -o myapp_debug.exe myapp.cpp librank.a -lws2_32

# 优化版本
g++ -std=c++17 -O3 -I. -Ithird_party/luna -Ilua-dev -Ilua-static -o myapp_release.exe myapp.cpp librank.a -lws2_32
```

## 使用示例

### 1. 基本 C++ 使用
```cpp
#include "zset/zset.hpp"
#include <iostream>

int main() {
    SkipList skiplist;
    
    // 插入数据
    skiplist.insert(10, "data10");
    skiplist.insert(20, "data20");
    
    // 搜索数据
    auto result = skiplist.search(10);
    if (result) {
        std::cout << "找到: " << result << std::endl;
    }
    
    return 0;
}
```

### 2. C++/Lua 混合使用
```cpp
#include "zset/zset.hpp"
#include "third_party/luna/luna.h"
#include "lua.hpp"

int main() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    
    // 注册类到 Lua
    SkipList* temp_obj = new SkipList();
    lua_register_class(L, temp_obj);
    delete temp_obj;
    
    // 创建构造函数
    auto create_skiplist = [](lua_State* L) -> int {
        SkipList* obj = new SkipList();
        lua_push_object(L, obj);
        return 1;
    };
    lua_push_function(L, lua_global_function(create_skiplist));
    lua_setglobal(L, "SkipList");
    
    // 执行 Lua 脚本
    luaL_dofile(L, "script.lua");
    
    lua_close(L);
    return 0;
}
```

### 3. Lua 脚本示例
```lua
-- script.lua
local skiplist = SkipList()

-- 插入数据
skiplist:insert(1, "first")
skiplist:insert(2, "second")

-- 搜索数据
local result = skiplist:search(1)
if result then
    print("找到数据:", result)
end

-- 删除数据
skiplist:remove(1)
print("删除后大小:", skiplist.size)
```

## API 参考

### SkipList 类

#### 构造函数
```cpp
SkipList();  // 创建空的跳表
```

#### 主要方法
```cpp
// 插入键值对
void insert(int key, const std::string& value);

// 搜索键对应的值
std::string* search(int key);

// 删除键值对
bool remove(int key);

// 获取跳表大小
int size;
```

#### Lua 绑定
在 Lua 中，所有方法都可以直接调用：
```lua
local obj = SkipList()
obj:insert(1, "value")
local result = obj:search(1)
obj:remove(1)
print(obj.size)
```

## 性能特性

- **时间复杂度**:
  - 插入: O(log n)
  - 搜索: O(log n)
  - 删除: O(log n)
- **空间复杂度**: O(n)
- **内存管理**: 自动垃圾回收（Lua 托管）

## 平台支持

- **Windows**: 完全支持（当前主要平台）
- **Linux**: 需要调整编译选项
- **macOS**: 需要调整编译选项

## 故障排除

### 常见编译错误

1. **找不到头文件**
   ```
   解决方案: 确保包含正确的头文件路径
   -I. -Ithird_party/luna -Ilua-dev -Ilua-static
   ```

2. **链接错误**
   ```
   解决方案: 确保链接了 ws2_32 库
   -lws2_32
   ```

3. **C++17 支持**
   ```
   解决方案: 使用支持 C++17 的编译器
   -std=c++17
   ```

### 运行时问题

1. **Lua 脚本加载失败**
   - 检查脚本文件路径
   - 确保脚本语法正确

2. **内存泄漏**
   - 确保正确调用 `lua_close(L)`
   - 避免在 Lua 托管的对象上手动 delete

## 扩展开发

### 添加新的 C++ 类到 Lua

1. 在类声明中添加：
```cpp
class MyClass final {
    // ... 成员 ...
public:
    DECLARE_LUA_CLASS(MyClass);
};
```

2. 在 cpp 文件中实现：
```cpp
LUA_EXPORT_CLASS_BEGIN(MyClass)
LUA_EXPORT_METHOD(myMethod)
LUA_EXPORT_PROPERTY(myProperty)
LUA_EXPORT_CLASS_END()
```

3. 注册到 Lua：
```cpp
MyClass* temp = new MyClass();
lua_register_class(L, temp);
delete temp;
```

## 许可证

请参考各组件各自的许可证：
- Luna: 查看 `third_party/luna/LICENSE`
- Lua: MIT 许可证
- LZ4: BSD 许可证


