package callisto_gpu

import "base:runtime"
import "core:log"
import "../common"
import "../config"

RHI_BACKEND         :: config.RHI_BACKEND
RHI_TRACK_RESOURCES :: config.RHI_TRACK_RESOURCES
RHI_VALIDATION      :: config.RHI_VALIDATION

Result :: common.Result
Runner :: common.Runner
Window :: common.Window

// TODO: add location := #caller_location to all create procs

Rect2D :: struct {
        x, y          : int,
        width, height : int,
}


Device_Create_Info :: struct {
        runner : ^Runner,
}

Device :: struct {
        immediate_command_buffer : Command_Buffer, // This probably shouldn't be exposed - create a default CB instead?
        _impl: _Device_Impl,
}

Swapchain_Scaling_Flag :: enum {
        None,
        Stretch,
        Fit,
}

Swapchain_Create_Info :: struct {
        window      : ^Window,
        resolution  : [2]int, // Leave as 0 to match window
        scaling     : Swapchain_Scaling_Flag,
        vsync       : bool,
}

Swapchain :: struct {
        resolution         : [2]int,
        scaling            : Swapchain_Scaling_Flag,
        vsync              : bool,
        render_target_view : Render_Target_View,
        _impl              : _Swapchain_Impl,
}


Shader_Stage_Flags :: bit_set[Shader_Stage_Flag]
Shader_Stage_Flag :: enum {
        Vertex,
        Fragment,
        Compute,
        // FEATURE(Geometry shaders)
}

Vertex_Shader_Create_Info :: struct {
        code              : []u8,
        vertex_attributes : Vertex_Attribute_Flags,
}

Vertex_Shader :: struct {
        vertex_attributes : Vertex_Attribute_Flags,
        _impl : _Vertex_Shader_Impl,
}


Fragment_Shader_Create_Info :: struct {
        code              : []u8,
}

Fragment_Shader :: struct {
        _impl : _Fragment_Shader_Impl,
}


Compute_Shader_Create_Info :: struct {
        code              : []u8,
}

Compute_Shader :: struct {
        _impl : _Compute_Shader_Impl,
}



Command_Buffer :: struct {
        _impl : _Command_Buffer_Impl,
}


Vertex_Attribute_Flags :: bit_set[Vertex_Attribute_Flag]
Vertex_Attribute_Flag :: enum {
        Position,
        Position2D,
        Color,
        Tex_Coord_0,
        Tex_Coord_1,
        Normal,
        Tangent,
        Joints_0,
        Joints_1,
        Weights_0,
        Weights_1,
}


Resource_Access_Flag :: enum {
        Device_General,
        Device_Immutable,
        Host_To_Device,
        Device_To_Host,
}

Buffer_Usage_Flags :: bit_set[Buffer_Usage_Flag]
Buffer_Usage_Flag :: enum {
        Vertex,
        Index,
        Constant,
        Unordered_Access,
        Shader_Resource,
        // Stream_Output, // FEATURE(Geometry shader)
}

Buffer_Create_Info :: struct {
        size         : int,
        stride       : int,
        access       : Resource_Access_Flag,
        usage        : Buffer_Usage_Flags,
        initial_data : rawptr,
}

Buffer :: struct {
        size   : int,
        stride : int,
        length : int,
        access : Resource_Access_Flag,
        usage  : Buffer_Usage_Flags,
        _impl  : _Buffer_Impl,
}


