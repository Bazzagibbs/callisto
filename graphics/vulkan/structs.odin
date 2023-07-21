package callisto_graphics_vulkan

import vk "vendor:vulkan"
import "../common"

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

CVK_Mesh :: struct {
	vertex_buffer:	common.Vertex_Buffer,
	index_buffer:	common.Index_Buffer,
}