# rank

一个最小可运行的 C++ 项目，包含跳表示例（`zset.hpp`/`zset.cpp`）和测试入口（`test.cpp`）。

## 先决条件

- 已安装编译器：建议 MinGW-w64（包含 `g++` 与 `gdb`），或 MSYS2 下的 `mingw-w64-gcc`。
- VS Code（可选）并安装扩展：C/C++（ms-vscode.cpptools）。

## 方式一：使用 VS Code 任务/调试

已提供 `.vscode/tasks.json` 和 `.vscode/launch.json`：

- 构建：按 Ctrl+Shift+B（默认任务“C++: Build (g++)”），输出到 `build/rank.exe`。
- 运行：在命令面板运行“Tasks: Run Task”选择“C++: Run”，或直接按 F5 启动调试（会先构建）。

注意：首次构建会自动创建 `build/` 目录。

## 方式二：命令行直接编译

在项目根目录执行：

```bash
g++ -std=c++17 -O2 -g test.cpp zset.cpp -o build/rank.exe
./build/rank.exe  # PowerShell 下可用 .\build\rank.exe
```

如果 `build/` 不存在，请先创建：

```bash
mkdir build
```

## 方式三：使用 CMake

项目已提供 `CMakeLists.txt`：

```bash
cmake -S . -B build -G "MinGW Makefiles"
cmake --build build --config Release
./build/rank.exe
```

在 MSVC 工具链下也可用：

```bash
cmake -S . -B build -G "Visual Studio 17 2022"
cmake --build build --config Release
build/Release/rank.exe
```

## 文件说明

- `zset.hpp`：跳表结构与接口声明。
- `zset.cpp`：跳表实现。
- `test.cpp`：简单用例（插入、查询、删除并打印层级）。
- `.vscode/`：VS Code 构建与调试配置。
- `CMakeLists.txt`：CMake 构建脚本。

## 常见问题

- 找不到 `g++`/`gdb`：请将 MinGW-w64 的 `bin` 目录添加到 PATH，或在 VS Code 的 `c_cpp_properties.json` 指定正确的 `compilerPath`。
- 调试无法启动：确认已安装 `gdb`，且 `launch.json` 中 `miDebuggerPath` 可在 PATH 中找到。
