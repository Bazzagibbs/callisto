package callisto_editor

import "core:path/filepath"
import "core:os/os2"
import "core:strings"
import "core:log"

importers : map[string]Importer_Proc

// src_filename : "player.png"
// dir_rel      : "sprites\\characters\\"
// src_fullpath : "C:\\projects\\game\\res\\sprites\\characters\\player.png"
// dst_dir_abs  : "C:\\projects\\game\\imported\\sprites\\characters\\"
Importer_Proc :: #type proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string,  dst_dir_abs: string) -> (ok: bool)

// `file_ext` must include the leading period, e.g. ".png"
register_importer :: proc(file_ext: string, importer: Importer_Proc) {
        importers[file_ext] = importer
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

                        importer(args, fi.name, dir_rel, fi.fullpath, dst_dir_abs)

                        delete(src_dir_abs)
                        delete(dir_rel)
                        delete(dst_dir_abs)
                } else {
                        log.warn("No importer for file type", ext, "-", fi.name)
                }
        }

        os2.walker_destroy(&w)
}
