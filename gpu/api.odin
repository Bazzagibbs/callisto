package callisto_gpu

import "base:runtime"
import "../common"
import "../config"

RHI :: config.RHI

Result :: common.Result
Runner :: common.Runner
Window :: common.Window

Rect :: struct {
        x, y          : int,
        width, height : int,
}


Vsync_Modes :: bit_set[Vsync_Mode]
Vsync_Mode :: enum {
        Double_Buffered, // Guaranteed to be supported on every device
        Triple_Buffered,
        Off,
}


Device_Create_Info :: struct {
        runner : ^Runner,
}

Device :: struct {
        immediate_command_buffer : Command_Buffer,
        _impl: _Device_Impl,
}

Command_Buffer :: struct {
        _impl : _Command_Buffer_Impl,
}




device_create :: proc(create_info: ^Device_Create_Info) -> (d: Device, res: Result) {
        return _device_create(create_info) 
}

device_destroy :: proc (d: ^Device) {
        _device_destroy(d)
}

// device_wait_for_idle :: proc (d: ^Device) {
//         _device_wait_for_idle(d)
// }




// Shader_Stages :: bit_set[Shader_Stage]
// Shader_Stage :: enum {
//         // Graphics
//         Vertex,
//         Tessellation_Control,
//         Tessellation_Evaluation,
//         Geometry,
//         Fragment,
//         // Compute
//         Compute,
//         // // Ray tracing // FEATURE(Ray tracing)
//         // Ray_Generation,
//         // Any_Hit,
//         // Closest_Hit,
//         // Miss,
//         // Intersection,
//         // Callable,
//         // // Mesh // FEATURE(Mesh shaders)
//         // Task,
//         // Mesh,
// }

// Texture_Init_Info :: struct {
//         format             : Texture_Format,
//         usage              : Texture_Usage_Flags,
//         queue_usage        : Queue_Flags,
//         memory_access_type : Memory_Access_Type,
//         dimensions         : Texture_Dimensions,
//         extent             : [3]u32,
//         mip_count          : u32,
//         layer_count        : u32,
//         multisample        : Texture_Multisample,
//         // initial_layout     : Texture_Layout,
//         sampler_info       : Sampler_Info,
// }

// Texture_Format :: enum {
//         Undefined,
//         R8G8B8A8_UNORM,
//         R16G16B16A16_SFLOAT,
// }

// Texture_Dimensions :: enum {
//         _1D,
//         _2D,
//         _3D,
//         Cube,
//         _1D_Array,
//         _2D_Array,
//         Cube_Array,
// }

// Texture_Multisample :: enum {
//         None,
//         _2,
//         _4,
//         _8,
//         _16,
//         _32,
//         _64,
// }

// Sampler_Info :: struct {
//         minify_filter         : Filter,
//         magnify_filter        : Filter,
//         mip_filter            : Filter,
//         mip_lod_bias          : f32,
//
//         wrap_mode             : Sampler_Wrap_Mode,
//         border_color          : Sampler_Border_Color,
//         sample_by_pixel_index : bool, // when true, use [0, pixel_width) instead of [0, 1)
//         anisotropy            : Anisotropy,
//
//         min_lod               : f32,
//         max_lod               : f32,
//
// }

// Sampler_Info_DEFAULT :: Sampler_Info {
//         wrap_mode             = .Clamp_To_Border,
//         minify_filter         = .Linear,
//         magnify_filter        = .Linear,
//         mip_filter            = .Linear,
//         mip_lod_bias          = 0,
//         anisotropy            = ._8,
//         min_lod               = 0,
//         max_lod               = 0,
//         border_color          = .Transparent_Black_Float,
//         sample_by_pixel_index = false,
// }


// Filter :: enum {
//         Nearest,
//         Linear,
// }