Texture_Format_Flag :: enum u32 {
        Unknown = 0,

        // 128-bit
        R32G32B32A32_UNTYPED,
        R32G32B32A32_FLOAT,
        R32G32B32A32_UINT,
        R32G32B32A32_SINT,
        
        // 96-bit
        R32G32B32_UNTYPED,
        R32G32B32_FLOAT,
        R32G32B32_UINT,
        R32G32B32_SINT,

        // 64-bit
        R16G16B16A16_UNTYPED,
        R16G16B16A16_FLOAT,
        R16G16B16A16_UNORM,
        R16G16B16A16_UINT,
        R16G16B16A16_SNORM,
        R16G16B16A16_SINT,

        R32G32_UNTYPED,
        R32G32_FLOAT,
        R32G32_UINT,
        R32G32_SINT,

        // 64-bit depth/stencil
        D32_FLOAT_S8X24_UINT, // X24 is unused
        
        // 32-bit
        R8G8B8A8_UNTYPED,
        R8G8B8A8_UNORM,
        R8G8B8A8_UINT,
        R8G8B8A8_SNORM,
        R8G8B8A8_SINT,
        R8G8B8A8_UNORM_SRGB,

        R10G10B10A2_UNTYPED,
        R10G10B10A2_UNORM,
        R10G10B10A2_UINT,
        R11G11B10_FLOAT,

        R16G16_UNTYPED,
        R16G16_FLOAT,
        R16G16_UNORM,
        R16G16_UINT,
        R16G16_SNORM,
        R16G16_SINT,

        R32_UNTYPED,
        R32_FLOAT,
        R32_UINT,
        R32_SINT,
        
        B8G8R8A8_UNTYPED,
        B8G8R8A8_UNORM,
        B8G8R8A8_UNORM_SRGB,

        // 32-bit depth/stencil
        D32_FLOAT,
        D24_UNORM_S8_UINT,

        // 16-bit
        R8G8_UNTYPED,
        R8G8_UNORM,
        R8G8_UINT,
        R8G8_SNORM,
        R8G8_SINT,

        R16_UNTYPED,
        R16_FLOAT,
        R16_UNORM,
        R16_UINT,
        R16_SNORM,
        R16_SINT,
       
        B4G4R4A4_UNORM,
        B5G5R5A1_UNORM,
        B5G6R5_UNORM,

        // 16-bit depth/stencil
        D16_UNORM,

        // 8-bit
        R8_UNTYPED,
        R8_UNORM,
        R8_UINT,
        R8_SNORM,
        R8_SINT,

        A8_UNORM,

        // 1-bit
        R1_UNORM,

        // Block compressed
        BC1_UNTYPED,
        BC1_UNORM,
        BC1_UNORM_SRGB,
        BC2_UNTYPED,
        BC2_UNORM,
        BC2_UNORM_SRGB,
        BC3_UNTYPED,
        BC3_UNORM,
        BC3_UNORM_SRGB,
        BC4_UNTYPED,
        BC4_UNORM,
        BC4_SNORM,
        BC5_UNTYPED,
        BC5_UNORM,
        BC5_SNORM,
        BC6H_UNTYPED,
        BC6H_UFLOAT,
        BC6H_SFLOAT,
        BC7_UNTYPED,
        BC7_UNORM,
        BC7_UNORM_SRGB,
}


Texture_Usage_Flags :: bit_set[Texture_Usage_Flag]
Texture_Usage_Flag :: enum {
        Render_Target,
        Depth_Stencil_Target,
        Unordered_Access,
        Shader_Resource,
        // Decoder, // FEATURE(Video)
        // Encoder,
}

Multisample_Flag :: enum {
        None,
        _2,
        _4,
        _8,
        _16,
}

Texture2D_Upload_Info :: struct {
        data     : []u8,
        row_size : int,
}

Texture2D_Create_Info :: struct {
        resolution            : [2]int,
        mip_levels            : int, // 0 creates a full mip chain
        multisample           : Multisample_Flag,
        format                : Texture_Format_Flag,
        access                : Resource_Access_Flag,
        usage                 : Texture_Usage_Flags,
        allow_generate_mips   : bool,
        initial_data          : []Texture2D_Upload_Info, // requires a buffer per mip level
}

Texture2D :: struct {
        resolution   : [2]int,
        mip_levels   : int,
        array_layers : int,
        format       : Texture_Format_Flag,
        _impl        : _Texture2D_Impl,
}


Render_Target_View :: struct {
        _impl : _Render_Target_View_Impl,
}

Depth_Stencil_View :: struct {
        _impl : _Depth_Stencil_View_Impl,
}

Texture2D_View_Create_Info :: struct {
        format            : Texture_Format_Flag,
        multisample       : bool, // Cannot be used with cubemap
        array             : bool,
        cubemap           : bool,
        mip_lowest_level  : int,
        mip_levels        : int,
        array_start_layer : int, // When array == true and cubemap == true, the index of the first cube.
        array_layers      : int, // When array == true and cubemap == true, the number of cubes.
}


Texture_View :: struct {
        _impl : _Texture_View_Impl,
}

// Buffer_View :: struct {}

Compare_Op :: enum {
        Never,
        Less,
        Equal,
        Less_Or_Equal,
        Greater,
        Not_Equal,
        Greater_Or_Equal,
        Always,
}

Sampler_Filter_Flag :: enum {
        Point,
        Linear,
}

Sampler_Anisotropy_Flag :: enum {
        None,
        _2,
        _4,
        _8,
        _16,
}

Sampler_Address_Flag :: enum {
        Wrap,
        Mirror,
        Clamp,
        Border,
        Mirror_Negative,
}

Sampler_Border_Color_Flag :: enum {
        Black_Transparent,
        Black_Opaque,
        White_Transparent,
        White_Opaque,
}


