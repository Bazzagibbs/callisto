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

Engine :: common.Engine
Renderer :: common.Renderer
Window :: common.Window
Input :: common.Input

Engine_Description      :: common.Engine_Description
Application_Description :: common.Application_Description
Display_Description     :: common.Display_Description
Renderer_Description    :: common.Renderer_Description
Update_Callback_Proc    :: common.Update_Callback_Proc
Tick_Callback_Proc      :: common.Update_Callback_Proc

