package callisto_graphics_vulkan

import vk "vendor:vulkan"

// Vulkan-specific structs
CVK_Buffer :: struct {
	size: 		u64,
	length:     u64,
	buffer: 	vk.Buffer,
	memory:		vk.DeviceMemory,
}


CVK_Shader :: struct {
	pipeline: 			vk.Pipeline,
	pipeline_layout:    vk.PipelineLayout,
}