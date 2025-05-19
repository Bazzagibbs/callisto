package callisto

import sdl "vendor:sdl3"
import "core:os/os2"
import "core:path/filepath"
import "core:log"
import "config"
import "core:encoding/cbor"
import "core:strings"

// A path relative to the Asset library (<app_exe_dir>/data)
Asset_Path :: distinct string


// If ok, call `os2.close()` when done with file.
asset_path_open :: proc(asset_path: Asset_Path, type: Asset_Type = .Any, temp_allocator := context.temp_allocator, location := #caller_location) -> (file: ^os2.File, ok: bool) {
        base_path := string(sdl.GetBasePath())
        full_path := filepath.join({base_path, "data", string(asset_path)}, temp_allocator)
        defer delete(full_path, temp_allocator)

        f, err := os2.open(full_path)
        if err != nil {
                log.error("Could not open asset:", asset_path, "-", err, location = location)
                return nil, false
        }

        when !config.NO_ASSET_TYPE_CHECK {
        // Read the header and assert the asset type
                if type != .Any {
                        r := os2.to_reader(f)
                        asset: Asset_Unknown
                        err := cbor.unmarshal_from_reader(r, &asset)
                        if err != nil {
                                log.error("Failed to unmarshal asset header:", asset_path, "-", err, location = location)
                                os2.close(f)
                                return nil, false
                        }
                        
                        log.debug(asset.header)

                        if asset.type != type {
                                log.error("Asset type is incorrect:", asset_path, "- Expected", type, "but is", asset.type, location = location)
                                os2.close(f)
                                return nil, false
                        }

                        // Rewind the file and return it
                        os2.seek(f, 0, .Start)
                }
        }

        return f, true
}



Asset_Type :: enum u32 {
        Any = 0,
        Shader,
}

Asset_Header :: struct {
        type    : Asset_Type,
        // version : u32,
        // hash? : u64,
}

// Used to query asset type without loading the entire file
Asset_Unknown :: struct {
        using header : Asset_Header,
}



Asset_Shader :: struct {
        // sdl.GPUShaderCreateInfo with slices/strings
        using header         : Asset_Header,
        code                 : []u8 `fmt:"-"`,
        entrypoint           : string,
        format               : sdl.GPUShaderFormat,
        stage                : sdl.GPUShaderStage,
        num_samplers         : u32,
        num_storage_textures : u32,
        num_storage_buffers  : u32,
        num_uniform_buffers  : u32,

        props                : sdl.PropertiesID,

        // Dictionary of uniforms/textures to be assigned in material
        // uniform_layout : map[string]Shader_Uniform,
}



// Delete is called on temp allocations, so regular allocators are safe to use
asset_load_shader :: proc(device: ^sdl.GPUDevice, path: Asset_Path, temp_allocator := context.temp_allocator, location := #caller_location) -> (shader: ^sdl.GPUShader, ok: bool) {

        f := asset_path_open(path, .Shader, location = location) or_return
        defer os2.close(f)

        asset: Asset_Shader
        reader := os2.to_reader(f)
        err := cbor.unmarshal_from_reader(reader, &asset, allocator = temp_allocator, temp_allocator = temp_allocator, loc = location)
        if err != nil {
                log.error("Failed to unmarshal shader asset:", path, "-", err, location = location)
                return nil, false
        }

        // Clean up buffer allocations from cbor
        defer {
                delete(asset.entrypoint, temp_allocator)
                delete(asset.code, temp_allocator)
                // delete(asset.uniform_layout, temp_allocator)
        }

        // entrypoint_c := strings.clone_to_cstring(asset.entrypoint, temp_allocator)
        // defer delete(entrypoint_c, temp_allocator)
        entrypoint_c : cstring = "main"


        // Translate to SDL create info
        create_info := sdl.GPUShaderCreateInfo {
                code_size            = uint(len(asset.code)),
                code                 = raw_data(asset.code),
                entrypoint           = entrypoint_c,
                format               = asset.format,
                stage                = asset.stage,
                num_samplers         = asset.num_samplers,
                num_storage_textures = asset.num_storage_textures,
                num_storage_buffers  = asset.num_storage_buffers,
                num_uniform_buffers  = asset.num_uniform_buffers,

                props                = asset.props,
        }

        return sdl.CreateGPUShader(device, create_info), true
}

