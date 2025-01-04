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
        immediate_command_buffer : Command_Buffer,
        _impl: _Device_Impl,
}

Swapchain_Scaling_Flag :: enum {
        None,
        Stretch,
        Fit,
}

Swapchain_Create_Info :: struct {
        window     : ^Window,
        resolution : Rect_2D, // Leave as 0 to match window
        scaling    : Swapchain_Scaling_Flag,
        vsync      : bool,
}

Swapchain :: struct {
        resolution : Rect_2D,
        scaling    : Swapchain_Scaling_Flag,
        vsync      : bool,
        _impl      : _Swapchain_Impl,
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
