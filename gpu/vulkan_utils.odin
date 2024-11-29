package callisto_gpu

import "base:runtime"
import "core:path/filepath"
import "core:os/os2"
import "core:strings"
import "core:log"
import vk "../vendor_mod/vulkan"
import "../config"

// when RHI == "vulkan"

check_result :: proc(vkres: vk.Result, loc := #caller_location) -> Result {
        if vkres == .SUCCESS {
                return .Ok
        }
        
        log.error("RHI:", vkres, loc)
       
        #partial switch vkres {
        case .ERROR_OUT_OF_HOST_MEMORY: return .Allocation_Error_CPU
        case .ERROR_OUT_OF_DEVICE_MEMORY: return .Allocation_Error_GPU
        case .ERROR_MEMORY_MAP_FAILED: return .Memory_Map_Failed
        }

        return .Unknown_RHI_Error

}

_vk_prepend_layer_path :: proc() -> (ok: bool) {
        when ODIN_OS == .Windows {
                SEP :: ";"
        } else when ODIN_OS == .Linux || ODIN_OS == .Darwin {
                SEP :: ":"
        }
        
        existing := os2.get_env("VK_LAYER_PATH", context.temp_allocator)

        exe_dir := config.get_exe_directory(context.temp_allocator)
        ours := filepath.join({exe_dir, config.SHIPPING_LIBS_PATH, "vulkan"}, context.temp_allocator)

        if existing != "" {
                err: runtime.Allocator_Error
                ours, err = strings.join({ours, existing}, SEP)
                if err != nil {
                        return false
                }
        }

        return os2.set_env("VK_LAYER_PATH", ours)
}


