#+ private
package callisto_gpu

import dx "vendor:directx/d3d11"
import "vendor:directx/dxgi"

// when RHI_BACKEND == "d3d11" {

_Format_To_Dx11 := [Texture_Format_Flag]dxgi.FORMAT {
        .Unknown              = .UNKNOWN,

        // 128-bit
        .R32G32B32A32_UNTYPED = .R32G32B32A32_TYPELESS,
        .R32G32B32A32_FLOAT   = .R32G32B32A32_FLOAT,
        .R32G32B32A32_UINT    = .R32G32B32A32_UINT,
        .R32G32B32A32_SINT    = .R32G32B32A32_SINT,
        
        // 96-bit
        .R32G32B32_UNTYPED    = .R32G32B32_TYPELESS,
        .R32G32B32_FLOAT      = .R32G32B32_FLOAT,
        .R32G32B32_UINT       = .R32G32B32_UINT,
        .R32G32B32_SINT       = .R32G32B32_SINT,

        // 64-bit
        .R16G16B16A16_UNTYPED = .R16G16B16A16_TYPELESS,
        .R16G16B16A16_FLOAT   = .R16G16B16A16_FLOAT,
        .R16G16B16A16_UNORM   = .R16G16B16A16_UNORM,
        .R16G16B16A16_UINT    = .R16G16B16A16_UINT,
        .R16G16B16A16_SNORM   = .R16G16B16A16_SNORM,
        .R16G16B16A16_SINT    = .R16G16B16A16_SINT,

        .R32G32_UNTYPED       = .R32G32_TYPELESS,
        .R32G32_FLOAT         = .R32G32_FLOAT,
        .R32G32_UINT          = .R32G32_UINT,
        .R32G32_SINT          = .R32G32_SINT,

        // 64-bit depth/stencil
        .D32_FLOAT_S8X24_UINT = .D32_FLOAT_S8X24_UINT, // X24 is unused
        
        // 32-bit
        .R8G8B8A8_UNTYPED     = .R8G8B8A8_TYPELESS,
        .R8G8B8A8_UNORM       = .R8G8B8A8_UNORM,
        .R8G8B8A8_UINT        = .R8G8B8A8_UINT,
        .R8G8B8A8_SNORM       = .R8G8B8A8_SNORM,
        .R8G8B8A8_SINT        = .R8G8B8A8_SINT,
        .R8G8B8A8_UNORM_SRGB  = .R8G8B8A8_UNORM_SRGB,

        .R10G10B10A2_UNTYPED  = .R10G10B10A2_TYPELESS,
        .R10G10B10A2_UNORM    = .R10G10B10A2_UNORM,
        .R10G10B10A2_UINT     = .R10G10B10A2_UINT,
        .R11G11B10_FLOAT      = .R11G11B10_FLOAT,

        .R16G16_UNTYPED       = .R16G16_TYPELESS,
        .R16G16_FLOAT         = .R16G16_FLOAT,
        .R16G16_UNORM         = .R16G16_UNORM,
        .R16G16_UINT          = .R16G16_UINT,
        .R16G16_SNORM         = .R16G16_SNORM,
        .R16G16_SINT          = .R16G16_SINT,

        .R32_UNTYPED          = .R32_TYPELESS,
        .R32_FLOAT            = .R32_FLOAT,
        .R32_UINT             = .R32_UINT,
        .R32_SINT             = .R32_SINT,
        
        .B8G8R8A8_UNTYPED     = .B8G8R8A8_TYPELESS,
        .B8G8R8A8_UNORM       = .B8G8R8A8_UNORM,
        .B8G8R8A8_UNORM_SRGB  = .B8G8R8A8_UNORM_SRGB,

        // 32-bit depth/stencil
        .D32_FLOAT            = .D32_FLOAT,
        .D24_UNORM_S8_UINT    = .D24_UNORM_S8_UINT,

        // 16-bit
        .R8G8_UNTYPED         = .R8G8_TYPELESS,
        .R8G8_UNORM           = .R8G8_UNORM,
        .R8G8_UINT            = .R8G8_UINT,
        .R8G8_SNORM           = .R8G8_SNORM,
        .R8G8_SINT            = .R8G8_SINT,

        .R16_UNTYPED          = .R16_TYPELESS,
        .R16_FLOAT            = .R16_FLOAT,
        .R16_UNORM            = .R16_UNORM,
        .R16_UINT             = .R16_UINT,
        .R16_SNORM            = .R16_SNORM,
        .R16_SINT             = .R16_SINT,
       
        .B4G4R4A4_UNORM       = .B4G4R4A4_UNORM,
        .B5G5R5A1_UNORM       = .B5G5R5A1_UNORM,
        .B5G6R5_UNORM         = .B5G6R5_UNORM,

        // 16-bit depth/stencil
        .D16_UNORM            = .D16_UNORM,

        // 8-bit
        .R8_UNTYPED           = .R8_TYPELESS,
        .R8_UNORM             = .R8_UNORM,
        .R8_UINT              = .R8_UINT,
        .R8_SNORM             = .R8_SNORM,
        .R8_SINT              = .R8_SINT,

        .A8_UNORM             = .A8_UNORM,

        // 1-bit
        .R1_UNORM             = .R1_UNORM,

        // Block compressed
        .BC1_UNTYPED          = .BC1_TYPELESS,
        .BC1_UNORM            = .BC1_UNORM,
        .BC1_UNORM_SRGB       = .BC1_UNORM_SRGB,
        .BC2_UNTYPED          = .BC2_TYPELESS,
        .BC2_UNORM            = .BC2_UNORM,
        .BC2_UNORM_SRGB       = .BC2_UNORM_SRGB,
        .BC3_UNTYPED          = .BC3_TYPELESS,
        .BC3_UNORM            = .BC3_UNORM,
        .BC3_UNORM_SRGB       = .BC3_UNORM_SRGB,
        .BC4_UNTYPED          = .BC4_TYPELESS,
        .BC4_UNORM            = .BC4_UNORM,
        .BC4_SNORM            = .BC4_SNORM,
        .BC5_UNTYPED          = .BC5_TYPELESS,
        .BC5_UNORM            = .BC5_UNORM,
        .BC5_SNORM            = .BC5_SNORM,
        .BC6H_UNTYPED         = .BC6H_TYPELESS,
        .BC6H_UFLOAT          = .BC6H_UF16,
        .BC6H_SFLOAT          = .BC6H_SF16,
        .BC7_UNTYPED          = .BC7_TYPELESS,
        .BC7_UNORM            = .BC7_UNORM,
        .BC7_UNORM_SRGB       = .BC7_UNORM_SRGB,
}

