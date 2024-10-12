@echo off

set projectdir=%~dp0..
pushd %projectdir%

if not exist ".\out\" mkdir ".\out\"
odin build . -debug -build-mode:dll -out=./out/game_staging.dll && move .\out\game_staging.dll .\out\game.dll

popd