min_lod_UNCLAMPED :: min(f32)
max_lod_UNCLAMPED :: max(f32)

Sampler_Create_Info :: struct {
        min_filter     : Sampler_Filter_Flag,
        mag_filter     : Sampler_Filter_Flag,
        mip_filter     : Sampler_Filter_Flag,
        max_anisotropy : Sampler_Anisotropy_Flag,
        min_lod        : f32,
        max_lod        : f32,
        lod_bias       : f32,
        address_mode   : Sampler_Address_Flag,
        border_color   : Sampler_Border_Color_Flag,
}


Sampler :: struct {
        _impl : _Sampler_Impl,
}

Viewport_Info :: struct {
        rect      : Rect2D,
        min_depth : f32,
        max_depth : f32,
}



device_create :: proc(create_info: ^Device_Create_Info, location := #caller_location) -> (d: Device, res: Result) {
        return _device_create(create_info, location) 
}

device_destroy :: proc (d: ^Device) {
        _device_destroy(d)
}


swapchain_create :: proc(d: ^Device, create_info: ^Swapchain_Create_Info, location := #caller_location) -> (sc: Swapchain, res: Result) {
        return _swapchain_create(d, create_info, location)
}

swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        _swapchain_destroy(d, sc)
}


// Pass `resolution = {0, 0}` to use the full window resolution
swapchain_resize :: proc(d: ^Device, sc: ^Swapchain, resolution: [2]int = {0, 0}) -> (res: Result) {
        return _swapchain_resize(d, sc, resolution)
}

swapchain_present :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        return _swapchain_present(d, sc)
}

vertex_shader_create :: proc(d: ^Device, create_info: ^Vertex_Shader_Create_Info, location := #caller_location) -> (shader: Vertex_Shader, res: Result) {
        return _vertex_shader_create(d, create_info, location)
}

vertex_shader_destroy :: proc(d: ^Device, shader: ^Vertex_Shader) {
        _vertex_shader_destroy(d, shader)
}

fragment_shader_create :: proc(d: ^Device, create_info: ^Fragment_Shader_Create_Info, location := #caller_location) -> (shader: Fragment_Shader, res: Result) {
        return _fragment_shader_create(d, create_info, location)
}

fragment_shader_destroy :: proc(d: ^Device, shader: ^Fragment_Shader) {
        _fragment_shader_destroy(d, shader)
}

compute_shader_create :: proc(d: ^Device, create_info: ^Compute_Shader_Create_Info, location := #caller_location) -> (shader: Compute_Shader, res: Result) {
        return _compute_shader_create(d, create_info, location)
}

compute_shader_destroy :: proc(d: ^Device, shader: ^Compute_Shader) {
        _compute_shader_destroy(d, shader)
}


buffer_create :: proc(d: ^Device, create_info: ^Buffer_Create_Info, location := #caller_location) -> (buffer: Buffer, res: Result) {
        return _buffer_create(d, create_info, location)
}

buffer_destroy :: proc(d: ^Device, buffer: ^Buffer) {
        _buffer_destroy(d, buffer)
}

// Identical samplers are cached and refcounted internally.
sampler_create :: proc(d: ^Device, create_info: ^Sampler_Create_Info, location := #caller_location) -> (sampler: Sampler, res: Result) {
        return _sampler_create(d, create_info, location)
}

sampler_destroy :: proc(d: ^Device, sampler: ^Sampler) {
        _sampler_destroy(d, sampler)
}


// texture1d_create :: proc(d: ^Device, create_info: ^Texture1D_Create_Info, location := #caller_location) -> (tex: Texture1D, res: Result) {
//         return _texture1d_create(d, create_info, location)
// }
//
// texture1d_destroy :: proc(d: ^Device, tex: ^Texture1D) {
//         _texture1d_destroy(d, tex)
// }

texture2d_create :: proc(d: ^Device, create_info: ^Texture2D_Create_Info, location := #caller_location) -> (tex: Texture2D, res: Result) {
        _validate_texture2d_create(create_info, location) or_return

        return _texture2d_create(d, create_info, location)
}

texture2d_destroy :: proc(d: ^Device, tex: ^Texture2D) {
        _texture2d_destroy(d, tex)
}



// texture3d_create :: proc(d: ^Device, create_info: ^Texture3D_Create_Info, location := #caller_location) -> (tex: Texture3D, res: Result) {
//         return _texture3d_create(d, create_info, location)
// }
//
// texture3d_destroy :: proc(d: ^Device, tex: ^Texture3D) {
//         _texture3d_destroy(d, tex)
// }

// Pass `create_info = nil` to create a full texture view
texture_view_create :: proc {
        // texture1d_view_create,
        texture2d_view_create,
        // texture3d_view_create,
}

