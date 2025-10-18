@echo off
echo ========================================
echo 启动 Rank 程序
echo ========================================
echo.

REM 检查可执行文件是否存在
if not exist "build\bin\rank.exe" (
    echo 错误: 找不到 build\bin\rank.exe
    echo 请先运行 build_cmake.bat 构建项目
    echo.
    pause
    exit /b 1
)

REM 检查 Lua 脚本是否存在
if not exist "rank.lua" (
    echo 错误: 找不到 rank.lua 文件
    echo 请确保 rank.lua 文件在项目根目录
    echo.
    pause
    exit /b 1
)

echo 正在启动程序...
echo.

REM 运行程序
.\build\bin\rank.exe

echo.
echo ========================================
echo 程序执行完毕
echo ========================================
echo.
echo 按任意键退出...
pause > nul
