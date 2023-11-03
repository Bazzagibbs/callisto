//+build windows, linux, darwin
//+private
package callisto_graphics

import "core:log"
import "core:mem"
import "core:runtime"
import "../config"
import "../asset"
import vk "vendor:vulkan"

// TODO: reduce indirection, store CVK_Buffer directly
_create_vertex_attribute_buffer :: proc(attribute_data: $T/[]$E, attribute_buffer: ^^CVK_Buffer) -> (ok: bool) {
    buf_len := u64(len(attribute_data))
    buf_size := u64(buf_len * size_of(E))

    staging_buffer, err1 := new(CVK_Buffer); if err1 != .None {
        log.error("Failed to create buffer:", err1)
        return false
    }
    defer _destroy_buffer(staging_buffer)
    staging_buffer.size = buf_size
    staging_buffer.length = buf_len
    staging_buffer_usage: vk.BufferUsageFlags = {.TRANSFER_SRC}
    staging_buffer_properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}
    _create_buffer(staging_buffer.size, staging_buffer_usage, staging_buffer_properties, staging_buffer) or_return
    
    // Copy data to staging buffer
    vk_data: rawptr
    vk.MapMemory(bound_state.device, staging_buffer.memory, 0, vk.DeviceSize(staging_buffer.size), {}, &vk_data)
    mem.copy(vk_data, raw_data(attribute_data), int(staging_buffer.size))
    vk.UnmapMemory(bound_state.device, staging_buffer.memory)
   
    // TODO: don't need to alloc here, caller can provide memory
    local_buffer, err2 := new(CVK_Buffer); if err2 != .None {
        log.error("Failed to create buffer:", err2)
        return false
    }
    defer if !ok do _destroy_buffer(local_buffer)
    local_buffer.size = buf_size
    local_buffer.length = buf_len
    usage: vk.BufferUsageFlags = {.TRANSFER_DST, .VERTEX_BUFFER}
    properties: vk.MemoryPropertyFlags = {.DEVICE_LOCAL}
    _create_buffer(local_buffer.size, usage, properties, local_buffer) or_return

    _copy_buffer(staging_buffer, local_buffer) or_return
    attribute_buffer^ = local_buffer
    return true
}

_destroy_vertex_attribute_buffer :: proc(buffer: ^CVK_Buffer) {
    _destroy_buffer(buffer)
}

_create_index_buffer :: proc(indices: $T/[]$E, buffer: ^^CVK_Buffer) -> (ok: bool) {
    buf_len := u64(len(indices))
    buf_size := u64(buf_len * size_of(E))

    staging_buffer, err1 := new(CVK_Buffer); if err1 != .None {
        log.error("Failed to create buffer:", err1)
        return false
    }
    defer _destroy_buffer(staging_buffer)
    staging_buffer.size = buf_size
    staging_buffer.length = buf_len
    staging_buffer_usage: vk.BufferUsageFlags = {.TRANSFER_SRC}
    staging_buffer_properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}
    _create_buffer(staging_buffer.size, staging_buffer_usage, staging_buffer_properties, staging_buffer) or_return
    
    vk_data: rawptr
    vk.MapMemory(bound_state.device, staging_buffer.memory, 0, vk.DeviceSize(staging_buffer.size), {}, &vk_data)
    mem.copy(vk_data, raw_data(indices), int(staging_buffer.size))
    vk.UnmapMemory(bound_state.device, staging_buffer.memory)

    local_buffer, err2 := new(CVK_Buffer); if err2 != .None {
        log.error("Failed to create buffer:", err2)
        return false
    }
    defer if !ok do _destroy_buffer(local_buffer)
    local_buffer.size = buf_size
    local_buffer.length = buf_len
    usage: vk.BufferUsageFlags = {.TRANSFER_DST, .INDEX_BUFFER}
    properties: vk.MemoryPropertyFlags = {.DEVICE_LOCAL}
    _create_buffer(local_buffer.size, usage, properties, local_buffer) or_return

    _copy_buffer(staging_buffer, local_buffer) or_return

    buffer^ = local_buffer
    return true
}

