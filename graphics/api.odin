package callisto_graphics
import "../common"
import "../asset"

Result                 :: common.Result
Renderer               :: distinct common.Handle
Gpu_Image              :: distinct common.Handle
Gpu_Buffer             :: distinct common.Handle

Renderer_Create_Info   :: struct {}
Gpu_Image_Create_Info  :: struct {}
Gpu_Buffer_Create_Info :: struct {}
Gpu_Buffer_Upload_Info :: struct {}


renderer_create :: proc(create_info: ^Renderer_Create_Info) -> (r: Renderer, res: Result) {
    unimplemented();
}

renderer_destroy :: proc(r: Renderer) {
    unimplemented();
}

gpu_image_create :: proc(r: Renderer, description: ^Gpu_Image_Create_Info) -> (gpu_img: Gpu_Image, res: Result) {
    unimplemented();
}

gpu_image_destroy :: proc(r: Renderer, gpu_img: Gpu_Image) {
    unimplemented();
}

gpu_buffer_create :: proc(r: Renderer, description: ^Gpu_Buffer_Create_Info) -> (gpu_buf: Gpu_Buffer, res: Result) {
    unimplemented();
}

gpu_buffer_upload :: proc(r: Renderer, description: ^Gpu_Buffer_Upload_Info) -> (res: Result) {
    unimplemented();
}

gpu_buffer_destroy :: proc(r: Renderer, gpu_buf: Gpu_Buffer) {
    unimplemented();
}


