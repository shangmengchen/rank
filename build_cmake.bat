@echo off
echo ========================================
echo Building Rank Project with CMake
echo ========================================

REM 清理之前的构建文件
echo Cleaning previous build files...
if exist build rmdir /s /q build
mkdir build

echo.
echo [1/3] Configuring with CMake...
cd build
cmake .. -G "MinGW Makefiles"
if errorlevel 1 (
    echo ERROR: CMake configuration failed
    cd ..
    exit /b 1
)

echo.
echo [2/3] Building with CMake...
cmake --build . --config Release
if errorlevel 1 (
    echo ERROR: CMake build failed
    cd ..
    exit /b 1
)

cd ..

echo.
echo ========================================
echo Build completed successfully!
echo Output files:
echo   - build/bin/rank.exe (executable)
echo   - build/lib/librank_lib.a (static library)
echo ========================================
echo.
echo To run the program: .\build\bin\rank.exe
echo To use the library: link with build/lib/librank_lib.a
echo.