_destroy_index_buffer :: proc(buffer: ^CVK_Buffer) {
    _destroy_buffer(buffer)
}

_create_material_uniform_buffers :: proc(material_buffer_typeid: typeid, material_instance: ^CVK_Material_Instance) -> (ok: bool) {
    ok = true
    using bound_state
    
    ubo_type_info := type_info_of(material_buffer_typeid)
    #partial switch v in ubo_type_info.variant {
        case runtime.Type_Info_Struct:
        case runtime.Type_Info_Named:
            ubo_type_info = v.base
        case:
            log.warn("Unsupported uniform buffer type")
            return true
    }
    buf_size := ubo_type_info.size

    usage: vk.BufferUsageFlags = {.UNIFORM_BUFFER}
    properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}

    material_instance.uniform_buffers = make([]^CVK_Buffer, config.RENDERER_FRAMES_IN_FLIGHT)
    material_instance.uniform_buffers_mapped = make([]rawptr, config.RENDERER_FRAMES_IN_FLIGHT)

    for i in 0..<config.RENDERER_FRAMES_IN_FLIGHT {
        cvk_buffer, err := new(CVK_Buffer); if err != .None {
            log.error("Failed to create uniform buffer:", err)
            return false
        }
        cvk_buffer.size = u64(buf_size)
        _create_buffer(u64(buf_size), usage, properties, cvk_buffer) or_return
        defer if !ok do _destroy_buffer(cvk_buffer)


        res := vk.MapMemory(device, cvk_buffer.memory, 0, vk.DeviceSize(buf_size), {}, &material_instance.uniform_buffers_mapped[i]); if res != .SUCCESS {
            log.error("Failed to create uniform buffer:", res)
            return false
        }
        defer if !ok {
            vk.UnmapMemory(device, cvk_buffer.memory)
            vk.FreeMemory(device, cvk_buffer.memory, nil)
        } 
        
        material_instance.uniform_buffers[i] = cvk_buffer
    }
    return true
}


_destroy_material_uniform_buffers :: proc(material_instance: Material_Instance) {
    using bound_state
    cvk_mat_instance := transmute(^CVK_Material_Instance)material_instance
    for i in 0..<config.RENDERER_FRAMES_IN_FLIGHT {
        buf := cvk_mat_instance.uniform_buffers[i]
        cvk_buffer := transmute(^CVK_Buffer)buf
        // vk.UnmapMemory(device, cvk_buffer.memory)
        // vk.FreeMemory(device, cvk_buffer.memory, nil)
        _destroy_buffer(cvk_buffer)
    }
}


_impl_create_static_mesh :: proc(mesh_asset: ^asset.Mesh, mesh: ^Mesh) -> (ok: bool) {
    ok = true
    cvk_mesh := new(CVK_Mesh)
    defer if !ok do free(cvk_mesh)
 
    cvk_mesh.vertex_groups = make([]CVK_Vertex_Group, len(mesh_asset.vertex_groups))
    defer if !ok do delete(cvk_mesh.vertex_groups)

    defer if !ok do _impl_destroy_static_mesh(transmute(Mesh)&cvk_mesh)

    for asset_vert_group, i in mesh_asset.vertex_groups {
        cvk_vertex_group := &cvk_mesh.vertex_groups[i]
        _create_index_buffer(asset_vert_group.index, &cvk_vertex_group.index) or_return
        
        _create_vertex_attribute_buffer(asset_vert_group.position,      &cvk_vertex_group.position) or_return
        _create_vertex_attribute_buffer(asset_vert_group.normal,        &cvk_vertex_group.normal)   or_return
        _create_vertex_attribute_buffer(asset_vert_group.tangent,       &cvk_vertex_group.tangent)  or_return
        // if len(asset_vert_group.texcoords) > 0 {
        _create_vertex_attribute_buffer(asset_vert_group.texcoords[0],  &cvk_vertex_group.uv_0)     or_return
        // } else {
        //     _create_empty_buffer(&cvk_vertex_group.uv_0)
        // }
    }
    
    mesh^ = transmute(Mesh)cvk_mesh
    return true
}


