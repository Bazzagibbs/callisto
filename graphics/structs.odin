package callisto_graphics

import cc "../common"

Built_In :: struct {
    texture_white           : Texture,
    texture_black           : Texture,
    texture_transparent     : Texture,
}

Handle                  :: cc.Handle

Buffer                  :: cc.Buffer
Texture                 :: cc.Texture
Mesh                    :: cc.Mesh
Shader                  :: cc.Shader
Material                :: cc.Material 
Model                   :: cc.Model
Render_Pass             :: cc.Render_Pass
Render_Target           :: cc.Render_Target

Texture_Description     :: cc.Texture_Description
Shader_Description      :: cc.Shader_Description
Material_Description    :: cc.Material_Description
Model_Description       :: cc.Model_Description
Render_Pass_Description :: cc.Render_Pass_Description

Render_Pass_Uniforms    :: cc.Render_Pass_Uniforms
Instance_Uniforms       :: cc.Instance_Uniforms
