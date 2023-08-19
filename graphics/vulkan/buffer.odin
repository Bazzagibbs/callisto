package callisto_graphics_vulkan

import "core:log"
import "core:mem"
import "core:runtime"
import "../common"
import "../../config"
import "../../asset"
import vk "vendor:vulkan"

create_vertex_attribute_buffer :: proc(attribute_data: $T/[]$E, attribute_buffer: ^^CVK_Buffer) -> (ok: bool) {
    buf_len := u64(len(attribute_data))
    buf_size := u64(buf_len * size_of(E))

    staging_buffer, err1 := new(CVK_Buffer); if err1 != .None {
        log.error("Failed to create buffer:", err1)
        return false
    }
    defer destroy_buffer(staging_buffer)
    staging_buffer.size = buf_size
    staging_buffer.length = buf_len
    staging_buffer_usage: vk.BufferUsageFlags = {.TRANSFER_SRC}
    staging_buffer_properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}
    create_buffer(staging_buffer.size, staging_buffer_usage, staging_buffer_properties, staging_buffer) or_return
    
    // Copy data to staging buffer
    vk_data: rawptr
    vk.MapMemory(bound_state.device, staging_buffer.memory, 0, vk.DeviceSize(staging_buffer.size), {}, &vk_data)
    mem.copy(vk_data, raw_data(attribute_data), int(staging_buffer.size))
    vk.UnmapMemory(bound_state.device, staging_buffer.memory)
    
    local_buffer, err2 := new(CVK_Buffer); if err2 != .None {
        log.error("Failed to create buffer:", err2)
        return false
    }
    defer if !ok do destroy_buffer(local_buffer)
    local_buffer.size = buf_size
    local_buffer.length = buf_len
    usage: vk.BufferUsageFlags = {.TRANSFER_DST, .VERTEX_BUFFER}
    properties: vk.MemoryPropertyFlags = {.DEVICE_LOCAL}
    create_buffer(local_buffer.size, usage, properties, local_buffer) or_return

    copy_buffer(staging_buffer, local_buffer) or_return
    attribute_buffer^ = local_buffer
    return true
}

destroy_vertex_attribute_buffer :: proc(buffer: ^CVK_Buffer) {
    destroy_buffer(buffer)
}

create_index_buffer :: proc(indices: $T/[]$E, buffer: ^^CVK_Buffer) -> (ok: bool) {
    buf_len := u64(len(indices))
    buf_size := u64(buf_len * size_of(E))

    staging_buffer, err1 := new(CVK_Buffer); if err1 != .None {
        log.error("Failed to create buffer:", err1)
        return false
    }
    defer destroy_buffer(staging_buffer)
    staging_buffer.size = buf_size
    staging_buffer.length = buf_len
    staging_buffer_usage: vk.BufferUsageFlags = {.TRANSFER_SRC}
    staging_buffer_properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}
    create_buffer(staging_buffer.size, staging_buffer_usage, staging_buffer_properties, staging_buffer) or_return
    
    vk_data: rawptr
    vk.MapMemory(bound_state.device, staging_buffer.memory, 0, vk.DeviceSize(staging_buffer.size), {}, &vk_data)
    mem.copy(vk_data, raw_data(indices), int(staging_buffer.size))
    vk.UnmapMemory(bound_state.device, staging_buffer.memory)

    local_buffer, err2 := new(CVK_Buffer); if err2 != .None {
        log.error("Failed to create buffer:", err2)
        return false
    }
    defer if !ok do destroy_buffer(local_buffer)
    local_buffer.size = buf_size
    local_buffer.length = buf_len
    usage: vk.BufferUsageFlags = {.TRANSFER_DST, .INDEX_BUFFER}
    properties: vk.MemoryPropertyFlags = {.DEVICE_LOCAL}
    create_buffer(local_buffer.size, usage, properties, local_buffer) or_return

    copy_buffer(staging_buffer, local_buffer) or_return

    buffer^ = local_buffer
    return true
}

destroy_index_buffer :: proc(buffer: ^CVK_Buffer) {
    destroy_buffer(buffer)
}