_multisample_to_dx11 := #force_inline proc(flag: Multisample_Flag) -> u32 {
        return 1 << u32(flag)
}


// use *_flags proc instead!
_Texture_Usage_To_Dx11 := [Texture_Usage_Flag]dx.BIND_FLAG {
        .Render_Target        = .RENDER_TARGET,
        .Depth_Stencil_Target = .DEPTH_STENCIL,
        .Unordered_Access     = .UNORDERED_ACCESS,
        .Shader_Resource      = .SHADER_RESOURCE,
        // .Decoder           = .DECODER, // FEATURE(Video)
        // .Encoder           = .VIDEO_ENCODER,
}

_texture_usage_flags_to_dx11 :: proc(usage_flags: Texture_Usage_Flags) -> dx.BIND_FLAGS {
        bind_flags := dx.BIND_FLAGS {}

        for flag in usage_flags {
                bind_flags += {_Texture_Usage_To_Dx11[flag]}
        }

        return bind_flags
}


_Usage_Access_Pair :: struct {
        usage  : dx.USAGE,
        access : dx.CPU_ACCESS_FLAGS,
}

_Resource_Access_To_Dx11 := [Resource_Access_Flag]_Usage_Access_Pair {
        .Device_General   = { .DEFAULT, {} },
        .Device_Immutable = { .IMMUTABLE, {} },
        .Host_To_Device   = { .DYNAMIC, {.WRITE} },
        .Device_To_Host   = { .STAGING, {.READ} },
}

// use *_flags proc instead!
_Buffer_Usage_To_Dx11 := [Buffer_Usage_Flag]dx.BIND_FLAG {
        .Vertex           = .VERTEX_BUFFER,
        .Index            = .INDEX_BUFFER,
        .Constant         = .CONSTANT_BUFFER,
        .Shader_Resource  = .SHADER_RESOURCE,
        .Unordered_Access = .UNORDERED_ACCESS,
}

_buffer_usage_flags_to_dx11 :: proc(usage_flags: Buffer_Usage_Flags) -> dx.BIND_FLAGS {
        bind_flags := dx.BIND_FLAGS {}

        for flag in usage_flags {
                bind_flags += {_Buffer_Usage_To_Dx11[flag]}
        }

        return bind_flags
}

_sampler_filter_to_dx11 :: proc(min_filter, mag_filter, mip_filter: Sampler_Filter_Flag, aniso: Sampler_Anisotropy_Flag) -> dx.FILTER {
        if aniso != .None {
                return .ANISOTROPIC
        }

        min_shift := i32(min_filter) << dx.MIN_FILTER_SHIFT
        mag_shift := i32(mag_filter) << dx.MAG_FILTER_SHIFT
        mip_shift := i32(mip_filter) << dx.MIP_FILTER_SHIFT

        return dx.FILTER(min_shift | mag_shift | mip_shift)
}


_Sampler_Address_Flag_To_Dx11 := [Sampler_Address_Flag]dx.TEXTURE_ADDRESS_MODE {
        .Wrap            = .WRAP,
        .Mirror          = .MIRROR,
        .Clamp           = .CLAMP,
        .Border          = .BORDER,
        .Mirror_Negative = .MIRROR_ONCE,
}

_sampler_aniso_to_dx11 :: proc(aniso: Sampler_Anisotropy_Flag) -> u32 {
        return 1 << u32(aniso)
}

_Sampler_Border_Color_Flag_To_Dx11 := [Sampler_Border_Color_Flag][4]f32 {
        .Black_Opaque      = {0, 0, 0, 1},
        .White_Opaque      = {1, 1, 1, 1},
        .Black_Transparent = {0, 0, 0, 0},
        .White_Transparent = {1, 1, 1, 0},
}

_Texture_Dimension_Flag :: enum {
        _1,
        _2,
        _3,
}

_texture_view_dimension_to_dx11 :: proc(dimension: _Texture_Dimension_Flag, is_ms, is_array, is_cube: bool) -> dx.SRV_DIMENSION {
        switch dimension {      
        case ._1: 
                return .TEXTURE1DARRAY if is_array else .TEXTURE1D

        case ._2: 
                if is_cube {
                        return .TEXTURECUBEARRAY if is_array else .TEXTURECUBE
                }
                if is_ms {
                        return .TEXTURE2DMSARRAY if is_array else .TEXTURE2DMS
                }

                return .TEXTURE2DARRAY if is_array else .TEXTURE2D

        case ._3: 
                return .TEXTURE3D

        }

        unreachable()
}

//} // when RHI_BACKEND == "d3d11"
