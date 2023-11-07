package callisto

import cc "common"
import cg "graphics"
import "input"
import "window"

Engine_Context :: struct {
    window:     window.Window_Context,
    input:      input.Input_Context,
    graphics:   cg.Graphics_Context,
}

Handle :: distinct rawptr

uvec2       :: cc.uvec2
uvec3       :: cc.uvec3
uvec4       :: cc.uvec4

ivec2       :: cc.ivec2
ivec3       :: cc.ivec3
ivec4       :: cc.ivec4

vec2        :: cc.vec2
vec3        :: cc.vec3
vec4        :: cc.vec4

mat2        :: cc.mat2
mat3        :: cc.mat3
mat4        :: cc.mat4

MAT2_IDENTITY :: cc.MAT2_IDENTITY
MAT3_IDENTITY :: cc.MAT3_IDENTITY
MAT4_IDENTITY :: cc.MAT4_IDENTITY

color32     :: cc.color32

quat        :: cc.quat

Vertex_Buffer   :: cc.Vertex_Buffer
Index_Buffer    :: cc.Index_Buffer

Axis_Algined_Bounding_Box :: cc.Axis_Aligned_Bounding_Box

Transform       :: cc.Transform
