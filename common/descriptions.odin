package callisto_common

Engine_Description :: struct {
    application_description : ^Application_Description,
    display_description     : ^Display_Description,
    renderer_description    : ^Renderer_Description,
    update_proc             : Update_Callback_Proc,
    tick_proc               : Tick_Callback_Proc,

    user_data               : rawptr,
}

Application_Description :: struct {
    name : string,
    company : string,
    version : Version,
}

Display_Description :: struct {
    vsync         : Display_Vsync_Flag,
    fullscreen    : Display_Fullscreen_Flag,
    window_extent : uvec2,
}

Display_Vsync_Flag :: enum {
    Off,
    Double_Buffer,
    Triple_Buffer,
}

Display_Fullscreen_Flag :: enum {
    Windowed,
    Borderless,
    Exclusive,
}


Renderer_Description :: struct {
    headless: bool,
}


Texture_Description :: struct {
    image_path  : string,
    color_space : Image_Color_Space,
}

Image_Color_Space :: enum {
    Srgb,
    Linear,
}


Shader_Description :: struct {
    stage : Shader_Stage_Flag,
    resource_sets : []Gpu_Resource_Set,
    program : []u8,
    // cull_mode                   : Shader_Description_Cull_Mode,
    // depth_test                  : bool,
    // depth_write                 : bool,
    // depth_compare_op            : Compare_Op,
}

Shader_Description_Cull_Mode :: enum {
    Back,
    Front,
    None,
}

Compare_Op :: enum {
    Never,
    Less,
    Equal,
    Less_Or_Equal,
    Greater,
    Not_Equal,
    Greater_Or_Equal,
    Always,
}


Material_Description :: struct {
    // shader
    // uniform values (textures, colors, values)
}

Model_Description :: struct {
    model_path : string,
}

Render_Pass_Description :: struct {
    ubo_type          : typeid,
    render_target     : Render_Target,
    is_present_output : bool,
}

Gpu_Image_Description :: struct {
    format : Gpu_Image_Format,
    usage  : Gpu_Image_Usage_Flags,
    aspect : Gpu_Image_Aspect_Flags,
    access : Gpu_Access_Flag,
    filter : Gpu_Filter,
    extent : uvec3,
}

Gpu_Buffer_Description        :: struct {}
Gpu_Buffer_Upload_Description :: struct {}

