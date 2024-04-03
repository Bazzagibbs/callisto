package callisto_graphics
import "../common"
import "../asset"

Result                        :: common.Result
Renderer                      :: distinct common.Handle
Gpu_Image                     :: distinct common.Handle
Gpu_Buffer                    :: distinct common.Handle

Renderer_Description          :: common.Renderer_Description
Gpu_Image_Description         :: struct {}
Gpu_Buffer_Description        :: struct {}
Gpu_Buffer_Upload_Description :: struct {}


renderer_create :: proc(create_info: ^Renderer_Description) -> (r: Renderer, res: Result) {
    unimplemented();
}

renderer_destroy :: proc(r: Renderer) {
    unimplemented();
}

gpu_image_create :: proc(r: Renderer, description: ^Gpu_Image_Description) -> (gpu_image: Gpu_Image, res: Result) {
    unimplemented();
}

gpu_image_destroy :: proc(r: Renderer, gpu_img: Gpu_Image) {
    unimplemented();
}

gpu_buffer_create :: proc(r: Renderer, description: ^Gpu_Buffer_Description) -> (gpu_buffer: Gpu_Buffer, res: Result) {
    unimplemented();
}

gpu_buffer_upload :: proc(r: Renderer, description: ^Gpu_Buffer_Upload_Description) -> (res: Result) {
    unimplemented();
}

gpu_buffer_destroy :: proc(r: Renderer, gpu_buffer: Gpu_Buffer) {
    unimplemented();
}


