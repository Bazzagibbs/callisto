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


// **IMPORTANT**: Don't use this vtable directly in application code!
// Doing so will break the ability to port to a different renderer in the future.
Device :: struct {
        using vtable             : vk.VTable,

        instance                 : vk.Instance,
        debug_messenger          : vk.DebugUtilsMessengerEXT,
        phys_device              : vk.PhysicalDevice,
        device                   : vk.Device,

        allocator                : vma.Allocator,

        graphics_family          : u32,
        present_family           : u32,
        async_compute_family     : u32,
        
        uniform_alignment        : u32,
        
        graphics_queue           : vk.Queue,
        present_queue            : vk.Queue,
        async_compute_queue      : vk.Queue,

        submit_mutex             : sync.Mutex,

        bindless_layout          : vk.DescriptorSetLayout,
        bindless_pool            : vk.DescriptorPool,
        bindless_set             : vk.DescriptorSet,
        bindless_pipeline_layout : vk.PipelineLayout,

        descriptor_allocator_sampled_tex : _Descriptor_Allocator,
        descriptor_allocator_storage_tex : _Descriptor_Allocator,
}

@(private)
_Descriptor_Allocator :: struct {
        next      : int,
        free_list : [MAX_DESCRIPTORS]u32, // FEATURE(Texture limit)
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
        queue               : Queue_Flag,

        pool                : vk.CommandPool,
        buffer              : vk.CommandBuffer,

        wait_sema           : vk.Semaphore,
        signal_sema         : vk.Semaphore,
        signal_fence        : vk.Fence,

        push_constant_state : [4]vk.DeviceAddress,
}


Texture :: struct {
        image       : vk.Image,
        full_view   : Texture_View,
        extent      : vk.Extent3D,
        mip_count   : u32,
        layer_count : u32,
        allocation  : vma.Allocation,
        is_sampled  : bool,
        is_storage  : bool,
        sampled_reference : Texture_Reference,
        storage_reference : Texture_Reference,
}

Texture_View   :: struct {
        view   : vk.ImageView,
}

Texture_Reference :: struct {
        handle: u32,
}

Sampler :: struct {}

Shader :: struct {
        shader : vk.ShaderEXT,
        stages : vk.ShaderStageFlags,
}

Buffer :: struct {
        buffer     : vk.Buffer,
        allocation : vma.Allocation,
        alloc_info : vma.AllocationInfo,
        address    : vk.DeviceAddress,
        stride     : u32,
}

Buffer_Reference :: struct {
        address : vk.DeviceAddress,
}

// GPU -> CPU sync
Fence :: struct {
        fence: vk.Fence,
}

// GPU -> GPU sync
Semaphore :: struct { 
        sema: vk.Semaphore,
}


// } // when RHI == "vulkan"
