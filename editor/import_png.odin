package callisto_editor

import "core:os/os2"
import "core:strings"
import "core:log"
import "core:image"
import "core:image/png"
import "core:encoding/cbor"
import "core:path/filepath"
import sdl "vendor:sdl3"
import cal ".."

@(init)
register_importer_png :: proc() {
        // May later require further processing
        // - compression
        // - normal map format
        // - sprite sheets from image
        // - image to atlas
        register_importer(".png", import_png)
}


import_png :: proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string, dst_dir_abs: string, user_data: rawptr) -> (ok: bool) {
        os2.make_directory_all(dst_dir_abs)

        out_filename := strings.concatenate({filepath.stem(src_filename), ".cal"})
        defer delete(out_filename)
        dst_path_abs := filepath.join({dst_dir_abs, out_filename})
        defer delete(dst_path_abs)

        data, err := os2.read_entire_file_from_path(src_fullpath, context.allocator)
        if err != nil {
                log.error("Failed to load file:", src_filename, "-", err)
                return false
        }
        defer delete(data)

        img_info, err1 := image.load_from_bytes(data, {.info})
        if err1 != nil {
                log.error("Failed to get image info:", src_filename, "-", err)
                return false
        }
        defer image.destroy(img_info)

        // Convert pixel depth + channel count -> sdl format
        format := image_info_to_format(img_info) or_return
        
        texture := cal.Asset_Texture {
                type        = .Texture,
                uuid        = {}, // TODO: from metadata
                data_usage  = .Color,  // TODO: from metadata
                compression = .Png,
                format      = format,
                width       = u32(img_info.width),
                height      = u32(img_info.height),
                mip_levels  = 1, // TODO: generate mips
                data        = data,
        }

        return marshal_asset_into_file(dst_path_abs, texture)
}


image_info_to_format :: proc(info: ^image.Image) -> (format: sdl.GPUTextureFormat, ok: bool) {
        png_info := info.metadata.(^image.PNG_Info)

        switch info.depth {
        case 8:
                switch info.channels {
                case 1: return .R8_UNORM, true
                case 2: return .R8G8_UNORM, true
                case 3: return .R8G8B8A8_UNORM, true // use alpha_add_if_missing in decoder
                case 4: return .R8G8B8A8_UNORM, true 
                }
        }

        log.errorf("Unhandled image configuration: %#v", info)
        return .INVALID, false
}