// Sampler_Wrap_Mode :: enum {
//         Repeat,
//         Mirror,
//         Clamp_To_Edge,
//         Clamp_To_Border,
// }
//
// Sampler_Border_Color :: enum {
//         Transparent_Black_Float,
//         Transparent_Black_Int,
//         Opaque_Black_Float,
//         Opaque_Black_Int,
//         Opaque_White_Float,
//         Opaque_White_Int,
// }

// Anisotropy :: enum {
//         None,
//         _1,
//         _2,
//         _4,
//         _8,
//         _16,
// }

// Compare_Op :: enum {
// 	Never,
// 	Less,
// 	Equal,
// 	Less_Or_Equal,
// 	Greater,
// 	Not_Equal,
// 	Greater_Or_Equal,
// 	Always,
// }

// Cull_Mode :: enum {
//         Never,
//         Counter_Clockwise,
//         Clockwise,
//         Always,
// }

// Shader_Init_Info :: struct {
//         code              : []u8,
//         stage             : Shader_Stage,
//         // vertex_attributes : Vertex_Attribute_Flags,
//         cull_mode         : Cull_Mode,
//         depth_test        : Compare_Op,
//         depth_write       : bool,
//         depth_bias        : f32,
//         // stencil_test   : Compare_Op,
//         // stencil_write  : bool,
// }
//
// Shader_Init_Info_DEFAULT :: Shader_Init_Info {
//         // code              = {},
//         // stage             = {},
//         // vertex_attributes = {},
//         cull_mode            = .Counter_Clockwise,
//         depth_test           = .Greater,
//         depth_write          = true,
//         depth_bias           = 0,
//         // stencil_test      = .Always,
//         // stencil_write     = false,
// }


// Constant_Buffer_Set_Info :: struct {
//         slot             : Constant_Buffer_Slot,
//         buffer_reference : Buffer_Reference,
// }
//
// Constant_Buffer_Slot :: enum {
//         Scene    = 0,
//         Camera   = 1,
//         Pass     = 2,
//         Material = 3,
//         Instance = 4,
// }
//

// Vertex_Attribute_Flags :: bit_set[Vertex_Attribute_Flag]
// Vertex_Attribute_Flag :: enum {
//         Position,
//         Normal,
//         Tangent,
//         Color_0,
//         Color_1,
//         Tex_Coord_0,
//         Tex_Coord_1,
//         Tex_Coord_2,
//         Tex_Coord_3,
//         Joints_0,
//         Joints_1,
//         Weights_0,
//         Weights_1,
// }

// Vertex_Attribute_Stride := [Vertex_Attribute_Flag]int {
//         .Position    = size_of([3]f32),
//         .Normal      = size_of([3]f16),
//         .Tangent     = size_of([4]f16),
//         .Color_0     = size_of([4]u8),
//         .Color_1     = size_of([4]u8),
//         .Tex_Coord_0 = size_of([2]f16),
//         .Tex_Coord_1 = size_of([2]f16),
//         .Tex_Coord_2 = size_of([2]f16),
//         .Tex_Coord_3 = size_of([2]f16),
//         .Joints_0    = size_of([4]u16),
//         .Joints_1    = size_of([4]u16),
//         .Weights_0   = size_of([4]f16),
//         .Weights_1   = size_of([4]f16),
// }

// Vertex_Buffer_Bind_Info :: struct {
//         attribute : Vertex_Attribute_Flag,
//         buffer    : Buffer_Reference,
// }

// Buffer_Init_Info :: struct {
//         size               : int,
//         usage              : Buffer_Usage_Flags,
//         queue_usage        : Queue_Flags,
//         memory_access_type : Memory_Access_Type,
// }
//
//
// Buffer_Usage_Flags :: bit_set[Buffer_Usage_Flag]
// Buffer_Usage_Flag :: enum {
//         Transfer_Src,
//         Transfer_Dst,
//         Storage,
//         Index,
//         Vertex,
//         Addressable,
// }

// Index_Type :: enum {
//         U16 = 0,
//         U32 = 1,
// }

