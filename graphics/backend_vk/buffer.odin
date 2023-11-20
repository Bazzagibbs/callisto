package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:log"
import "core:mem"

Gpu_Buffer :: struct {
    size:           vk.DeviceSize,
    buffer:         vk.Buffer,
    device_memory:  vk.DeviceMemory,
}


create_buffer :: proc(cg_ctx: ^Graphics_Context, size: int, usage: vk.BufferUsageFlags, properties: vk.MemoryPropertyFlags) -> (buffer: ^Gpu_Buffer, ok: bool) {
    buffer = new(Gpu_Buffer)
    defer if !ok do free(buffer)

    buffer_info := vk.BufferCreateInfo {
        sType       = .BUFFER_CREATE_INFO,
        size        = vk.DeviceSize(size),
        usage       = usage,
        sharingMode = .EXCLUSIVE,
    }

    res := vk.CreateBuffer(cg_ctx.device, &buffer_info, nil, &buffer.buffer)
    check_result(res) or_return
    defer if !ok do vk.DestroyBuffer(cg_ctx.device, buffer.buffer, nil)


    mem_requirements: vk.MemoryRequirements
    vk.GetBufferMemoryRequirements(cg_ctx.device, buffer.buffer, &mem_requirements)

    buffer.size = mem_requirements.size

    dst_mem_type := buffer_find_memory_type(cg_ctx, mem_requirements.memoryTypeBits, properties)
    buffer_allocate_memory(cg_ctx, mem_requirements.size, dst_mem_type, &buffer.device_memory) or_return
    defer if !ok do vk.FreeMemory(cg_ctx.device, buffer.device_memory, nil)

    res = vk.BindBufferMemory(cg_ctx.device, buffer.buffer, buffer.device_memory, 0)
    check_result(res) or_return

    return buffer, true
}


destroy_buffer :: proc(cg_ctx: ^Graphics_Context, buffer: ^Gpu_Buffer) {
    vk.DestroyBuffer(cg_ctx.device, buffer.buffer, nil)
    vk.FreeMemory(cg_ctx.device, buffer.device_memory, nil)
    free(buffer)
}


upload_buffer_data :: proc(cg_ctx: ^Graphics_Context, data: []byte, usage: vk.BufferUsageFlags) -> (buffer: ^Gpu_Buffer, ok: bool) {
    staging_buffer := create_buffer(cg_ctx, len(data), {.TRANSFER_SRC}, {.HOST_VISIBLE, .HOST_COHERENT}) or_return
    defer destroy_buffer(cg_ctx, staging_buffer)

    mapped_mem: rawptr
    vk.MapMemory(cg_ctx.device, staging_buffer.device_memory, 0, staging_buffer.size, {}, &mapped_mem)
    mem.copy(raw_data(data), mapped_mem, len(data))
    vk.UnmapMemory(cg_ctx.device, staging_buffer.device_memory)

    device_buffer := create_buffer(cg_ctx, len(data), {.TRANSFER_DST} + usage, {.DEVICE_LOCAL}) or_return

    buffer_copy(cg_ctx, staging_buffer.buffer, device_buffer.buffer, staging_buffer.size)

    return device_buffer, true
}


// ///////////////////////////////////////////////////////////////////////////

buffer_find_memory_type :: proc(cg_ctx: ^Graphics_Context, type_filter: u32, properties: vk.MemoryPropertyFlags) -> u32 {
    mem_properties: vk.PhysicalDeviceMemoryProperties
    vk.GetPhysicalDeviceMemoryProperties(cg_ctx.physical_device, &mem_properties)
    
    for i in 0..<mem_properties.memoryTypeCount {
        if (type_filter & (1 << i) != 0) &&
            (mem_properties.memoryTypes[i].propertyFlags & properties == properties) {
            return i
        }
    }

    log.error("No suitable memory type")
    return 0
}


buffer_allocate_memory :: proc(cg_ctx: ^Graphics_Context, size: vk.DeviceSize, mem_type: u32, memory: ^vk.DeviceMemory) -> (ok: bool) {
    alloc_info := vk.MemoryAllocateInfo {
        sType           = .MEMORY_ALLOCATE_INFO,
        allocationSize  = size,
        memoryTypeIndex = mem_type,
    }

    res := vk.AllocateMemory(cg_ctx.device, &alloc_info, nil, memory)
    check_result(res) or_return

    return true
}


buffer_copy :: proc(cg_ctx: ^Graphics_Context, src_buffer, dst_buffer: vk.Buffer, size: vk.DeviceSize) {
    alloc_info := vk.CommandBufferAllocateInfo {
        sType               = .COMMAND_BUFFER_ALLOCATE_INFO,
        level               = .PRIMARY,
        commandPool         = cg_ctx.transfer_pool,
        commandBufferCount  = 1,
    }

    cmd_buffer: vk.CommandBuffer
    vk.AllocateCommandBuffers(cg_ctx.device, &alloc_info, &cmd_buffer)

    begin_info := vk.CommandBufferBeginInfo {
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        flags = {.ONE_TIME_SUBMIT},
    }
    
    vk.BeginCommandBuffer(cmd_buffer, &begin_info)

    copy_region := vk.BufferCopy {
        size = size,
    }
    vk.CmdCopyBuffer(cmd_buffer, src_buffer, dst_buffer, 1, &copy_region)

    vk.EndCommandBuffer(cmd_buffer)

    submit_info := vk.SubmitInfo {
        sType = .SUBMIT_INFO,
        commandBufferCount = 1,
        pCommandBuffers = &cmd_buffer,
    }
    vk.QueueSubmit(cg_ctx.transfer_queue, 1, &submit_info, {})
    vk.QueueWaitIdle(cg_ctx.transfer_queue)
    vk.FreeCommandBuffers(cg_ctx.device, cg_ctx.transfer_pool, 1, &cmd_buffer)
}


// TODO: use VMA to allocate device memory better
