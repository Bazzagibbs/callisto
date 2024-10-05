package callisto_common

import "core:math/linalg"
import "core:time"



// Aliased types
Handle      :: distinct rawptr

uvec2     :: [2]u32
uvec3     :: [3]u32
uvec4     :: [4]u32
ivec2     :: [2]i32
ivec3     :: [3]i32
ivec4     :: [4]i32

vec2        :: [2]f32
vec3        :: [3]f32
vec4        :: [4]f32

mat2        :: matrix[2, 2]f32
mat3        :: matrix[3, 3]f32
mat4        :: matrix[4, 4]f32

MAT2_IDENTITY :: linalg.MATRIX2F32_IDENTITY
MAT3_IDENTITY :: linalg.MATRIX3F32_IDENTITY
MAT4_IDENTITY :: linalg.MATRIX4F32_IDENTITY

color32     :: [4]u8
quat        :: linalg.Quaternionf32


Result :: enum {
    Ok,
    Unknown,
    Out_Of_Memory,
    Initialization_Failed,
    Device_Lost,
    Feature_Not_Present,
    Format_Not_Supported,
    Device_Not_Supported,
    Invalid_Handle,
    Invalid_Asset,
    Invalid_Description,
}

Window :: distinct Handle
Renderer :: distinct Handle

Buffer          :: distinct Handle
Texture         :: distinct Handle
Mesh            :: distinct Handle
Shader          :: distinct Handle
Material        :: distinct Handle
Model           :: distinct Handle 
Render_Pass     :: distinct Handle
Render_Target   :: distinct Handle

Gpu_Image       :: distinct Handle
Gpu_Buffer      :: distinct Handle

// Structs
// ///////

Engine :: struct {
    window      : Window,
    renderer    : Renderer,
    input       : ^Input,
    update_proc : Update_Callback_Proc,
    tick_proc   : Tick_Callback_Proc,
    time        : Frame_Time,

    user_data   : rawptr,
}


Version :: struct {
    major : u32,
    minor : u32,
    patch : u32,
}


Frame_Time :: struct {
    stopwatch_epoch  : time.Stopwatch, // Since callisto.run()
    stopwatch_delta  : time.Stopwatch, // Reset every frame
    scale            : f32,

    delta            : f32,
    delta_unscaled   : f32,
    // delta_tick       : f32,
    maximum_delta    : f32,
}


Axis_Aligned_Bounding_Box :: struct {
    center     : vec3,
    extent     : vec3, // half of width/breadth/height
}


Transform :: struct {
    translation     : vec3,
    rotation        : quat,
    scale           : vec3,
}


// ///////////////////////////////////////////////////////////
Render_Pass_Uniforms :: struct {
    view:       mat4,
    proj:       mat4,
    viewproj:   mat4,
}

Instance_Uniforms :: struct {
    model:      mat4,
}

Update_Callback_Proc :: #type proc(ctx: ^Engine)
Tick_Callback_Proc   :: #type proc(ctx: ^Engine)

