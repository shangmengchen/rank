@echo off
echo Cleaning build artifacts...

REM 删除编译生成的文件
Remove-Item *.o -Force -ErrorAction SilentlyContinue
Remove-Item *.a -Force -ErrorAction SilentlyContinue
Remove-Item rank.exe -Force -ErrorAction SilentlyContinue
Remove-Item example.exe -Force -ErrorAction SilentlyContinue

REM 删除CMake生成的文件
Remove-Item CMakeCache.txt -Force -ErrorAction SilentlyContinue
Remove-Item CMakeFiles -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item build -Recurse -Force -ErrorAction SilentlyContinue

echo Clean completed!
