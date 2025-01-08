#+ private

package callisto_gpu

import "core:log"
import "base:runtime"

// A validation layer at the RHI level so applications don't rely on undefined behaviour.
// At the moment, only validate create info - don't want to maintain our own state machine.

// TODO:
// - device_create (nothing at the moment)
// - swapchain_create
// - vertex_shader_create
// - fragment_shader_create
// - compute_shader_create
// - buffer_create
// - sampler_create
// - command_buffer_create


_validate :: proc(condition: bool, assertion: bool, location: runtime.Source_Code_Location, description := "", condition_expr := #caller_expression(condition), assertion_expr := #caller_expression(assertion)) -> bool {
        if condition == true && assertion == false {
                log.error("Validation failed: When ", condition_expr, ", ", assertion_expr, " must be true. ", description, sep = "", location = location)
                return false
        }

        return true
}

_validate_always :: proc(assertion: bool, location: runtime.Source_Code_Location, description := "", assertion_expr := #caller_expression(assertion)) -> bool {
        if assertion == false {
                log.error("Validation failed: ", assertion_expr, " must be true. ", description, sep = "", location = location)
                return false
        }

        return true
}


_validate_texture2d_create :: proc(create_info: ^Texture2D_Create_Info, location: runtime.Source_Code_Location) -> Result {
        when RHI_VALIDATION {
                valid := true
                valid &= _validate_always(create_info.mip_levels >= 0, location) // 0 mips is "full chain"
                valid &= _validate_always(create_info.mip_levels <= 14, location)
                valid &= _validate_always(create_info.resolution.x <= 2e14 && create_info.resolution.y <= 2e14, location)
                valid &= _validate_always(create_info.resolution.x >= 1 && create_info.resolution.y >= 1, location)
                valid &= _validate(create_info.multisample != .None, create_info.initial_data == nil, location, "Multisampled textures cannot have initial data.")
                valid &= _validate(create_info.allow_generate_mips == true, create_info.usage >= {.Render_Target}, location, "Generating mips requires that a shader can render to the texture.")
                valid &= _validate(create_info.allow_generate_mips == true, create_info.access == .Device_General, location, "Generating mips requires that a texture is writable from the GPU.") 
                valid &= _validate(create_info.mip_levels == 0, create_info.initial_data == nil, location, "A mip level count must be provided to upload initial data.")
                valid &= _validate(create_info.initial_data != nil, len(create_info.initial_data) == create_info.mip_levels, location, "Initial data must be provided for all mip levels, or no mip levels.")
                valid &= _validate(create_info.mip_levels != 0, len(create_info.initial_data) == create_info.mip_levels, location)

                if !valid { 
                        return .Argument_Invalid
                }
        }

        return .Ok
}