create_material_uniform_buffers :: proc(uniform_buffer_typeid: typeid, material_instance: ^CVK_Material_Instance) -> (ok: bool) {
    ok = true
    using bound_state
    
    ubo_type_info := type_info_of(uniform_buffer_typeid)
    #partial switch v in ubo_type_info.variant {
        case runtime.Type_Info_Struct:
        case runtime.Type_Info_Named:
            ubo_type_info = v.base
        case:
            log.error("Unsupported uniform buffer type")
            return false
    }
    buf_size := ubo_type_info.size

    usage: vk.BufferUsageFlags = {.UNIFORM_BUFFER}
    properties: vk.MemoryPropertyFlags = {.HOST_VISIBLE, .HOST_COHERENT}
    resize(&material_instance.uniform_buffers, config.RENDERER_FRAMES_IN_FLIGHT)
    resize(&material_instance.uniform_buffers_mapped, config.RENDERER_FRAMES_IN_FLIGHT)

    for i in 0..<config.RENDERER_FRAMES_IN_FLIGHT {
        cvk_buffer, err := new(CVK_Buffer); if err != .None {
            log.error("Failed to create uniform buffer:", err)
            return false
        }
        cvk_buffer.size = u64(buf_size)
        create_buffer(u64(buf_size), usage, properties, cvk_buffer) or_return
        defer if !ok do destroy_buffer(cvk_buffer)


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


destroy_material_uniform_buffers :: proc(material_instance: common.Material_Instance) {
    using bound_state
    cvk_mat_instance := transmute(^CVK_Material_Instance)material_instance
    for i in 0..<config.RENDERER_FRAMES_IN_FLIGHT {
        buf := cvk_mat_instance.uniform_buffers[i]
        cvk_buffer := transmute(^CVK_Buffer)buf
        // vk.UnmapMemory(device, cvk_buffer.memory)
        // vk.FreeMemory(device, cvk_buffer.memory, nil)
        destroy_buffer(cvk_buffer)
    }
}


create_static_mesh :: proc(mesh_asset: ^asset.Mesh, mesh: ^common.Mesh) -> (ok: bool) {
    ok = true
    cvk_mesh := new(CVK_Mesh)
    defer if !ok do free(cvk_mesh)
    
    // create index buffer
    create_index_buffer(mesh_asset.indices, &cvk_mesh.indices) or_return
    defer if !ok do destroy_index_buffer(cvk_mesh.indices)

    // create buffers for mandatory attributes
    create_vertex_attribute_buffer(mesh_asset.positions, &cvk_mesh.positions) or_return
    defer if !ok do destroy_vertex_attribute_buffer(cvk_mesh.positions)
    create_vertex_attribute_buffer(mesh_asset.normals, &cvk_mesh.normals) or_return
    defer if !ok do destroy_vertex_attribute_buffer(cvk_mesh.normals)
    create_vertex_attribute_buffer(mesh_asset.tex_coords_0, &cvk_mesh.tex_coords_0) or_return
    defer if !ok do destroy_vertex_attribute_buffer(cvk_mesh.tex_coords_0)

    // TODO: add support for optional attributes

    mesh^ = transmute(common.Mesh)cvk_mesh
    return true
}

destroy_static_mesh :: proc(mesh: common.Mesh) {
    cvk_mesh := transmute(^CVK_Mesh)mesh

    destroy_vertex_attribute_buffer(cvk_mesh.indices)

    destroy_vertex_attribute_buffer(cvk_mesh.positions)
    destroy_vertex_attribute_buffer(cvk_mesh.normals)
    destroy_vertex_attribute_buffer(cvk_mesh.tex_coords_0)

    // TODO: add support for optional attributes
    free(mesh)
}

create_buffer :: proc(size: u64, usage: vk.BufferUsageFlags, properties: vk.MemoryPropertyFlags, cvk_buffer: ^CVK_Buffer) -> (ok: bool) {
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
        memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, properties),
    }
    
    res = vk.AllocateMemory(device, &memory_alloc_info, nil, &cvk_buffer.memory); if res != .SUCCESS {
        log.error("Failed to allocate memory:", res)
        return false
    }
    defer if !ok do vk.FreeMemory(device, cvk_buffer.memory, nil)
    vk.BindBufferMemory(device, cvk_buffer.buffer, cvk_buffer.memory, 0)

    return true
}


destroy_buffer :: proc(buffer: ^CVK_Buffer) {
    using bound_state
    vk.DeviceWaitIdle(device)
    vk.DestroyBuffer(device, buffer.buffer, nil)
    vk.FreeMemory(device, vk.DeviceMemory(buffer.memory), nil)
    free(buffer)
}

copy_buffer :: proc(src_buffer, dst_buffer: ^CVK_Buffer) -> (ok: bool) {
    temp_command_buffer: vk.CommandBuffer
    begin_one_shot_commands(&temp_command_buffer)

    copy_region: vk.BufferCopy = {
        size = vk.DeviceSize(src_buffer.size),
    }
    vk.CmdCopyBuffer(temp_command_buffer, src_buffer.buffer, dst_buffer.buffer, 1, &copy_region)
    
    end_one_shot_commands(temp_command_buffer)

    return true
}

copy_vk_buffer_to_vk_image :: proc(buffer: vk.Buffer, img: vk.Image, width, height: u32) {
    temp_command_buffer: vk.CommandBuffer
    begin_one_shot_commands(&temp_command_buffer)

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
    end_one_shot_commands(temp_command_buffer)
}