_impl_destroy_static_mesh :: proc(mesh: Mesh) {
    cvk_mesh := transmute(^CVK_Mesh)mesh
    
    for cvk_vert_group in cvk_mesh.vertex_groups {
        _destroy_buffer(cvk_vert_group.index)
        
        _destroy_buffer(cvk_vert_group.position)
        _destroy_buffer(cvk_vert_group.normal)
        _destroy_buffer(cvk_vert_group.tangent)
        _destroy_buffer(cvk_vert_group.uv_0)
    }
    delete(cvk_mesh.vertex_groups)
    free(mesh)
}

_create_buffer :: proc(size: u64, usage: vk.BufferUsageFlags, properties: vk.MemoryPropertyFlags, cvk_buffer: ^CVK_Buffer) -> (ok: bool) {
    using bound_state
    cvk_buffer.size = size

    buffer_create_info := vk.BufferCreateInfo {
        sType = .BUFFER_CREATE_INFO,
        size = vk.DeviceSize(size),
        usage = usage,
        sharingMode = .EXCLUSIVE,
    }
    res := vk.CreateBuffer(device, &buffer_create_info, nil, &cvk_buffer.buffer); if res != .SUCCESS {
        log.error("Failed to create buffer:", res)
        return false
    }
    defer if !ok do vk.DestroyBuffer(device, cvk_buffer.buffer, nil)
    
    requirements: vk.MemoryRequirements
    vk.GetBufferMemoryRequirements(device, cvk_buffer.buffer, &requirements)

    memory_alloc_info: vk.MemoryAllocateInfo = {
        sType = .MEMORY_ALLOCATE_INFO,
        allocationSize = requirements.size,
        memoryTypeIndex = _find_memory_type(requirements.memoryTypeBits, properties),
    }
    
    res = vk.AllocateMemory(device, &memory_alloc_info, nil, &cvk_buffer.memory); if res != .SUCCESS {
        log.error("Failed to allocate memory:", res)
        return false
    }
    defer if !ok do vk.FreeMemory(device, cvk_buffer.memory, nil)
    vk.BindBufferMemory(device, cvk_buffer.buffer, cvk_buffer.memory, 0)

    return true
}

_destroy_buffer :: proc(buffer: ^CVK_Buffer) {
    using bound_state
    if buffer.buffer != 0 {
        vk.DeviceWaitIdle(device)
        vk.DestroyBuffer(device, buffer.buffer, nil)
        vk.FreeMemory(device, vk.DeviceMemory(buffer.memory), nil)
    }
    free(buffer)
}

_copy_buffer :: proc(src_buffer, dst_buffer: ^CVK_Buffer) -> (ok: bool) {
    temp_command_buffer: vk.CommandBuffer
    _begin_one_shot_commands(&temp_command_buffer)

    copy_region: vk.BufferCopy = {
        size = vk.DeviceSize(src_buffer.size),
    }
    vk.CmdCopyBuffer(temp_command_buffer, src_buffer.buffer, dst_buffer.buffer, 1, &copy_region)
    
    _end_one_shot_commands(temp_command_buffer)

    return true
}

_copy_vk_buffer_to_vk_image :: proc(buffer: vk.Buffer, img: vk.Image, width, height: u32) {
    temp_command_buffer: vk.CommandBuffer
    _begin_one_shot_commands(&temp_command_buffer)

    region := vk.BufferImageCopy {
        bufferOffset = 0,
        bufferRowLength = 0,
        bufferImageHeight = 0,
        imageSubresource = {
            aspectMask = {.COLOR},
            mipLevel = 0,
            baseArrayLayer = 0,
            layerCount = 1,
        },
        imageOffset = {0, 0, 0},
        imageExtent = {width, height, 1},
    }

    vk.CmdCopyBufferToImage(temp_command_buffer, buffer, img, .TRANSFER_DST_OPTIMAL, 1, &region)
    _end_one_shot_commands(temp_command_buffer)
}
