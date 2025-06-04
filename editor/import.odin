package callisto_editor

import "base:runtime"
import "core:reflect"
import "core:path/filepath"
import "core:os/os2"
import "core:strings"
import "core:log"
import "core:encoding/cbor"
import "../common"
import "core:encoding/uuid"
import "core:encoding/json"
import "core:fmt"
import "base:intrinsics"
import cal ".."

importers : map[string]Importer

// NOTE: copy this, don't use it directly
JSON_MARSHAL_OPTS_DEFAULT := json.Marshal_Options {
        spec                      = .SJSON,
        pretty                    = true,
        write_uint_as_hex         = true,
        mjson_keys_use_quotes     = true,
        mjson_keys_use_equal_sign = true,
        sort_maps_by_key          = true,
        use_enum_names            = true,
}

Importer :: struct {
        importer_proc    : Importer_Proc,
        init_proc        : Importer_Init_Proc,     // Optional
        destroy_proc     : Importer_Destroy_Proc,  // Optional
        user_data        : rawptr,
}


// src_filename : "player.png"
// dir_rel      : "sprites\\characters\\"
// src_fullpath : "C:\\projects\\game\\res\\sprites\\characters\\player.png"
// dst_dir_abs  : "C:\\projects\\game\\imported\\sprites\\characters\\"
Importer_Proc :: #type proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string,  dst_dir_abs: string, user_data: rawptr = nil) -> (ok: bool)

Importer_Init_Proc :: #type proc(args: ^Args, user_data: ^rawptr)

Importer_Destroy_Proc :: #type proc(args: ^Args, user_data: rawptr)


// Used to serialize nicely in JSON files, however CBOR can't serialize u128. Convert back to uuid.Identifier for asset use.
Identifier_JSON :: distinct u128


identifier_json_generate :: proc () -> Identifier_JSON {
        // UUIDs should be serialized as big-endian. JSON can't print hex u128be.
        return identifier_to_json(uuid.generate_v4())
}

identifier_to_json :: proc(bytes: uuid.Identifier) -> Identifier_JSON {
        return Identifier_JSON(transmute(u128be)(bytes))
}

identifier_from_json :: proc(id: Identifier_JSON) -> uuid.Identifier {
        return transmute(uuid.Identifier)(u128be(id))
}


Import_Data_Header :: struct {
        uuid: Identifier_JSON,
}

// `file_ext` must include the leading period, e.g. ".png"
register_importer :: proc(file_ext: string, importer: Importer_Proc, init: Importer_Init_Proc = nil, destroy: Importer_Destroy_Proc = nil) {
        imp := Importer {
                importer_proc = importer,
                init_proc     = init,
                destroy_proc  = destroy,
                user_data     = nil,
        }
        importers[file_ext] = imp
}

// Walk res directory
// If a file exists with no metadata file, create a default one for that file type
// Create a .cal file containing all resources created from a source file
//      - Manifest contains additional URIs to subresources 
//      - File player.cal has subresources "frame_0", "frame_1", etc. and would be referenced by `player_resource := Resource[Sprite]("res://sprites/player.cal:frame_0")`
import_resources :: proc(args: ^Args) {
        project_abs, _ := filepath.abs(args.project)
        defer delete(project_abs)

        res_abs := filepath.join({project_abs, args.resource})
        defer delete(res_abs)

        imported_abs := filepath.join({project_abs, args.imported})
        defer delete(imported_abs)

        for _, &importer in importers {
                if importer.init_proc != nil {
                        importer.init_proc(args, &importer.user_data)
                }
        }


        w : os2.Walker
        os2.walker_init_path(&w, res_abs)

        for fi in os2.walker_walk(&w) {
                if fi.type != .Regular {
                        continue
                }

                ext := filepath.ext(fi.name)
                if ext == ".import" {
                        continue
                }

                importer, exists := importers[ext] 
                if exists {
                        src_dir_abs := filepath.dir(fi.fullpath)
                        dir_rel, _  := filepath.rel(res_abs, src_dir_abs)
                        dst_dir_abs := filepath.join({imported_abs, dir_rel})

                        ok := importer.importer_proc(args, fi.name, dir_rel, fi.fullpath, dst_dir_abs, importer.user_data)
                        if !ok {
                                log.error("Failed to import resource:", dir_rel, fi.name)
                        }

                        delete(src_dir_abs)
                        delete(dir_rel)
                        delete(dst_dir_abs)
                } else {
                        log.warn("No importer for file type", ext, "-", fi.name)
                }
        }

        os2.walker_destroy(&w)


        for _, &importer in importers {
                if importer.destroy_proc != nil {
                        importer.destroy_proc(args, importer.user_data)
                }
        }
}


