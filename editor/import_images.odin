package callisto_editor

import "base:runtime"
import "core:image"
import "core:image/qoi"
import "core:math"
import "core:bytes"
import "core:slice"
import "core:log"
import "core:mem"
import "core:c/libc"
import sdl "vendor:sdl3"
import cmp "compressonator"
import cal ".."

// FIXME: Used in compressonator progress callbacks. Find out how to pass user data to them.
global_context: runtime.Context


Import_Data_Image :: struct {
        using _             : Import_Data_Header,
        data_usage          : cal.Texture_Data_Usage,
        create_mips         : bool,
        compression         : cal.Texture_Compression,
        // invert_normal_green : bool, // Only show when data_usage == .Normal
}

IMPORT_DATA_IMAGE_DEFAULT := Import_Data_Image {
        data_usage          = .Color,
        create_mips         = true,
        compression         = .QOI, // TODO: Change to BC7 on full builds
}


import_images_init :: proc(args: ^Args, user_data: ^rawptr) {
        global_context = context

        cmp.InitFramework()

        err_bclib := cmp.InitializeBCLibrary()
        if err_bclib != .NONE {
                log.error("Failed to load Compressonator BCLibrary:", err_bclib)
                return
        }
}

import_images_destroy :: proc(args: ^Args, user_data: rawptr) {
        cmp.ShutdownBCLibrary()
}



image_compression_feedback :: proc "c" (progress: f32, pUser1, pUser2: cmp.DWord_Ptr) -> (abort: bool) {
        context = global_context

        log.debugf("Image compression: %v%%", progress)
        return false
}


image_get_cmp_channel_format :: proc(img: ^image.Image) -> (format: cmp.Channel_Format, ok: bool) {
        if img.channels != 4 {
                log.error("Image must be imported with alpha channel. Channel count:", img.channels)
                return {}, false
        }

        switch img.depth {
        case 8:  return ._8bit, true
        case 16: return ._16bit, true
        case 32: return ._32bit, true
        }

        log.error("Unknown image channel format with depth:", img.depth)
        return {}, false
}

// mip must be freed with `cmp.FreeMipSet()`
image_to_mip_0 :: proc(img: ^image.Image) -> (mip: cmp.Mip_Set, ok: bool) {
        channel_format := image_get_cmp_channel_format(img) or_return
        mip = _cmp_allocate_mip_set(channel_format, .ARGB, ._2D, i32(img.width), i32(img.height), 1) or_return
        defer if !ok {
                cmp.FreeMipSet(&mip)
        }

        mip.m_nMipLevels = 1


        level: ^cmp.Mip_Level
        cmp.GetMipLevel(&level, &mip, 0, 0)
        _cmp_allocate_mip_level_data(level, i32(img.width), i32(img.height), channel_format, .ARGB) or_return

        pixels := bytes.buffer_to_bytes(&img.pixels)
        mem.copy(level.m_pbData, raw_data(pixels), len(pixels))

        // Assign mip level 0 to the set's pData ref
        mip.pData = level.m_pbData
        mip.dwDataSize = u32(len(pixels))

        ok = true
        return
}


_cmp_get_max_mip_levels :: proc(width, height, depth: i32) -> i32 {
        max_dimension := max(width, height, depth)
        // Max mip including original is log2 + 1. If not a power of 2, round down.
        extra_mips := i32(math.floor(math.log2(f32(max_dimension)))) + 1
        return extra_mips
}


_cmp_allocate_mip_set :: proc(channel_format: cmp.Channel_Format, texture_data_type: cmp.Texture_Data_Type, texture_type: cmp.Texture_Type, width, height, depth: i32) -> (mip: cmp.Mip_Set, ok: bool)  {
        if width <= 0 || height <= 0 || depth <= 0 {
                log.error("Invalid image dimensions:", width, height, depth)
                return {}, false
        }

        mip.m_nMaxMipLevels = _cmp_get_max_mip_levels(width, height, depth if texture_type == .VolumeTexture else 1) 
        mip.m_ChannelFormat = channel_format
        mip.m_TextureDataType = texture_data_type
        mip.m_TextureType = texture_type
        mip.m_nWidth = width
        mip.m_nHeight = height
        mip.m_nDepth = depth

        table, levels_to_alloc := _cmp_allocate_mip_level_table(mip.m_nMaxMipLevels, texture_type, depth) or_return
        mip.m_pMipLevelTable = table
        defer if !ok {
                libc.free(mip.m_pMipLevelTable)
                mip.m_pMipLevelTable = nil
        }

        _cmp_allocate_all_mip_levels(mip.m_pMipLevelTable, texture_type, levels_to_alloc) or_return

        ok = true
        return
}


// These are not exposed by the C api :(
_cmp_allocate_mip_level_table :: proc(max_levels: i32, texture_type: cmp.Texture_Type, depth: i32) -> (table: cmp.Mip_Level_Table, levels_to_allocate: i32, ok: bool) {
        #partial switch texture_type {
        case ._1D, ._2D:
                levels_to_allocate = max_levels
                if depth != 1 {
                        ok = false
                        return
                }
        case .CubeMap:
                if depth < 6 {
                        ok = false
                        return
                }
                levels_to_allocate = max_levels * depth
        case .VolumeTexture:
                temp_depth := depth
                for i in 0..<max_levels {
                        levels_to_allocate += temp_depth
                        if temp_depth > 1 {
                                temp_depth >>= 1
                        }
                }
        case:
                ok = false
                return
        }

        // libc so it can be freed by compressonator
        table = (cmp.Mip_Level_Table)(libc.calloc(uint(levels_to_allocate), size_of(^cmp.Mip_Level)))

        ok = table != nil
        return 
}