// ///////////////////////////////////////////////////////////
Gpu_Image_Format :: enum {
    // From the useful part of vk.Format
	UNDEFINED                                      = 0,
	R4G4_UNORM_PACK8                               = 1,
	R4G4B4A4_UNORM_PACK16                          = 2,
	B4G4R4A4_UNORM_PACK16                          = 3,
	R5G6B5_UNORM_PACK16                            = 4,
	B5G6R5_UNORM_PACK16                            = 5,
	R5G5B5A1_UNORM_PACK16                          = 6,
	B5G5R5A1_UNORM_PACK16                          = 7,
	A1R5G5B5_UNORM_PACK16                          = 8,
	R8_UNORM                                       = 9,
	R8_SNORM                                       = 10,
	R8_USCALED                                     = 11,
	R8_SSCALED                                     = 12,
	R8_UINT                                        = 13,
	R8_SINT                                        = 14,
	R8_SRGB                                        = 15,
	R8G8_UNORM                                     = 16,
	R8G8_SNORM                                     = 17,
	R8G8_USCALED                                   = 18,
	R8G8_SSCALED                                   = 19,
	R8G8_UINT                                      = 20,
	R8G8_SINT                                      = 21,
	R8G8_SRGB                                      = 22,
	R8G8B8_UNORM                                   = 23,
	R8G8B8_SNORM                                   = 24,
	R8G8B8_USCALED                                 = 25,
	R8G8B8_SSCALED                                 = 26,
	R8G8B8_UINT                                    = 27,
	R8G8B8_SINT                                    = 28,
	R8G8B8_SRGB                                    = 29,
	B8G8R8_UNORM                                   = 30,
	B8G8R8_SNORM                                   = 31,
	B8G8R8_USCALED                                 = 32,
	B8G8R8_SSCALED                                 = 33,
	B8G8R8_UINT                                    = 34,
	B8G8R8_SINT                                    = 35,
	B8G8R8_SRGB                                    = 36,
	R8G8B8A8_UNORM                                 = 37,
	R8G8B8A8_SNORM                                 = 38,
	R8G8B8A8_USCALED                               = 39,
	R8G8B8A8_SSCALED                               = 40,
	R8G8B8A8_UINT                                  = 41,
	R8G8B8A8_SINT                                  = 42,
	R8G8B8A8_SRGB                                  = 43,
	B8G8R8A8_UNORM                                 = 44,
	B8G8R8A8_SNORM                                 = 45,
	B8G8R8A8_USCALED                               = 46,
	B8G8R8A8_SSCALED                               = 47,
	B8G8R8A8_UINT                                  = 48,
	B8G8R8A8_SINT                                  = 49,
	B8G8R8A8_SRGB                                  = 50,
	A8B8G8R8_UNORM_PACK32                          = 51,
	A8B8G8R8_SNORM_PACK32                          = 52,
	A8B8G8R8_USCALED_PACK32                        = 53,
	A8B8G8R8_SSCALED_PACK32                        = 54,
	A8B8G8R8_UINT_PACK32                           = 55,
	A8B8G8R8_SINT_PACK32                           = 56,
	A8B8G8R8_SRGB_PACK32                           = 57,
	A2R10G10B10_UNORM_PACK32                       = 58,
	A2R10G10B10_SNORM_PACK32                       = 59,
	A2R10G10B10_USCALED_PACK32                     = 60,
	A2R10G10B10_SSCALED_PACK32                     = 61,
	A2R10G10B10_UINT_PACK32                        = 62,
	A2R10G10B10_SINT_PACK32                        = 63,
	A2B10G10R10_UNORM_PACK32                       = 64,
	A2B10G10R10_SNORM_PACK32                       = 65,
	A2B10G10R10_USCALED_PACK32                     = 66,
	A2B10G10R10_SSCALED_PACK32                     = 67,
	A2B10G10R10_UINT_PACK32                        = 68,
	A2B10G10R10_SINT_PACK32                        = 69,
	R16_UNORM                                      = 70,
	R16_SNORM                                      = 71,
	R16_USCALED                                    = 72,
	R16_SSCALED                                    = 73,
	R16_UINT                                       = 74,
	R16_SINT                                       = 75,
	R16_SFLOAT                                     = 76,
	R16G16_UNORM                                   = 77,
	R16G16_SNORM                                   = 78,
	R16G16_USCALED                                 = 79,
	R16G16_SSCALED                                 = 80,
	R16G16_UINT                                    = 81,
	R16G16_SINT                                    = 82,
	R16G16_SFLOAT                                  = 83,
	R16G16B16_UNORM                                = 84,
	R16G16B16_SNORM                                = 85,
	R16G16B16_USCALED                              = 86,
	R16G16B16_SSCALED                              = 87,
	R16G16B16_UINT                                 = 88,
	R16G16B16_SINT                                 = 89,
	R16G16B16_SFLOAT                               = 90,
	R16G16B16A16_UNORM                             = 91,
	R16G16B16A16_SNORM                             = 92,
	R16G16B16A16_USCALED                           = 93,
	R16G16B16A16_SSCALED                           = 94,
	R16G16B16A16_UINT                              = 95,
	R16G16B16A16_SINT                              = 96,
	R16G16B16A16_SFLOAT                            = 97,
	R32_UINT                                       = 98,
	R32_SINT                                       = 99,
	R32_SFLOAT                                     = 100,
	R32G32_UINT                                    = 101,
	R32G32_SINT                                    = 102,
	R32G32_SFLOAT                                  = 103,
	R32G32B32_UINT                                 = 104,
	R32G32B32_SINT                                 = 105,
	R32G32B32_SFLOAT                               = 106,
	R32G32B32A32_UINT                              = 107,
	R32G32B32A32_SINT                              = 108,
	R32G32B32A32_SFLOAT                            = 109,
	R64_UINT                                       = 110,
	R64_SINT                                       = 111,
	R64_SFLOAT                                     = 112,
	R64G64_UINT                                    = 113,
	R64G64_SINT                                    = 114,
	R64G64_SFLOAT                                  = 115,
	R64G64B64_UINT                                 = 116,
	R64G64B64_SINT                                 = 117,
	R64G64B64_SFLOAT                               = 118,
	R64G64B64A64_UINT                              = 119,
	R64G64B64A64_SINT                              = 120,
	R64G64B64A64_SFLOAT                            = 121,
	B10G11R11_UFLOAT_PACK32                        = 122,
	E5B9G9R9_UFLOAT_PACK32                         = 123,
	D16_UNORM                                      = 124,
	X8_D24_UNORM_PACK32                            = 125,
	D32_SFLOAT                                     = 126,
	S8_UINT                                        = 127,
	D16_UNORM_S8_UINT                              = 128,
	D24_UNORM_S8_UINT                              = 129,
	D32_SFLOAT_S8_UINT                             = 130,
	BC1_RGB_UNORM_BLOCK                            = 131,
	BC1_RGB_SRGB_BLOCK                             = 132,
	BC1_RGBA_UNORM_BLOCK                           = 133,
	BC1_RGBA_SRGB_BLOCK                            = 134,
	BC2_UNORM_BLOCK                                = 135,
	BC2_SRGB_BLOCK                                 = 136,
	BC3_UNORM_BLOCK                                = 137,
	BC3_SRGB_BLOCK                                 = 138,
	BC4_UNORM_BLOCK                                = 139,
	BC4_SNORM_BLOCK                                = 140,
	BC5_UNORM_BLOCK                                = 141,
	BC5_SNORM_BLOCK                                = 142,
	BC6H_UFLOAT_BLOCK                              = 143,
	BC6H_SFLOAT_BLOCK                              = 144,
	BC7_UNORM_BLOCK                                = 145,
	BC7_SRGB_BLOCK                                 = 146,
	ETC2_R8G8B8_UNORM_BLOCK                        = 147,
	ETC2_R8G8B8_SRGB_BLOCK                         = 148,
	ETC2_R8G8B8A1_UNORM_BLOCK                      = 149,
	ETC2_R8G8B8A1_SRGB_BLOCK                       = 150,
	ETC2_R8G8B8A8_UNORM_BLOCK                      = 151,
	ETC2_R8G8B8A8_SRGB_BLOCK                       = 152,
	EAC_R11_UNORM_BLOCK                            = 153,
	EAC_R11_SNORM_BLOCK                            = 154,
	EAC_R11G11_UNORM_BLOCK                         = 155,
	EAC_R11G11_SNORM_BLOCK                         = 156,
	ASTC_4x4_UNORM_BLOCK                           = 157,
	ASTC_4x4_SRGB_BLOCK                            = 158,
	ASTC_5x4_UNORM_BLOCK                           = 159,
	ASTC_5x4_SRGB_BLOCK                            = 160,
	ASTC_5x5_UNORM_BLOCK                           = 161,
	ASTC_5x5_SRGB_BLOCK                            = 162,
	ASTC_6x5_UNORM_BLOCK                           = 163,
	ASTC_6x5_SRGB_BLOCK                            = 164,
	ASTC_6x6_UNORM_BLOCK                           = 165,
	ASTC_6x6_SRGB_BLOCK                            = 166,
	ASTC_8x5_UNORM_BLOCK                           = 167,
	ASTC_8x5_SRGB_BLOCK                            = 168,
	ASTC_8x6_UNORM_BLOCK                           = 169,
	ASTC_8x6_SRGB_BLOCK                            = 170,
	ASTC_8x8_UNORM_BLOCK                           = 171,
	ASTC_8x8_SRGB_BLOCK                            = 172,
	ASTC_10x5_UNORM_BLOCK                          = 173,
	ASTC_10x5_SRGB_BLOCK                           = 174,
	ASTC_10x6_UNORM_BLOCK                          = 175,
	ASTC_10x6_SRGB_BLOCK                           = 176,
	ASTC_10x8_UNORM_BLOCK                          = 177,
	ASTC_10x8_SRGB_BLOCK                           = 178,
	ASTC_10x10_UNORM_BLOCK                         = 179,
	ASTC_10x10_SRGB_BLOCK                          = 180,
	ASTC_12x10_UNORM_BLOCK                         = 181,
	ASTC_12x10_SRGB_BLOCK                          = 182,
	ASTC_12x12_UNORM_BLOCK                         = 183,
	ASTC_12x12_SRGB_BLOCK                          = 184,
}

