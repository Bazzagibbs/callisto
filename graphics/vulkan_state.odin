//+build windows, linux, darwin
//+private
package callisto_graphics

import vk "vendor:vulkan"

State :: struct {
	debug_messenger            : vk.DebugUtilsMessengerEXT,
	instance                   : vk.Instance,
	surface                    : vk.SurfaceKHR,
	physical_device            : vk.PhysicalDevice,
	device                     : vk.Device,
	queue_family_indices       : Queue_Family_Indices,
	queues                     : Queue_Handles,
	swapchain                  : vk.SwapchainKHR,
	swapchain_details          : Swapchain_Details,
	target_image_index         : u32,
	images                     : []vk.Image,
	image_views                : []vk.ImageView,
    depth_image                : vk.Image,
    depth_image_view           : vk.ImageView,
    depth_image_memory         : vk.DeviceMemory,
	render_pass                : vk.RenderPass,
	pipeline                   : vk.Pipeline,
	pipeline_layout            : vk.PipelineLayout,
	framebuffers               : []vk.Framebuffer,
	command_pool               : vk.CommandPool,
    flight_frame               : u32,
	command_buffers            : []vk.CommandBuffer,
	image_available_semaphores : []vk.Semaphore,
	render_finished_semaphores : []vk.Semaphore,
	in_flight_fences           : []vk.Fence,
    descriptor_pool            : vk.DescriptorPool,
    texture_sampler_default    : vk.Sampler,
}

Queue_Family_Indices :: struct {
	graphics   : Maybe(u32),
	present    : Maybe(u32),
}

Queue_Handles :: struct {
	graphics   : vk.Queue,
	present    : vk.Queue,
}

Swapchain_Details :: struct {
	capabilities   : vk.SurfaceCapabilitiesKHR,
	format         : vk.SurfaceFormatKHR,
	present_mode   : vk.PresentModeKHR,
	extent         : vk.Extent2D,
}

_destroy_state :: proc(using state: ^State) {
	delete(images)
	delete(image_views)
	delete(framebuffers)
	delete(command_buffers)
	delete(image_available_semaphores)
	delete(render_finished_semaphores)
	delete(in_flight_fences)
}
