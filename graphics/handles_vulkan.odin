//+private
package callisto_graphics

import "../common"
import "../config"
import backend "backend_vk"

when config.RENDERER_API == .Vulkan {

    Renderer_Vk :: backend.Renderer
    Gpu_Image_Vk :: backend.Gpu_Image
    Gpu_Buffer_Vk :: backend.Gpu_Buffer

    to_handle :: proc {
        to_handle_renderer,
        to_handle_gpu_image,
        to_handle_gpu_buffer,
    }

    to_handle_renderer :: proc "contextless" (renderer_vk: ^Renderer_Vk) -> (Renderer) {
        return transmute(Renderer)renderer_vk;
    }

    to_handle_gpu_image :: proc "contextless" (gpu_img_vk: ^Gpu_Image_Vk) -> (Gpu_Image) {
        return transmute(Gpu_Image)gpu_img_vk;
    }

    to_handle_gpu_buffer :: proc "contextless" (gpu_buf_vk: ^Gpu_Buffer_Vk) -> (Gpu_Buffer) {
        return transmute(Gpu_Buffer)gpu_buf_vk;
    }


    from_handle :: proc {
        from_handle_renderer,
        from_handle_gpu_image,
        from_handle_gpu_buffer,
    }

    from_handle_renderer :: proc "contextless" (handle: Renderer) -> (^Renderer_Vk) {
        return transmute(^Renderer_Vk)handle;
    }

    from_handle_gpu_image :: proc "contextless" (handle: Gpu_Image) -> (^Gpu_Image_Vk) {
        return transmute(^Gpu_Image_Vk)handle;
    }

    from_handle_gpu_buffer :: proc "contextless" (handle: Gpu_Buffer) -> (^Gpu_Buffer_Vk) {
        return transmute(^Gpu_Buffer_Vk)handle;
    }



}