copy_imported_to_data :: proc(args: ^Args) -> (res: Result) {
        data_dir := abs_path_from_out(args, "data")
        defer delete(data_dir)
        
        if os2.exists(data_dir) {
                err1 := os2.remove_all(data_dir)
                if err1 != nil {
                        log.error("Failed to delete occupied data directory:", err1)
                        return .Platform_Error
                }
        }

        imported_dir := abs_path_from_project(args, args.imported)
        defer delete(imported_dir)
        
        err := common.copy_directory(data_dir, imported_dir)
        if err != nil {
                log.error("Failed to copy assets to data directory:", err)
                return .Platform_Error
        }

        return .Ok
}


marshal_asset_into_file :: proc(dst_path_abs: string, asset: any) -> (ok: bool) {
        out_file, err_dst := os2.open(dst_path_abs, {.Write, .Trunc, .Create})
        if err_dst != nil {
                log.error("Failed to open output file:", dst_path_abs, "-", err_dst)
                return false
        }
        defer os2.close(out_file)

        w := os2.to_writer(out_file)

        err_cbor := cbor.marshal_into_writer(w, asset, temp_allocator = context.temp_allocator)
        if err_cbor != nil {
                log.error("Failed to marshal shader asset:", dst_path_abs, "-", err_cbor)
                return false
        }

        return true
}


// src_fullpath: The absolute filepath of the resource, NOT including .import extension.
import_data_open_or_create :: proc(src_fullpath: string, default_data: $T, allocator := context.allocator) -> (data: T, was_created: bool, ok: bool)  where intrinsics.type_is_struct(T) {
        context.allocator = allocator
        meta_path := fmt.aprintf("%v.import", src_fullpath)
        defer delete(meta_path)
        data = default_data

        // If the meta file doesn't exist, create one with the default_data then return a copy
        if !os2.exists(meta_path) {
                struct_generate_uuids(&data)
                
                ok = import_data_write_direct(meta_path, data)
                was_created = ok
                return
        }

        if !os2.is_file(meta_path) {
                log.error("Import metadata path is not a valid file:", meta_path)
                ok = false
                return
        }

        raw_data, err := os2.read_entire_file_from_path(meta_path, allocator)
        if err != nil {
                log.error("Failed to open import metadata file:", meta_path, err)
                ok = false
                return
        }

        err_json := json.unmarshal(raw_data, &data, JSON_MARSHAL_OPTS_DEFAULT.spec)
        if err_json != nil {
                log.error("Failed to unmarshal import metadata file:", meta_path, err_json)
                ok = false
                return
        }

        ok = true
        return
}


// src_fullpath: The absolute filepath of the resource, NOT including .import extension.
import_data_write :: proc(src_fullpath: string, data: $T) -> (ok: bool) {
        meta_path := fmt.aprintf("%v.import", src_fullpath)
        defer delete(meta_path)

        return import_data_write_direct(meta_path, data)
}

// import_data_fullpath: The absolute filepath of the resource's import file.
import_data_write_direct :: proc(import_data_fullpath: string, data: $T) -> (ok: bool) {
        meta_path := import_data_fullpath

        f, err := os2.open(meta_path, {.Create, .Trunc, .Write})
        if err != nil {
                log.error("Failed to open import metadata file:", meta_path, err)
                return false
        }
        defer os2.close(f)
        w := os2.to_writer(f)

        opts := JSON_MARSHAL_OPTS_DEFAULT
        err_json := json.marshal_to_writer(w, data, &opts)
        if err_json != nil {
                log.error("Failed to marshal import metadata:", meta_path)
                return false
        }

        return true
}


// Replace uuid.Identifier fields in `data` with a new UUID
struct_generate_uuids :: proc(data: ^$T) {
        a := any {
                data,
                typeid_of(T),
        }
        struct_generate_uuids_any(a)
}

struct_generate_uuids_any :: proc(v: any) {
        if v == nil {
                return
        }
       
        ti := type_info_of(v.id)

        if ti.id == typeid_of(Identifier_JSON) {
                replaced_uuid := (^Identifier_JSON)(v.data)
                replaced_uuid^ = identifier_json_generate()
                log.infof("Generated UUID: %x", replaced_uuid^)
                return
        }

        ti_base := runtime.type_info_base(ti)
        #partial switch info in ti_base.variant {
        case runtime.Type_Info_Struct:
                for field in reflect.struct_fields_zipped(ti_base.id) {
                        field_any := any {
                                rawptr(uintptr(v.data) + field.offset), 
                                field.type.id,
                        }
                        
                        struct_generate_uuids_any(field_any)
                }
        }
}


