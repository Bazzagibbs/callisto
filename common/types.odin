package callisto_common

import "core:math/linalg"
import "core:time"



// Aliased types
Handle      :: distinct rawptr

uvec2     :: [2]u32
uvec3     :: [3]u32
uvec4     :: [4]u32
ivec2     :: [2]i32
ivec3     :: [3]i32
ivec4     :: [4]i32

vec2        :: [2]f32
vec3        :: [3]f32
vec4        :: [4]f32

mat2        :: matrix[2, 2]f32
mat3        :: matrix[3, 3]f32
mat4        :: matrix[4, 4]f32

MAT2_IDENTITY :: linalg.MATRIX2F32_IDENTITY
MAT3_IDENTITY :: linalg.MATRIX3F32_IDENTITY
MAT4_IDENTITY :: linalg.MATRIX4F32_IDENTITY

color32     :: [4]u8
quat        :: linalg.Quaternionf32

Result :: enum {
    Ok,
    Unknown,
    Out_Of_Memory,
    Initialization_Failed,
    Device_Lost,
    Feature_Not_Present,
    Format_Not_Supported,
    Device_Not_Supported,
    Invalid_Handle,
    Invalid_Asset,
    Invalid_Description,
}

Window :: distinct Handle
Renderer :: distinct Handle

Buffer          :: distinct Handle
Texture         :: distinct Handle
Mesh            :: distinct Handle
Shader          :: distinct Handle
Material        :: distinct Handle
Model           :: distinct Handle 
Render_Pass     :: distinct Handle
Render_Target   :: distinct Handle

Gpu_Image       :: distinct Handle
Gpu_Buffer      :: distinct Handle

// Structs
// ///////

Engine :: struct {
    window      : Window,
    renderer    : Renderer,
    input       : ^Input,
    update_proc : Update_Callback_Proc,
    tick_proc   : Tick_Callback_Proc,
    time        : Frame_Time,

    user_data   : rawptr,
}


Version :: struct {
    major : u32,
    minor : u32,
    patch : u32,
}


Frame_Time :: struct {
    stopwatch_epoch  : time.Stopwatch, // Since callisto.run()
    stopwatch_delta  : time.Stopwatch, // Reset every frame
    scale            : f32,

    delta            : f32,
    delta_unscaled   : f32,
    // delta_tick       : f32,
    maximum_delta    : f32,
}


Axis_Aligned_Bounding_Box :: struct {
    center     : vec3,
    extent     : vec3, // half of width/breadth/height
}


Transform :: struct {
    translation     : vec3,
    rotation        : quat,
    scale           : vec3,
}


// ///////////////////////////////////////////////////////////
Render_Pass_Uniforms :: struct {
    view:       mat4,
    proj:       mat4,
    viewproj:   mat4,
}

Instance_Uniforms :: struct {
    model:      mat4,
}

Update_Callback_Proc :: #type proc(ctx: ^Engine)
Tick_Callback_Proc   :: #type proc(ctx: ^Engine)

// ///////////////////////////////////////////////////////////
Gpu_Image_Format :: enum {
}

Gpu_Image_Usage_Flags :: bit_set[Gpu_Image_Usage_Flag]
Gpu_Image_Usage_Flag  :: enum {
}

