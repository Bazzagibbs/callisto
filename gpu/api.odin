package callisto_gpu

import "../common"

Result :: common.Result
Runner :: common.Runner
Window :: common.Window


Device_Init_Info :: struct {
        runner            : ^Runner, // required
        required_features : Required_Device_Features,
}

Required_Device_Features :: bit_set[Required_Device_Feature]
Required_Device_Feature :: enum {}

Swapchain_Init_Info :: struct {
        window                        : Window,
        vsync                         : Vsync_Mode,
        force_draw_occluded_fragments : bool,
        // hdr    : bool,
}

Vsync_Modes :: bit_set[Vsync_Mode]
Vsync_Mode :: enum {
        Double_Buffered, // Guaranteed to be supported on every device
        Triple_Buffered,
        No_Sync,
}

Command_Buffer_Init_Info :: struct {
        type: Command_Buffer_Type,
}

Command_Buffer_Type :: enum {
        Graphics,
        Compute_Sync,
        Compute_Async,
}

Buffer_Init_Info :: struct {}

Buffer_Transfer_Info :: struct {}

Texture_Init_Info :: struct {
        format      : Texture_Format,
        usage       : Texture_Usage_Flags,
        dimensions  : Texture_View_Dimensions,
        extent      : [3]u32,
        mip_count   : u32,
        layer_count : u32,
}

Texture_Format :: enum {
        R8G8B8A8_UNORM_SRGB,
}

Texture_Usage_Flags :: bit_set[Texture_Usage_Flag]
Texture_Usage_Flag :: enum {
        Sampled,
        Storage,
        Color_Target,
        Depth_Stencil_Target,
        Transient,
}

Texture_View_Init_Info :: struct {
        texture     : ^Texture,
        format : Texture_Format,
        dimensions  : Texture_View_Dimensions,
        mip_base    : u32,
        mip_count   : u32,
        layer_base  : u32,
        layer_count : u32,
}

Texture_View_Dimensions :: enum {
        _1D,
        _2D,
        _3D,
        Cube,
        _1D_Array,
        _2D_Array,
        Cube_Array,
}

Sampler_Init_Info :: struct {}

Shader_Init_Info :: struct {}


Color_Target_Info :: struct {
        texture              : ^Texture,
        texture_view         : ^Texture_View,  // optional
        resolve_texture      : ^Texture,
        resolve_texture_view : ^Texture_View,  // optional
        clear_value          : [4]f32,
        load_op              : Load_Op,
        store_op             : Store_Op,
}

Depth_Stencil_Target_Info :: struct {
        texture              : ^Texture,
        texture_view         : ^Texture_View,  // optional
        resolve_texture      : ^Texture,
        resolve_texture_view : ^Texture_View,  // optional
        clear_value          : struct {depth: f32, stencil: u32},
        load_op              : Load_Op,
        store_op             : Store_Op,
}


Load_Op :: enum {
        Load,
        Clear,
        Dont_Care
}

Store_Op :: enum {
        Store,
        Dont_Care,
        Resolve,
        Resolve_And_Store,
}

Resolve_Mode_Flags :: bit_set[Resolve_Mode_Flag]
Resolve_Mode_Flag :: enum {
        Sample_0,
        Average,
        Min,
        Max,
}


// Implement this interface for all RHI backends
/*

device_init              :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result)
device_destroy           :: proc(d: ^Device)

swapchain_init
swapchain_destroy
swapchain_resize

swapchain_set_vsync
swapchain_get_vsync
swapchain_get_available_vsync

buffer_init              :: proc(d: ^Device, b: ^Buffer, init_info: ^Buffer_Init_Info) -> (res: Result)
buffer_destroy           :: proc(d: ^Device, b: ^Buffer)
buffer_transfer          :: proc(d: ^Device, transfer_info: ^Buffer_Transfer_Info) -> (res: Result)

texture_init             :: proc(d: ^Device, t: ^Texture, init_info: ^Texture_Init_Info) -> (res: Result)
texture_destroy          :: proc(d: ^Device, t: ^Texture)

sampler_init             :: proc(d: ^Device, s: ^Sampler, init_info: ^Sampler_Init_Info) -> (res: Result)
sampler_destroy          :: proc(d: ^Device, s: ^Sampler)

shader_init              :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> (res: Result)
shader_destroy           :: proc(d: ^Device, s: ^Shader)

command_buffer_init      :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info) -> (res: Result)
command_buffer_destroy   :: proc(d: ^Device, cb: ^Command_Buffer)
command_buffer_submit    :: proc(d: ^Device, cb: ^Command_Buffer)

cmd_clear                :: proc(cb: ^Command_Buffer, color: [4]f32)

cmd_bind_vertex_shader   :: proc(cb: ^Command_Buffer, vs: ^Shader)
cmd_bind_fragment_shader :: proc(cb: ^Command_Buffer, fs: ^Shader)

cmd_draw                 :: proc(cb: ^Command_Buffer, verts: ^Buffer, indices: ^Buffer)
present                  :: proc(cb: ^Command_Buffer, sc: ^Swapchain)
*/
