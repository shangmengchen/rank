-- Lua 脚本示例：使用 C++ SkipList 类
print("=== Lua 脚本测试 SkipList ===")

-- 创建 SkipList 实例
local list = SkipList()

-- 插入数据
print("插入数据...")
list:insert(3)
list:insert(6)
list:insert(7)
list:insert(9)
list:insert(12)
list:insert(19)
list:insert(17)
list:insert(26)
list:insert(21)
list:insert(25)

-- 显示跳表
print("跳表结构：")
list:display()

-- 搜索测试
print("搜索测试：")
print("搜索 19: " .. (list:search(19) and "找到" or "未找到"))
print("搜索 15: " .. (list:search(15) and "找到" or "未找到"))

-- 删除测试
print("删除 19...")
list:erase(19)
print("删除后的跳表：")
list:display()

print("=== 测试完成 ===")
