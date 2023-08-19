@echo off
for /R %%f in (resources\shaders_src\*) do (
    glslc %%f -o resources/shaders/%%~nf%%~xf.spv && echo Compiled %%~nf%%~xf.spv
)