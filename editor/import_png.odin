package callisto_editor

import "core:os/os2"
import "core:strings"
import "core:log"
import "core:image"
import "core:image/png"
import "core:image/qoi"
import "core:image/bmp"
import "core:encoding/cbor"
import "core:path/filepath"
import "core:slice"
import cmp "compressonator"
import sdl "vendor:sdl3"
import cal ".."
import "core:fmt"

@(init)
register_importer_png :: proc() {
        // May later require further processing
        // - compression
        // - normal map format
        // - sprite sheets from image
        // - image to atlas
        register_importer(".png", import_png, import_images_init, import_images_destroy)
}


import_png :: proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string, dst_dir_abs: string, user_data: rawptr) -> (ok: bool) {
        generate_mips := true

        import_data, _ := import_data_open_or_create(src_fullpath, IMPORT_DATA_IMAGE_DEFAULT) or_return

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

        img, err1 := image.load_from_bytes(data, {.alpha_add_if_missing})
        if err1 != nil {
                log.error("Failed to load image:", src_filename, "-", err)
                return false
        }
        defer image.destroy(img)

        src_mip := image_to_mip_0(img) or_return
        defer cmp.FreeMipSet(&src_mip)


        // Mip map creation
        if import_data.create_mips {
                requested_levels := cmp.CalcMaxMipLevel(src_mip.m_nHeight, src_mip.m_nWidth, true)
                min_size         := cmp.CalcMinMipSize(src_mip.m_nHeight, src_mip.m_nWidth, requested_levels)
                // cmp.GenerateMIPLevels(&src_mip, min_size)

                mip_filter_params := cmp.CFilter_Parameters {
                        nFilterType         = 0, // CPU
                        dwMipFilterOptions  = 0,
                        nMinSize            = min_size,
                        fGammaCorrection    = 1, // no correction
                        fSharpness          = 0.77,
                        destWidth           = 0,
                        destHeight          = 0,
                        useSRGB             = false, // TODO: color spaces
                }
                cmp.GenerateMIPLevelsEx(&src_mip, &mip_filter_params)
        }

        mip_data: [][]u8
        should_free_levels: bool

        if import_data.compression == .QOI {
                mip_data, should_free_levels = _cmp_mips_to_slices(&src_mip, import_data.compression == .QOI) or_return
        } else {
                // Compression
                compressed_mip: cmp.Mip_Set
                kernel_opts := cmp.Kernel_Options {
                        encodeWith    = .CPU,
                        format        = _compression_to_cmp_format(import_data.compression),
                        srcformat     = src_mip.m_format,
                        fquality      = 0.9,
                        threads       = 0, // auto
                        useSRGBFrames = false, // TODO: color spaces
                }
                err_compress := cmp.ProcessTexture(&src_mip, &compressed_mip, kernel_opts, image_compression_feedback)
                check_ok(err_compress, "Failed to compress texture") or_return

                mip_data, should_free_levels = _cmp_mips_to_slices(&src_mip, import_data.compression == .QOI) or_return
        }
        defer _cmp_mip_slices_destroy(mip_data, should_free_levels)


        // Marshal asset
        texture := cal.Asset_Texture {
                type        = .Texture,
                uuid        = identifier_from_json(import_data.uuid),
                data_usage  = import_data.data_usage,
                compression = import_data.compression,
                format      = _compression_to_sdl_format(import_data.compression, import_data.data_usage),
                width       = u32(img.width),
                height      = u32(img.height),
                data_mips   = mip_data,
        }

        log.info(texture.format)

        return marshal_asset_into_file(dst_path_abs, texture)
}


