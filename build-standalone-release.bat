@echo off

set projectdir=%~dp0..
pushd %projectdir%

if not exist ".\out\" mkdir ".\out\"
odin build . -out=./out/game.exe -define:HOT_RELOAD=false

popd
