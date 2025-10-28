#include "zset.hpp"

using namespace std;

// 显式实例化模板，为常用类型生成代码
// 这样可以让链接器找到模板的实现
template class SkipList<int>;
template class SkipList<double>;
template class SkipList<long long>;

template struct Node<int>;
template struct Node<double>;
template struct Node<long long>;

// Luna 实现 - 为 int 类型的 SkipList 导出到 Lua
// 注意：Lua绑定需要具体类型，所以我们只为 SkipList<int> 导出
LUA_EXPORT_CLASS_BEGIN(SkipList<int>)
LUA_EXPORT_METHOD(insert)
LUA_EXPORT_METHOD(erase)
LUA_EXPORT_METHOD(search)
LUA_EXPORT_METHOD(display)
LUA_EXPORT_METHOD(getRankByScore)
LUA_EXPORT_METHOD(getSize)
LUA_EXPORT_METHOD(getTopK)
LUA_EXPORT_CLASS_END()

// 如果需要导出 double 版本到 Lua，可以取消下面的注释
/*
LUA_EXPORT_CLASS_BEGIN(SkipList<double>)
LUA_EXPORT_METHOD(insert)
LUA_EXPORT_METHOD(erase)
LUA_EXPORT_METHOD(search)
LUA_EXPORT_METHOD(display)
LUA_EXPORT_METHOD(getRankByScore)
LUA_EXPORT_METHOD(getSize)
LUA_EXPORT_METHOD(getTopK)
LUA_EXPORT_CLASS_END()
*/










