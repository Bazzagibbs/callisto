package callisto_gpu

import "base:runtime"
import "../common"
import "../config"

RHI :: config.RHI

Result :: common.Result
Runner :: common.Runner
Window :: common.Window

Rect_2D :: struct {
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
        window     : ^Window,
        resolution : [2]int, // Leave as 0 to match window
        scaling    : Swapchain_Scaling_Flag,
        vsync      : bool,
}

Swapchain :: struct {
        resolution         : [2]int,
        scaling            : Swapchain_Scaling_Flag,
        vsync              : bool,
        render_target_view : Render_Target_View,
        _impl              : _Swapchain_Impl,
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
        initial_data : rawptr,
        access       : Resource_Access_Flag,
        usage        : Buffer_Usage_Flags,
}

Buffer :: struct {
        size   : int,
        stride : int,
        length : int,
        access : Resource_Access_Flag,
        usage  : Buffer_Usage_Flags,
        _impl  : _Buffer_Impl,
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


Texture_Create_Info :: struct {
        access : Resource_Access_Flag,
        usage  : Texture_Usage_Flags,
}

Texture :: struct {
        // _impl : _Texture_Impl,
}


Render_Target_View :: struct {
        _impl : _Render_Target_View_Impl,
}

Depth_Stencil_View :: struct {
        _impl : _Depth_Stencil_View_Impl,
}

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
        _1,
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


Sampler_Info :: struct {
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

Viewport_Info :: struct {
        rect      : Rect_2D,
        min_depth : f32,
        max_depth : f32,
}



device_create :: proc(create_info: ^Device_Create_Info) -> (d: Device, res: Result) {
        return _device_create(create_info) 
}

device_destroy :: proc (d: ^Device) {
        _device_destroy(d)
}


swapchain_create :: proc(d: ^Device, create_info: ^Swapchain_Create_Info) -> (sc: Swapchain, res: Result) {
        return _swapchain_create(d, create_info)
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

vertex_shader_create :: proc(d: ^Device, create_info: ^Vertex_Shader_Create_Info) -> (shader: Vertex_Shader, res: Result) {
        return _vertex_shader_create(d, create_info)
}

vertex_shader_destroy :: proc(d: ^Device, shader: ^Vertex_Shader) {
        _vertex_shader_destroy(d, shader)
}

fragment_shader_create :: proc(d: ^Device, create_info: ^Fragment_Shader_Create_Info) -> (shader: Fragment_Shader, res: Result) {
        return _fragment_shader_create(d, create_info)
}

fragment_shader_destroy :: proc(d: ^Device, shader: ^Fragment_Shader) {
        _fragment_shader_destroy(d, shader)
}

compute_shader_create :: proc(d: ^Device, create_info: ^Compute_Shader_Create_Info) -> (shader: Compute_Shader, res: Result) {
        return _compute_shader_create(d, create_info)
}

compute_shader_destroy :: proc(d: ^Device, shader: ^Compute_Shader) {
        _compute_shader_destroy(d, shader)
}


buffer_create :: proc(d: ^Device, create_info: ^Buffer_Create_Info) -> (buffer: Buffer, res: Result) {
        return _buffer_create(d, create_info)
}

buffer_destroy :: proc(d: ^Device, buffer: ^Buffer) {
        _buffer_destroy(d, buffer)
}


// command_buffer_create :: proc(d: ^Device, create_info: ^Command_Buffer_Create_Info) -> (cb: Command_Buffer, res: Result) {
//         return _command_buffer_create(d, create_info)
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

cmd_set_scissor_rects :: proc(cb: ^Command_Buffer, scissor_rects: []Rect_2D) {
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

cmd_clear_render_target :: proc(cb: ^Command_Buffer, view: ^Render_Target_View, color: [4]f32) {
        _cmd_clear_render_target(cb, view, color)
}

cmd_draw :: proc(cb: ^Command_Buffer) {
        _cmd_draw(cb)
}
