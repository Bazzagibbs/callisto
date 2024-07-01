package callisto_graphics
import "../common"
import "../asset"

Result                        :: common.Result
Renderer                      :: common.Renderer
Window                        :: common.Window
Shader                        :: common.Shader
Gpu_Image                     :: common.Gpu_Image
Gpu_Buffer                    :: common.Gpu_Buffer

Engine_Description            :: common.Engine_Description
Renderer_Description          :: common.Renderer_Description
Shader_Description            :: common.Shader_Description
Gpu_Image_Description         :: common.Gpu_Image_Description
Gpu_Buffer_Description        :: common.Gpu_Buffer_Description
Gpu_Buffer_Upload_Description :: common.Gpu_Buffer_Upload_Description


renderer_create :: proc(create_info: ^Engine_Description, window: Window) -> (r: Renderer, res: Result) {
    return _renderer_create(create_info, window)
}

renderer_destroy :: proc(r: Renderer) {
    _renderer_destroy(r)
}

gpu_image_create :: proc(r: Renderer, description: ^Gpu_Image_Description) -> (gpu_image: Gpu_Image, res: Result) {
    return _gpu_image_create(r, description)
}

gpu_image_destroy :: proc(r: Renderer, gpu_image: Gpu_Image) {
    _gpu_image_destroy(r, gpu_image)
}

gpu_buffer_create :: proc(r: Renderer, description: ^Gpu_Buffer_Description) -> (gpu_buffer: Gpu_Buffer, res: Result) {
    return _gpu_buffer_create(r, description)
}

gpu_buffer_upload :: proc(r: Renderer, description: ^Gpu_Buffer_Upload_Description) -> (res: Result) {
    return _gpu_buffer_upload(r, description)
}

gpu_buffer_destroy :: proc(r: Renderer, gpu_buffer: Gpu_Buffer) {
    _gpu_buffer_destroy(r, gpu_buffer)
}

shader_create :: proc(r: Renderer, description: ^Shader_Description) -> (shader: Shader, res: Result) {
    return _shader_create(r, description)
}

shader_destroy :: proc(r: Renderer, shader: Shader) {
    _shader_destroy(r, shader)
}

cmd_graphics_begin :: proc(r: Renderer) {
    _cmd_graphics_begin(r)
}

cmd_graphics_end :: proc(r: Renderer) {
    _cmd_graphics_end(r)
}

cmd_graphics_present :: proc(r: Renderer) {
    _cmd_graphics_present(r)
}

cmd_graphics_clear :: proc(r: Renderer, color: common.vec4) {
    _cmd_graphics_clear(r, color)
}