Gpu_Image_Usage_Flags :: bit_set[Gpu_Image_Usage_Flag]
Gpu_Image_Usage_Flag  :: enum {
    Transfer_Source,
    Transfer_Dest,
    Sampled,
    Storage,
    Color_Attachment,
    Depth_Stencil_Attachment,
    Transient_Attachment,
    Input_Attachment,
}


// Gpu_Shader_Description :: struct {
//     stage         : Shader_Stage_Flag,
//     resource_sets : []Gpu_Resource_Set,
//     program       : []u8,
// }

Shader_Stage_Flags :: bit_set[Shader_Stage_Flag]
Shader_Stage_Flag :: enum u32 {
    Vertex,
    Fragment,
    Compute,
    Tessellation_Control,
    Tessellation_Evaluation,
    Geometry,
    Ray_Generation,
    Ray_Intersection,
    Ray_Any_Hit,
    Ray_Closest_Hit,
    Ray_Miss,
    Ray_Callable,
}

Gpu_Resource_Set :: struct {
    bindings : []Gpu_Resource_Binding,
}

Gpu_Resource_Binding :: struct {
    binding       : u32,
    resource_type : Gpu_Resource_Type,
}

Gpu_Resource_Type :: enum {
    Storage_Image,
}

Gpu_Image_Aspect_Flags :: bit_set[Gpu_Image_Aspect_Flag]
Gpu_Image_Aspect_Flag :: enum {
    Color,
    Depth,
    Stencil,
    Plane,
    Metadata,
}

Gpu_Access_Flag :: enum {
    Gpu_Only,
    Cpu_To_Gpu,
    Gpu_To_Cpu,
}

Gpu_Filter :: enum {
    Linear,
    Nearest,
}
