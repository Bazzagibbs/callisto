@echo off
for /R %%f in (callisto\resources\shaders_src\*) do (
    glslc %%f -o callisto/resources/shaders/%%~nf%%~xf.spv && echo Compiled %%~nf%%~xf.spv
)
