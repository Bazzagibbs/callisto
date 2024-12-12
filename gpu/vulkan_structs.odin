package callisto_gpu

import dd "vendor:vulkan"

import "core:os/os2"
import "core:dynlib"
import "core:sync"
import "core:log"
import vk "vulkan"
import "vma"
import "../common"


// when RHI == "vulkan" {
@(private)
VK_VALIDATION_LAYER          :: ODIN_DEBUG

@(private)
VK_ENABLE_INSTANCE_DEBUGGING :: false



// **IMPORTANT**: Don't use this vtable directly in application code!
// Doing so will break the ability to port to a different renderer in the future.
Device :: struct {
        using vtable         : vk.VTable,

        instance             : vk.Instance,
        debug_messenger      : vk.DebugUtilsMessengerEXT,
        phys_device          : vk.PhysicalDevice,
        device               : vk.Device,

        allocator            : vma.Allocator,

        graphics_family      : u32,
        present_family       : u32,
        async_compute_family : u32,
        
        // Device owns the queues? One queue each per application
        graphics_queue       : vk.Queue,
        present_queue        : vk.Queue,
        async_compute_queue  : vk.Queue,

        submit_mutex         : sync.Mutex,
}

Swapchain :: struct {
        window               : Window_Handle,
        surface              : vk.SurfaceKHR,
        swapchain            : vk.SwapchainKHR,
        image_format         : vk.SurfaceFormatKHR,
        image_index          : u32,
        textures             : []Texture, // acquired, only destroy full_view
        extent               : vk.Extent2D,
        pending_destroy      : vk.SwapchainKHR,

        image_available_sema : [FRAMES_IN_FLIGHT]vk.Semaphore,
        render_finished_sema : [FRAMES_IN_FLIGHT]vk.Semaphore,
        in_flight_fence      : [FRAMES_IN_FLIGHT]vk.Fence,
        command_buffers      : [FRAMES_IN_FLIGHT]Command_Buffer,

        graphics_queue       : vk.Queue, // Owned by Device
        present_queue        : vk.Queue,

        frame_counter        : u32,
        needs_recreate       : bool,
        vsync                : Vsync_Mode,
        force_draw_occluded  : bool,
}


// Use a separate Command_Buffer per thread.
Command_Buffer :: struct {
        queue        : Queue_Flag,

        pool         : vk.CommandPool,
        buffer       : vk.CommandBuffer,

        wait_sema    : vk.Semaphore,
        signal_sema  : vk.Semaphore,
        signal_fence : vk.Fence,
}


Texture :: struct {
        image       : vk.Image,
        full_view   : Texture_View,
        extent      : vk.Extent3D,
        mip_count   : u32,
        layer_count : u32,
        allocation  : vma.Allocation,
}

Texture_View   :: struct {
        view   : vk.ImageView,
}

Sampler        :: struct {}
Shader         :: struct {}

Buffer         :: struct {}

// GPU -> CPU sync
Fence :: struct {
        fence: vk.Fence,
}

// GPU -> GPU sync
Semaphore :: struct { 
        sema: vk.Semaphore,
}

// } // when RHI == "vulkan"
