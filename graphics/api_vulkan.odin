//+private
package callisto_graphics

import "../common"
import backend "backend_vk"

Renderer_Vk :: backend.Renderer
Gpu_Image_Vk :: backend.Gpu_Image
Gpu_Buffer_Vk :: backend.Gpu_Buffer


from_handle :: proc {
    from_handle_renderer,
    from_handle_gpu_image,
    from_handle_gpu_buffer,
}

from_handle_renderer :: proc "contextless" (handle: Renderer) -> (^Renderer_Vk) {
    return transmute(^Renderer_Vk)handle;
}

from_handle_gpu_image :: proc "contextless" (handle: Gpu_Image) -> (^Gpu_Image_Vk) {
    return transmute(^Renderer_Vk)handle;
}

from_handle_gpu_buffer :: proc "contextless" (handle: Gpu_Buffer) -> (^Gpu_Buffer_Vk) {
    return transmute(^Gpu_Buffer_Vk)handle;
}
