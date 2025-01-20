#+private

package callisto_gpu

import "core:log"

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
        
clamp_slice_length_and_log :: proc(length: int, max: int, location := #caller_location) -> int {
        when !ODIN_DISABLE_ASSERT && ODIN_DEBUG {
                if length > max {
                        log.error("Argument slice is too long. Length:", length, "Max:", max, location = location)
                }
        }

        return min(length, max)
}
