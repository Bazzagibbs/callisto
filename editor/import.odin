package callisto_editor

import "core:path/filepath"
import "core:os/os2"
import "core:strings"
import "core:log"
import "../common"

importers : map[string]Importer

Importer :: struct {
        importer_proc : Importer_Proc,
        init_proc     : Importer_Init_Proc,     // Optional
        destroy_proc  : Importer_Destroy_Proc,  // Optional
        user_data     : rawptr,
}

// src_filename : "player.png"
// dir_rel      : "sprites\\characters\\"
// src_fullpath : "C:\\projects\\game\\res\\sprites\\characters\\player.png"
// dst_dir_abs  : "C:\\projects\\game\\imported\\sprites\\characters\\"
Importer_Proc :: #type proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string,  dst_dir_abs: string, user_data: rawptr = nil) -> (ok: bool)

Importer_Init_Proc :: #type proc(args: ^Args, user_data: ^rawptr)

Importer_Destroy_Proc :: #type proc(args: ^Args, user_data: rawptr)

// `file_ext` must include the leading period, e.g. ".png"
register_importer :: proc(file_ext: string, importer: Importer_Proc, init: Importer_Init_Proc = nil, destroy: Importer_Destroy_Proc = nil) {
        imp := Importer {
                importer,
                init,
                destroy,
                nil,
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
