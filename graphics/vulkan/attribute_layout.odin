package callisto_graphics_vulkan

import "core:runtime"
import "core:intrinsics"
import "core:log"
import vk "vendor:vulkan"

get_vertex_binding_description :: proc(vertex_type: typeid) -> (binding_desc: vk.VertexInputBindingDescription) {
    binding_desc = {
        binding = 0,
        stride = u32(type_info_of(vertex_type).size),
        inputRate = .VERTEX,
    }
    return
}

get_vertex_attribute_descriptions :: proc(vertex_type: typeid, attribute_descs: ^[dynamic]vk.VertexInputAttributeDescription) -> (ok: bool) {
    
    location_accumulator := 0
    
    vertex_type_info := type_info_of(vertex_type)
    struct_info: runtime.Type_Info_Struct = {}
    #partial switch variant_info in vertex_type_info.variant {
        case runtime.Type_Info_Named:
            struct_info = variant_info.base.variant.(runtime.Type_Info_Struct)
        case runtime.Type_Info_Struct:
            struct_info = variant_info
        case:
            log.fatal("Invalid vertex attribute struct")
            return false
    }

    attr_count := len(struct_info.types)
    resize(attribute_descs, attr_count)
    defer if !ok do resize(attribute_descs, 0)
    
    for i in 0..<attr_count {
        type := struct_info.types[i]
        offset := struct_info.offsets[i]
        ok = _get_vertex_attribute_from_type(type.id, offset, &location_accumulator, &attribute_descs[i]); if !ok {
            log.fatal("Invalid vertex attribute type:", type)
            return
        }
    }

    return
}

_get_vertex_attribute_from_type :: proc(attribute_type: typeid, offset: uintptr, location_accumulator: ^int, attribute_description: ^vk.VertexInputAttributeDescription) -> (ok: bool) {
    vk_format, locations_used := _typeid_to_vk_format(attribute_type)
    if vk_format == .UNDEFINED do return false

    attribute_description^ = {
        binding =   0,
        location =  u32(location_accumulator^),
        format =    vk_format,
        offset =    u32(offset),
    }

    location_accumulator^ += locations_used
    return true
}

_typeid_to_vk_format :: #force_inline proc(id: typeid) -> (format: vk.Format, locations_used: int) {
    locations_used = 1
    switch id {
        // Unsigned Int
        case typeid_of(u8):
            format = .R8_UINT
        case typeid_of([2]u8):
            format = .R8G8_UINT
        case typeid_of([3]u8):
            format = .R8G8B8_UINT
        case typeid_of([4]u8):
            format = .R8G8B8A8_UINT
        case typeid_of(u16):
            format = .R16_UINT
        case typeid_of([2]u16):
            format = .R16G16_UINT
        case typeid_of([3]u16):
            format = .R16G16B16_UINT
        case typeid_of([4]u16):
            format = .R16G16B16A16_UINT
        case typeid_of(u32):
            format = .R32_UINT
        case typeid_of([2]u32):
            format = .R32G32_UINT
        case typeid_of([3]u32):
            format = .R32G32B32_UINT
        case typeid_of([4]u32):
            format = .R32G32B32A32_UINT
        case typeid_of(u64):
            format = .R64_UINT
        case typeid_of([2]u64):
            format = .R64G64_UINT
        case typeid_of([3]u64):
            format = .R64G64B64_UINT
        case typeid_of([4]u64):
            format = .R64G64B64A64_UINT

        // Signed Int
        case typeid_of(i8):
            format = .R8_SINT
        case typeid_of([2]i8):
            format = .R8G8_SINT
        case typeid_of([3]i8):
            format = .R8G8B8_SINT
        case typeid_of([4]i8):
            format = .R8G8B8A8_SINT
        case typeid_of(i16):
            format = .R16_SINT
        case typeid_of([2]i16):
            format = .R16G16_SINT
        case typeid_of([3]i16):
            format = .R16G16B16_SINT
        case typeid_of([4]i16):
            format = .R16G16B16A16_SINT
        case typeid_of(i32):
            format = .R32_SINT
        case typeid_of([2]i32):
            format = .R32G32_SINT
        case typeid_of([3]i32):
            format = .R32G32B32_SINT
        case typeid_of([4]i32):
            format = .R32G32B32A32_SINT
        case typeid_of(i64):
            format = .R64_SINT
        case typeid_of([2]i64):
            format = .R64G64_SINT
        case typeid_of([3]i64):
            format = .R64G64B64_SINT
        case typeid_of([4]i64):
            format = .R64G64B64A64_SINT
        
        // Float
        case typeid_of(f32):
            format = .R32_SFLOAT
        case typeid_of([2]f32):
            format = .R32G32_SFLOAT
        case typeid_of([3]f32):
            format = .R32G32B32_SFLOAT
        case typeid_of([4]f32):
            format = .R32G32B32A32_SFLOAT
        case typeid_of(f64):
            format = .R64_SFLOAT
        case typeid_of([2]f64):
            format = .R64G64_SFLOAT
        case typeid_of([3]f64):
            format = .R64G64B64_SFLOAT
            locations_used = 2
        case typeid_of([4]f64):
            format = .R64G64B64A64_SFLOAT
            locations_used = 2

        // TODO: Mat3, Mat4

        case:
            format = .UNDEFINED
    }
    return

}


