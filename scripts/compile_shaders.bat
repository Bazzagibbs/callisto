@echo off
for /R %%f in (assets\shaders_src\*) do (
    glslc %%f -o assets/shaders/%%~nf%%~xf.spv && echo Compiled %%~nf%%~xf.spv
)