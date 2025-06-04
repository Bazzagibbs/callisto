package callisto

import sdl "vendor:sdl3"
import "core:os/os2"
import "core:path/filepath"
import "core:log"
import "config"
import "core:encoding/cbor"
import "core:strings"
import "core:math"
import "core:slice"
import "core:encoding/uuid"


// A path relative to the Asset library (<app_exe_dir>/data)
Asset_Path :: distinct string


// Asset_Database_Entry :: struct {
//         address  : string,
//         uuid     : uuid.Identifier,
//         refcount : int,
//         type     : Asset_Type,
// }
//
// Asset_Database :: struct {
//         entries    : [dynamic]Asset_Database_Entry,
//         by_uuid    : map[uuid.Identifier]int,
//         by_address : map[string]int,
// }


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
        Mesh,
        Texture,
}

Asset_Header :: struct {
        uuid    : uuid.Identifier,
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
asset_load_shader :: proc(r: ^Resource_Uploader, path: Asset_Path, temp_allocator := context.temp_allocator, location := #caller_location) -> (shader: Shader, ok: bool) {
        f := asset_path_open(path, .Shader, location = location) or_return
        defer os2.close(f)

        asset: Asset_Shader
        reader := os2.to_reader(f)
        err := cbor.unmarshal_from_reader(reader, &asset, allocator = temp_allocator, temp_allocator = temp_allocator, loc = location)
        if err != nil {
                log.error("Failed to unmarshal shader asset:", path, "-", err, location = location)
                return {}, false
        }

        // Clean up buffer allocations from cbor
        defer {
                delete(asset.entrypoint, temp_allocator)
                delete(asset.code, temp_allocator)
                // delete(asset.uniform_layout, temp_allocator)
        }

        return shader_create(r.device, &asset, temp_allocator)
}


Submesh_Flags :: bit_set[Submesh_Flag]
Submesh_Flag :: enum {
        U32_Indices, // Reinterpret the index buffer as a []u32 with half the length.
        // Separate_Shadow_Indices, // The mesh has been exported with a separate index list for depth-only draws. Otherwise use the regular list.
}


Submesh_Info :: struct {
        flags              : Submesh_Flags,
        material_slot_name : string,
        index_data         : []u16,
        index_shadow_data  : []u16,
        position_data      : [][3]f32,
        normal_data        : [][3]f32, // FIXME(opt): Octahedral compression
        tangent_data       : [][3]f32, // FIXME(opt): Octahedral compression
        tex_coord_0_data   : [][2]f32, // FIXME(opt): quantized?
        color_0_data       : [][4]u8,
        // skinning data
}

Asset_Mesh :: struct {
        using header : Asset_Header,
        submesh_infos : []Submesh_Info,
}


asset_load_mesh :: proc(r: ^Resource_Uploader, path: Asset_Path, allocator := context.allocator, temp_allocator := context.temp_allocator, location := #caller_location) -> (mesh: Mesh, ok: bool) {
        f := asset_path_open(path, .Mesh, location = location) or_return
        defer os2.close(f)

        asset: Asset_Mesh
        reader := os2.to_reader(f)
        err := cbor.unmarshal_from_reader(reader, &asset, allocator = temp_allocator, temp_allocator = temp_allocator, loc = location)
        if err != nil {
                log.error("Failed to unmarshal mesh asset:", path, "-", err, location = location)
                return {}, false
        }

        // Clean up buffer allocations from cbor
        defer {
                for info in asset.submesh_infos {
                        delete(info.material_slot_name, temp_allocator)
                        delete(info.index_data, temp_allocator)
                        delete(info.position_data, temp_allocator)
                        delete(info.normal_data, temp_allocator)
                        delete(info.tangent_data, temp_allocator)
                        delete(info.tex_coord_0_data, temp_allocator)
                        delete(info.color_0_data, temp_allocator)
                }
                delete(asset.submesh_infos, temp_allocator)
        }
        
        if len(asset.submesh_infos) > config.MAX_SUBMESHES {
                log.error("Mesh asset has more submeshes than allowed by MAX_SUBMESHES - limit:", config.MAX_SUBMESHES, "asset:", len(asset.submesh_infos), location = location)
                return {}, false
        }

        return mesh_create(r, &asset, allocator)
        
}


Asset_Texture :: struct {
        using header : Asset_Header,
        data_usage   : Texture_Data_Usage,
        compression  : Texture_Compression,
        format       : sdl.GPUTextureFormat,
        width        : u32,
        height       : u32,
        data_mips    : [][]u8, // []u8 per mip level
}

asset_load_texture :: proc(r: ^Resource_Uploader, path: Asset_Path, temp_allocator := context.temp_allocator, location := #caller_location) -> (texture: Texture, ok: bool) {
        f := asset_path_open(path, .Texture, location = location) or_return
        defer os2.close(f)

        asset: Asset_Texture
        reader := os2.to_reader(f)
        err := cbor.unmarshal_from_reader(reader, &asset, allocator = temp_allocator, temp_allocator = temp_allocator, loc = location)
        if err != nil {
                log.error("Failed to unmarshal shader asset:", path, "-", err, location = location)
                return {}, false
        }

        // Clean up buffer allocations from cbor
        defer {
                for mip in asset.data_mips {
                        delete(mip, temp_allocator)
                }
                delete(asset.data_mips, temp_allocator)
        }

        return texture_create(r, &asset, temp_allocator)
}


// Asset_Material :: struct {
//         using header               : Asset_Header,
//         vertex_input               : Vertex_Attribute_Slots,
//         shader_vertex              : Asset_Shader,
//         shader_fragment            : Asset_Shader,
//         textures_vertex            : []Asset_Texture,
//         textures_fragment          : []Asset_Texture,
//         // property_block_vertex   : []u8,
//         // property_block_fragment : []u8,
// }





// Optimised decompression of octahedral-compressed normal vectors.
// Implement this in shader code.
// optimisation by Rune Stubbe

// https://www.shadertoy.com/view/Mtfyzl
// oct_decode :: proc(compressed: [2]f32) -> [3]f32 {
//         n := [3]f32{compressed.x, compressed.y, 1 - math.abs(compressed.x) - math.abs(compressed.y)}
//         t := math.max(-n.z, 0)
//         n.xy += n.xy >= 0.0 ? -t : t
//         return linalg.normalize(n)
// }
