@echo off
echo ========================================
echo Building Rank Project with Luna Support
echo ========================================

REM 清理之前的构建文件
echo Cleaning previous build files...
if exist build rmdir /s /q build
mkdir build
cd build

REM 设置编译参数
set CXXFLAGS=-std=c++17 -O2 -DLUA_USE_WINDOWS -Wall
set CFLAGS=-std=c99 -O2 -DLUA_USE_WINDOWS
set INCLUDES=-I.. -I../third_party/luna -I../lua-dev -I../lua-static

REM Luna 源文件
set LUNA_SOURCES=../third_party/luna/luna.cpp ../third_party/luna/lua_archiver.cpp ../third_party/luna/var_int.cpp ../third_party/luna/lz4.c

REM Lua 源文件（排除主程序）
set LUA_SOURCES=../lua-static/lapi.c ../lua-static/lauxlib.c ../lua-static/lbaselib.c ../lua-static/lcode.c ../lua-static/lcorolib.c ../lua-static/lctype.c ../lua-static/ldblib.c ../lua-static/ldebug.c ../lua-static/ldo.c ../lua-static/ldump.c ../lua-static/lfunc.c ../lua-static/lgc.c ../lua-static/linit.c ../lua-static/liolib.c ../lua-static/llex.c ../lua-static/lmathlib.c ../lua-static/lmem.c ../lua-static/loadlib.c ../lua-static/lobject.c ../lua-static/lopcodes.c ../lua-static/loslib.c ../lua-static/lparser.c ../lua-static/lstate.c ../lua-static/lstring.c ../lua-static/lstrlib.c ../lua-static/ltable.c ../lua-static/ltablib.c ../lua-static/ltm.c ../lua-static/lundump.c ../lua-static/lutf8lib.c ../lua-static/lvm.c ../lua-static/lzio.c

REM 项目源文件
set PROJECT_SOURCES=../zset/test.cpp ../zset/zset.cpp

echo.
echo [1/5] Compiling Luna library sources...
for %%f in (%LUNA_SOURCES%) do (
    echo   Compiling %%f...
    g++ %CXXFLAGS% %INCLUDES% -c %%f
    if errorlevel 1 (
        echo ERROR: Failed to compile %%f
        exit /b 1
    )
)

echo.
echo [2/5] Compiling Lua library sources...
for %%f in (%LUA_SOURCES%) do (
    echo   Compiling %%f...
    gcc %CFLAGS% %INCLUDES% -c %%f
    if errorlevel 1 (
        echo ERROR: Failed to compile %%f
        exit /b 1
    )
)

echo.
echo [3/5] Compiling project sources...
for %%f in (%PROJECT_SOURCES%) do (
    echo   Compiling %%f...
    g++ %CXXFLAGS% %INCLUDES% -c %%f
    if errorlevel 1 (
        echo ERROR: Failed to compile %%f
        exit /b 1
    )
)

echo.
echo [4/5] Creating static library package...
ar rcs librank.a *.o
if errorlevel 1 (
    echo ERROR: Failed to create static library
    exit /b 1
)

echo.
echo [5/5] Linking executable...
g++ -o rank.exe *.o -lws2_32 -Wl,--subsystem,console
if errorlevel 1 (
    echo ERROR: Failed to link executable
    cd ..
    exit /b 1
)

cd ..

echo.
echo ========================================
echo Build completed successfully!
echo Output files:
echo   - build/rank.exe (executable)
echo   - build/librank.a (static library package)
echo ========================================
echo.
echo To run the program: .\build\rank.exe
echo To use the library: link with build/librank.a
echo.