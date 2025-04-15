@echo off

:: Check for clang
where clang >nul 2>nul
if %errorlevel% neq 0 (
        echo "Clang" not found.
        exit /b 1
)

:: Check for lib
where lib >nul 2>nul
if %errorlevel% neq 0 (
        echo "lib" not found. Please run from a Developer Command Line. 
        exit /b 1
)

clang -c src/ufbx.c -o src/ufbx.obj -target x86_64-pc-windows-msvc -O3
lib /OUT:ufbx.lib src\ufbx.obj
del src\ufbx.obj
