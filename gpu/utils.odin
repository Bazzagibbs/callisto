package callisto_gpu

len32 :: proc {
        len32_slice,
        len32_string,
        len32_dynamic_array,
}

len32_slice :: #force_inline proc(slice: $T/[]$E) -> u32 {
        return u32(len(slice))
}


len32_string :: #force_inline proc(str: string) -> u32 {
        return u32(len(str))
}

len32_dynamic_array :: #force_inline proc(dynamic_array: $T/[dynamic]$E) -> u32 {
        return u32(len(dynamic_array))
}
        
