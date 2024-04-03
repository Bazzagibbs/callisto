package callisto

import "common"
import cg "graphics"
import "input"
import "window"


Result                    :: common.Result
Frame_Time                :: common.Frame_Time

Handle                    :: common.Handle

uvec2                     :: common.uvec2
uvec3                     :: common.uvec3
uvec4                     :: common.uvec4

ivec2                     :: common.ivec2
ivec3                     :: common.ivec3
ivec4                     :: common.ivec4

vec2                      :: common.vec2
vec3                      :: common.vec3
vec4                      :: common.vec4

mat2                      :: common.mat2
mat3                      :: common.mat3
mat4                      :: common.mat4

MAT2_IDENTITY             :: common.MAT2_IDENTITY
MAT3_IDENTITY             :: common.MAT3_IDENTITY
MAT4_IDENTITY             :: common.MAT4_IDENTITY

color32                   :: common.color32

quat                      :: common.quat


Axis_Aligned_Bounding_Box :: common.Axis_Aligned_Bounding_Box

Transform                 :: common.Transform

Engine :: struct {
    window      : window.Window,
    renderer    : cg.Renderer,
    input       : ^input.Input,
    update_proc : Update_Callback_Proc,
    tick_proc   : Tick_Callback_Proc,
    time        : Frame_Time,

    user_data   : rawptr,
}


Engine_Description :: struct {
    display_description  : ^Display_Description,
    renderer_description : ^Renderer_Description,
    update_proc          : Update_Callback_Proc,
    tick_proc            : Tick_Callback_Proc,

    user_data            : rawptr,
}

Display_Description  :: common.Display_Description
Renderer_Description :: common.Renderer_Description
Update_Callback_Proc :: #type proc(ctx: ^Engine)
Tick_Callback_Proc   :: #type proc(ctx: ^Engine)

