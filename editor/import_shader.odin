package callisto_editor

import "core:os/os2"
import "core:strings"
import "core:log"
import "core:path/filepath"
import "core:encoding/cbor"
import "core:slice"
import sdl "vendor:sdl3"
import sc "sdl3_shadercross"
import cal ".."
import "core:c"

Hlsl_User_Data :: struct {}


// TODO
// - Reflect input layout for vertex shaders
// - Reflect uniform/storage buffers
// - Reflect texture bindings
// - Reflect attachments?


shader_stage_from_filename :: proc(filename: string) -> (stage: sc.ShaderStage, entrypoint: cstring, ok: bool) {
        ext := filepath.long_ext(filename)

        switch ext {
        case ".vert.hlsl", ".vertex.hlsl":
                return .VERTEX, "main", true
        case ".frag.hlsl", ".fragment.hlsl":
                return .FRAGMENT, "main", true
        case ".comp.hlsl", ".compute.hlsl":
                return .COMPUTE, "main", true
        }

        return {}, "", false
}

shadercross_stage_to_sdl_stage :: proc(sc_stage: sc.ShaderStage) -> sdl.GPUShaderStage {
        switch sc_stage {
        case .VERTEX   : return .VERTEX
        case .FRAGMENT : return .FRAGMENT
        case .COMPUTE  : return {} // Compute should be handled separately
        }

        return {}
}


import_hlsl :: proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string, dst_dir_abs: string, user_data: rawptr) -> (ok: bool) {
        // Maybe we can change this to be a separate directory and import a module all at once?
        // Then expose all the entry points in the material editor

        // hlsl_data := (^Hlsl_User_Data)(user_data)

        // Output files
        os2.make_directory_all(dst_dir_abs)

        out_filename := strings.concatenate({filepath.stem(src_filename), ".cal"})
        defer delete(out_filename)
        dst_path_abs := filepath.join({dst_dir_abs, out_filename})
        defer delete(dst_path_abs)


        src_filename_cstr := strings.clone_to_cstring(src_filename)
        defer delete(src_filename_cstr)
        // src_fullpath_c := strings.clone_to_cstring(src_fullpath)
        // defer delete(src_fullpath_c)


        stage, entrypoint, ok_1 := shader_stage_from_filename(src_filename)
        if !ok_1 {
                log.error("Failed to determine shader type from filename:", src_filename)
                return false
        }


        src, err_file := read_entire_file_cstring(src_fullpath)
        if err_file != nil {
                log.error("Failed to read file data:", src_filename, "-", err_file)
                return false
        }
        defer delete(src)
        

        hlsl_info := sc.HLSL_Info {
                source       = src,
                entrypoint   = entrypoint,
                include_dir  = nil, // TODO
                defines      = nil,
                shader_stage = stage,
                // enable_debug = args.debug, // Needs vk 1.3 or VK_KHR_shader_non_semantic_info in runtime
                name         = src_filename_cstr,
                
                props        = 0,
        }

        kernel_size: c.size_t

        kernel := sc.CompileSPIRVFromHLSL(&hlsl_info, &kernel_size)
        if kernel == nil {
                log.error(sdl.GetError())
                return false
        }

        kernel_slice := ([^]u8)(kernel)[:kernel_size]
        defer sdl.free(kernel)

        meta: sc.GraphicsShaderMetadata
        ok_reflect := sc.ReflectGraphicsSPIRV(([^]u8)(kernel), kernel_size, &meta)
        if !ok_reflect {
                log.error("Failed to get reflection info for shader:", src_filename)
                return false
        }

        // TODO: do actual reflection on uniform/storage buffers

        asset_create_info := cal.Asset_Shader {
                type                 = .Shader,
                code                 = kernel_slice,
                entrypoint           = string(entrypoint),
                format               = {.SPIRV},
                stage                = shadercross_stage_to_sdl_stage(stage),
                num_samplers         = meta.num_samplers,
                num_storage_buffers  = meta.num_storage_buffers,
                num_storage_textures = meta.num_storage_textures,
                num_uniform_buffers  = meta.num_uniform_buffers,
                props                = meta.props,
        }

        
        out_file, err_dst := os2.open(dst_path_abs, {.Write, .Trunc, .Create})
        if err_dst != nil {
                log.error("Failed to open output file:", dst_path_abs, "-", err_dst)
                return false
        }
        defer os2.close(out_file)

        w := os2.to_writer(out_file)

        err_cbor := cbor.marshal_into_writer(w, asset_create_info, temp_allocator = context.temp_allocator)
        if err_cbor != nil {
                log.error("Failed to marshal shader asset:", dst_path_abs, "-", err_cbor)
                return false
        }

        return true
}


@(init)
register_importer_shader :: proc() {
        register_importer(".hlsl", import_hlsl, import_hlsl_init, import_hlsl_destroy)
}


import_hlsl_init :: proc(args: ^Args, user_data: ^rawptr) {
        ok := sc.Init()
        if !ok {
                log.error("Failed to init shadercross")
        }
}
import_hlsl_destroy :: proc(args: ^Args, user_data: rawptr) {
        sc.Quit()
}
