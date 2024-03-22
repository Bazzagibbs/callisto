package callisto_graphics

import cc "../common"

render_pass_description_forward :: proc() -> cc.Render_Pass_Description {
    return cc.Render_Pass_Description {
        ubo_type            = typeid_of(cc.Render_Pass_Uniforms),
        is_present_output   = true,
    }
}
