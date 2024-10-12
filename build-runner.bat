@echo off

set projectdir=%~dp0..
pushd %projectdir%

if not exist ".\out\" mkdir ".\out\"
odin build ./callisto/runner -debug -out=./out/runner.exe -define:HOT_RELOAD=true

popd