_cmp_allocate_all_mip_levels :: proc(table: cmp.Mip_Level_Table, texture_type: cmp.Texture_Type, levels_to_allocate: i32) -> (ok: bool) {
        defer if !ok {
                for i in 0..<levels_to_allocate {
                        if table[i] != nil {
                                libc.free(table[i])
                                table[i] = nil
                        }
                }
        }

        for i in 0..<levels_to_allocate {
                table[i] = (^cmp.Mip_Level)(libc.calloc(1, size_of(cmp.Mip_Level)))
                if table[i] == nil {
                        return false
                }
        }

        return true
}

_cmp_allocate_mip_level_data :: proc(level: ^cmp.Mip_Level, width, height: i32, channel_format: cmp.Channel_Format, texture_data_type: cmp.Texture_Data_Type) -> (ok: bool) {
        if level == nil || width <= 0 || height <= 0 {
                return false
        }

        bits_per_pixel: u32
        #partial switch channel_format {
        case ._8bit, ._2101010, ._1010102, .Float9995E:
                bits_per_pixel = 8
        case ._16bit, .Float16:
                bits_per_pixel = 16
        case ._32bit, .Float32:
                bits_per_pixel = 32
        case:
                return false
        }

        #partial switch texture_data_type {
        case .XRGB, .ARGB, .NORMAL_MAP:
                bits_per_pixel *= 4
        case .RGB:
                bits_per_pixel *= 3
        case .RG, ._16:
                bits_per_pixel *= 2
        case .R, ._8:
                break
        case:
                return false
        }

        pitch := _cmp_pad_byte(u32(width), bits_per_pixel)
        level.m_nWidth = width
        level.m_nHeight = height
        level.m_dwLinearSize = pitch * u32(height)
        level.m_pbData = (^byte)(libc.malloc(uint(level.m_dwLinearSize)))

        return level.m_pbData != nil
}

_cmp_pad_byte :: #force_inline proc(width, bits_per_pixel: u32) -> u32 {
        return (bits_per_pixel * width + 7) / 8
}


_cmp_mips_to_slices :: proc(mip_set: ^cmp.Mip_Set, convert_to_qoi: bool, allocator := context.allocator) -> (mip_data_slices: [][]u8, should_free_levels: bool, ok: bool) {
        context.allocator = allocator


        should_free_levels = convert_to_qoi
        mip_data_slices = make([][]u8, int(mip_set.m_nMipLevels))

        defer if !ok {
                if convert_to_qoi {
                        for i in 0..<len(mip_data_slices) {
                                if mip_data_slices[i] != nil {
                                        delete(mip_data_slices[i])
                                }
                        }
                }

                delete(mip_data_slices)
        }


        if convert_to_qoi {
                // Mip levels need to be compressed to QOI format before serialization
                b := &bytes.Buffer{}
                defer bytes.buffer_destroy(b)

                for i in 0..<mip_set.m_nMipLevels {
                        level: ^cmp.Mip_Level
                        cmp.GetMipLevel(&level, mip_set, i, 0)
                        mip_pixels_raw := level.m_pbData[:level.m_dwLinearSize]
                        mip_pixels := slice.reinterpret([][4]u8, mip_pixels_raw)

                        mip_image, img_ok := image.pixels_to_image(mip_pixels, int(level.m_nWidth), int(level.m_nHeight))
                        if img_ok == false {
                                log.error("Failed to create image from mip level", i)
                                ok = false
                                return
                        }


                        bytes.buffer_reset(b)
                        qoi.save_to_buffer(b, &mip_image, {})
                        mip_data_slices[i] = bytes.clone(bytes.buffer_to_bytes(b))
                }

        } else {
                // Mip levels are already compressed, simply serialize them directly from the mip level
                for i in 0..<mip_set.m_nMipLevels {
                        level: ^cmp.Mip_Level
                        cmp.GetMipLevel(&level, mip_set, i, 0)
                        mip_data_slices[i] = level.m_pbData[:level.m_dwLinearSize]
                }
        }

        ok = true
        return
}

_cmp_mip_slices_destroy :: proc(mip_data_slices: [][]u8, should_free_levels: bool, allocator := context.allocator) {
        context.allocator = allocator

        if should_free_levels {
                for i in 0..<len(mip_data_slices) {
                        if mip_data_slices[i] != nil {
                                delete(mip_data_slices[i])
                        }
                }
        }

        delete(mip_data_slices)
}

_compression_to_cmp_format :: proc(compression: cal.Texture_Compression) -> (cmp_format: cmp.Format) {
        switch compression {
        case .QOI:  return .RGBA_8888
        case .BC6H: return .BC6H
        case .BC7:  return .BC7
        }
        return .Unknown
}

_compression_to_sdl_format :: proc(compression: cal.Texture_Compression, usage: cal.Texture_Data_Usage) -> (sdl_format: sdl.GPUTextureFormat) {
        switch compression {
        // case .QOI:  return .R8G8B8A8_UNORM_SRGB if usage == .Color else .R8G8B8A8_UNORM
        // case .BC6H: return .BC6H_RGB_UFLOAT
        // case .BC7:  return .BC7_RGBA_UNORM_SRGB if usage == .Color else .BC7_RGBA_UNORM
        case .QOI:  return .R8G8B8A8_UNORM
        case .BC6H: return .BC6H_RGB_UFLOAT
        case .BC7:  return .BC7_RGBA_UNORM
        }
        return .INVALID
}
