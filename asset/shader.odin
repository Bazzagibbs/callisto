package callisto_asset

import "core:io"
import "core:mem"
import cc "../common"

Gali_Shader_Stage_Flag :: cc.Shader_Stage_Flag
Gali_Compare_Op        :: cc.Compare_Op
Gali_Shader_Cull_Mode  :: cc.Shader_Cull_Mode
Gali_Gpu_Resource_Type :: cc.Gpu_Resource_Type

// Galileo file layout
// ///////////////////
Galileo_Shader_Manifest :: struct #packed {
    buffer_size            : u64, // Maybe this can go in the asset header?
    program_length         : u64, // u32 count
    resource_set_count     : u8,
    resource_binding_count : u8,
}

Galileo_Shader :: struct #packed {
    stage            : Gali_Shader_Stage_Flag,
    depth_test       : b8,
    depth_write      : b8,
    depth_compare_op : Gali_Compare_Op,
    cull_mode        : Gali_Shader_Cull_Mode,
}

Galileo_Shader_Resource_Set :: struct #packed {
    buffer_slice_begin : u32,
    binding_count : u8,
}

Galileo_Shader_Resource_Binding :: struct #packed {
    binding : u32,
    resource_type : cc.Gpu_Resource_Type,
}

// ///////////////////

Shader :: struct {
    using metadata   : Asset,
    stage            : cc.Shader_Stage_Flag,
    depth_test       : b8,
    depth_write      : b8,
    depth_compare_op : cc.Compare_Op,
    cull_mode        : cc.Shader_Cull_Mode,
    buffer           : []u8, // Stores resource bindings, then program
    
    resource_sets    : []cc.Gpu_Resource_Set, // View into buffer
    program          : []u32, // View into buffer
}


shader_serialize :: proc(shader: ^Shader, allocator := context.allocator) -> (data: []u8) {
    context.allocator = allocator

    file_buf_size := size_of(Galileo_Shader_Manifest) +
                     len(shader.resource_sets) * size_of(Galileo_Shader_Resource_Set) +
                     len(shader.program) * 4

    for set in shader.resource_sets {
        file_buf_size += len(set.bindings) * size_of(Galileo_Shader_Resource_Binding)
    }


    data = make([]u8, file_buf_size)
    cursor := 0
    
    manifest := new_struct_in_buffer(Galileo_Shader_Manifest, data, &cursor)

    unimplemented("Shader serialize")
    // return data
}
