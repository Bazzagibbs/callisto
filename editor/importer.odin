package callisto_editor

import "core:log"

import "core:os"
import "core:os/os2"
import "core:path/filepath"
import "core:strings"
import "core:fmt"
import "core:encoding/json"

import cal ".."


// Maps file extensions to their corresponding Importer implementation. Note the key includes the leading period, e.g. ".fbx"
importers: map[string]Importer

Importer :: struct {
        write_default_import_info_proc : Importer_Write_Default_Import_Info_Proc,
        importer_proc                  : Importer_Proc,
}

// Callback to write the default import info to a provided file.
Importer_Write_Default_Import_Info_Proc :: #type proc(w_file: ^os2.File) -> Result

// `file` is the raw asset data in its original format.
// `import_file` is `file`'s corresponding import metadata.
// `out_filepath` is an absolute filepath WITHOUT an extension. Any assets generated from a source file should append to this, then add the `.cal` file extension. E.g. `fmt.tprintf("%s.%s.cal", out_filepath, subasset_name)`
Importer_Proc :: #type proc(file: ^os2.File, import_file: ^os2.File, out_filepath: string) -> Result


json_marshal_opts_default :: proc() -> json.Marshal_Options {
        return {
                spec                      = .SJSON,
                pretty                    = true,
                spaces                    = 2,
                write_uint_as_hex         = true,
                mjson_keys_use_quotes     = true,
                mjson_keys_use_equal_sign = false,
                sort_maps_by_key          = true,
                use_enum_names            = true, // Safety when enum definitions change
        }
}

Json_Unmarshal_Spec :: json.Specification(.SJSON)


import_directory :: proc(res_src: string, res_dst: string, reimport_all := false) -> Result {
        log.info("Importing directory", res_src)
        res_src := res_src
        res_dst := res_dst

        if reimport_all {
                // TODO: delete dst directory and rebuild all
                // Otherwise, check if each asset has already been imported using file hash
        }

        if !filepath.is_abs(res_src) {
                res_src, _ = filepath.abs(res_src, context.temp_allocator)
        }
        
        if !filepath.is_abs(res_dst) {
                res_dst, _ = filepath.abs(res_dst, context.temp_allocator)
        }

        // Asset files contain a hash of the source file and a compact copy of the .import file used to create it.

        // For each file in src, check for a .import file
        // If none exists, determine the file type and create a new .import file for it with the default values for that type.
        
        walk_proc :: proc(info: os.File_Info, in_err: os.Error, user_data: rawptr) -> (err: os.Error, skip_dir: bool) {
                data := (^Walk_Userdata)(user_data)

                // Ignore meta files at this point, we'll get them explicitly in `import_file()`
                if info.is_dir || filepath.ext(info.name) == ".import" {
                        return {}, false
                }
       
                asset_path, err2 := filepath.rel(data.src_dir, info.fullpath, context.temp_allocator)
                
                res := import_file(data.src_dir, data.dst_dir, asset_path)
                return {}, false
        }

        Walk_Userdata :: struct {
                cwd     : string,
                src_dir : string,
                dst_dir : string,
        }
        
        cwd, _ := os2.get_working_directory(context.temp_allocator)

        walk_userdata := Walk_Userdata {
                cwd,
                res_src, 
                res_dst,
        }

        err3 := filepath.walk(res_src, walk_proc, &walk_userdata)
        if err3 != nil {
                log.error("Failed to walk directory:", err3)
                return .File_Invalid
        }

        log.info("[+++] Resources import complete")

        return .Ok
}


// `asset_path` is relative to res_src
import_file :: proc(res_src, res_dst, asset_path: string) -> Result {
        import_info_path := fmt.tprintf("%s.import", asset_path)
        import_info_path_abs := filepath.join({res_src, import_info_path}, context.temp_allocator)

        ext := filepath.ext(asset_path)
        importer, exist := importers[filepath.ext(asset_path)]
        if !exist {
                log.warnf("Unrecognized file extension: %s (%s)", ext, asset_path)
                return .File_Invalid
        }

        import_info_file: ^os2.File
        err: os2.Error

        // if import info file doesn't exist, create a default importer file.
        if os2.exists(import_info_path_abs) {
                import_info_file, err = os2.open(import_info_path_abs, {.Read, .Write})
                check_result(err, "Failed to open Import info file") or_return
        } else {
                import_info_file, err = os2.create(import_info_path_abs)
                check_result(err, "Failed to create Import info file") or_return
                importer.write_default_import_info_proc(import_info_file) or_return
                os2.seek(import_info_file, 0, .Start)
        }
        defer os2.close(import_info_file)

        asset_path_abs := filepath.join({res_src, asset_path}, context.temp_allocator)
        asset_file, err1 := os2.open(asset_path_abs)
        check_result(err1, "Failed to open Asset file") or_return
        defer os2.close(asset_file)

        asset_path_no_ext := filepath.stem(asset_path)
        out_path := filepath.join({res_dst, asset_path_no_ext}, context.temp_allocator)
        importer.importer_proc(asset_file, import_info_file, out_path)

        // log.info(
        return .Ok
}