// texture1d_view_create :: proc(d: ^Device, tex: ^Texture1D, create_info: ^Texture1D_View_Create_Info = nil, location := #caller_location = nil) -> (view: Texture_View, res: Result) {
//         return _texture1d_view_create(d, tex, create_info, location)
// }

// Pass `create_info = nil` to create a full texture view
texture2d_view_create :: proc(d: ^Device, tex: ^Texture2D, create_info: ^Texture2D_View_Create_Info = nil, location := #caller_location) -> (view: Texture_View, res: Result) {
        return _texture2d_view_create(d, tex, create_info, location)
}

// texture3d_view_create :: proc(d: ^Device, tex: ^Texture3D, create_info: ^Texture3D_View_Create_Info = nil, location := #caller_location) -> (view: Texture_View, res: Result) {
//         return _texture3d_view_create(d, tex, create_info, location)
// }


texture_view_destroy :: proc(d: ^Device, view: ^Texture_View) {
        _texture_view_destroy(d, view)
}

// command_buffer_create :: proc(d: ^Device, create_info: ^Command_Buffer_Create_Info, location := #caller_location) -> (cb: Command_Buffer, res: Result) {
//         return _command_buffer_create(d, create_info, location)
// }
//
// command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
//         _command_buffer_destroy(d, cb)
// }

command_buffer_begin :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        return _command_buffer_begin(d, cb)
}

command_buffer_end :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        return _command_buffer_end(d, cb)
}

command_buffer_submit :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        return _command_buffer_submit(d, cb)
}


cmd_set_viewports :: proc(cb: ^Command_Buffer, viewports: []Viewport_Info) {
        _cmd_set_viewports(cb, viewports)
}

cmd_set_scissor_rects :: proc(cb: ^Command_Buffer, scissor_rects: []Rect2D) {
        _cmd_set_scissor_rects(cb, scissor_rects)
}

cmd_set_render_targets :: proc(cb: ^Command_Buffer, render_target_views : []^Render_Target_View, depth_stencil_view : ^Depth_Stencil_View) {
        _cmd_set_render_targets(cb, render_target_views, depth_stencil_view)
}

cmd_set_vertex_shader :: proc(cb: ^Command_Buffer, shader: ^Vertex_Shader) {
        _cmd_set_vertex_shader(cb, shader)
}

cmd_set_fragment_shader :: proc(cb: ^Command_Buffer, shader: ^Fragment_Shader) {
        _cmd_set_fragment_shader(cb, shader)
}

cmd_set_compute_shader :: proc(cb: ^Command_Buffer, shader: ^Compute_Shader) {
        _cmd_set_compute_shader(cb, shader)
}

cmd_set_vertex_buffers :: proc(cb: ^Command_Buffer, buffers: []^Buffer) {
        _cmd_set_vertex_buffers(cb, buffers)
}

cmd_set_index_buffer :: proc(cb: ^Command_Buffer, buffer: ^Buffer) {
        _cmd_set_index_buffer(cb, buffer)
}

// // Note: buffer_views and texture_views share shader resource slots per stage.
// cmd_set_buffer_views :: proc(cb: ^Command_Buffer, stages: Shader_Stage_Flags, start_slot: int, views: []^Buffer_View) {
//         _cmd_set_buffer_views(cb, stages, start_slot, views)
// }

// Note: buffer_views and texture_views share shader resource slots per stage.
cmd_set_texture_views :: proc(cb: ^Command_Buffer, stages: Shader_Stage_Flags, start_slot: int, views: []^Texture_View) {
        _cmd_set_texture_views(cb, stages, start_slot, views)
}

cmd_set_samplers :: proc(cb: ^Command_Buffer, stages: Shader_Stage_Flags, start_slot: int, samplers: []^Sampler) {
        _cmd_set_samplers(cb, stages, start_slot, samplers)
}

cmd_update_constant_buffer :: proc(cb: ^Command_Buffer, buffer: ^Buffer, data: rawptr) {
        _cmd_update_constant_buffer(cb, buffer, data)
}

cmd_set_constant_buffers :: proc(cb: ^Command_Buffer, stages: Shader_Stage_Flags, start_slot: int, buffers: []^Buffer) {
        _cmd_set_constant_buffers(cb, stages, start_slot, buffers)
}


cmd_clear_render_target :: proc(cb: ^Command_Buffer, view: ^Render_Target_View, color: [4]f32) {
        _cmd_clear_render_target(cb, view, color)
}

cmd_draw :: proc(cb: ^Command_Buffer) {
        _cmd_draw(cb)
}

