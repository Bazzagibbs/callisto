package callisto_editor

import "core:io"
import "core:bufio"
import "core:os/os2"
import "core:fmt"
import "core:container/queue"
import "core:log"
import "core:math/linalg"
import "core:bytes"
import "core:encoding/json"
import "base:runtime"

import "ufbx"
import cal ".."


Asset :: struct {}

Import_Info_Fbx :: struct {
        // // settings
        // // ids
        construct_uuid: cal.Uuid,
        // subasset_uuids: map[string]uuid.Identifier,
}

import_info_fbx_destroy :: proc(info: ^Import_Info_Fbx) {
        // delete(info.subasset_uuids)
}


write_default_import_info_fbx :: proc(w_file: ^os2.File) -> Result {
        info := Import_Info_Fbx {
                construct_uuid = cal.uuid_generate()
        }

        data, err := json.marshal(info, json_marshal_opts_default(), context.temp_allocator)
        check_result(err, "Failed to marshal default Import info") or_return

        _, err2 := os2.write(w_file, data)
        check_result(err2, "Failed to write default Import info to file") or_return

        return .Ok
}


import_fbx :: proc(file: ^os2.File, import_info_file: ^os2.File, out_filepath: string) -> (res: Result) {
        construct : cal.Construct
        meshes : []cal.Mesh

        info_bytes, err := os2.read_entire_file(import_info_file, context.temp_allocator)
        check_result(err, "Failed to read Import info file") or_return

        // TODO: how to handle invalid import info files?
        info : Import_Info_Fbx
        err1 := json.unmarshal(info_bytes, &info, Json_Unmarshal_Spec, context.allocator)
        check_result(err1, "Failed to unmarshal Import info file") or_return
        defer import_info_fbx_destroy(&info)

        file_data, err2 := os2.read_entire_file_from_file(file, context.allocator)
        check_result(err2, "Failed to read Resource file") or_return
        defer delete(file_data)

        target_axes := ufbx.Coordinate_Axes {
                front = .NEGATIVE_Y,
                right = .POSITIVE_X,
                up    = .POSITIVE_Z,
        }

        load_opts := ufbx.Load_Opts {
                target_axes              = target_axes,
                target_unit_meters       = 1,
                space_conversion         = .ADJUST_TRANSFORMS,
                generate_missing_normals = true,
        }
        
        u_err: ufbx.Error
        scene := ufbx.load_memory(raw_data(file_data), len(file_data), &load_opts, &u_err)
        check_result(&u_err, "FBX: Failed to load scene") or_return
        defer ufbx.free_scene(scene)


        // NODES -> construct transforms
        // construct_build_from_fbx(scene)

        // MESHES -> construct asset ref + mesh asset
        // meshes = make([]cal.Mesh, len(scene.meshes))
        
        // ANIMATIONS -> animation asset
        
        // BLEND CHANNELS -> mesh blend shapes


        // Generate subasset UUIDs if required
        // Write UUIDs to metadata file
        // Write subassets to output files

        return .Ok
}


// Encode an FBX node tree into a breadth-first flat transform array
construct_build_from_fbx :: proc(scene: ^ufbx.Scene) -> (construct: cal.Construct, res: Result)  {
        
        if scene.root_node == nil {
                log.error("FBX file has no root node")
                return {}, .File_Invalid
        }

        Child_Entry :: struct {
                node   : ^ufbx.Node,
                parent : i32,
        }

        child_queue : queue.Queue(Child_Entry)
        queue.init(&child_queue, len(scene.nodes))
        defer queue.destroy(&child_queue)

        construct.transforms     = make([]cal.Transform, len(scene.nodes))
        construct.local_matrices = make([]matrix[4,4]f32, len(scene.nodes))
        construct.world_matrices = make([]matrix[4,4]f32, len(scene.nodes))

        cursor: i32 = 0

        // Add root node to queue
        queue.push(&child_queue, Child_Entry{scene.root_node, -1})

        // Pop node, add self to construct, add children to queue
        for entry in queue.pop_front_safe(&child_queue) {
                t := &construct.transforms[cursor]

                t.name         = entry.node.element.name
                t.parent_index = entry.parent
                t.child_index  = cursor + t.child_count
                t.flags       += {.Dirty}
                
                rot := linalg.array_cast(entry.node.local_transform.rotation, f32)
                quat: quaternion128
                quat.x = rot.x
                quat.y = rot.y
                quat.z = rot.z
                quat.w = rot.w

                t.local_position = linalg.array_cast(entry.node.local_transform.translation, f32)
                t.local_rotation = quat
                t.local_scale    = linalg.array_cast(entry.node.local_transform.scale, f32)
                for child in entry.node.children {
                        queue.push(&child_queue, Child_Entry{child, cursor})
                }

                cursor += 1
        }



        cal.construct_recalculate_matrices(&construct)

        log.infof("%#v", construct)

        return construct, .Ok
}

@(init)
_register_fbx :: proc() {
        importers[".fbx"] = {
                write_default_import_info_proc = write_default_import_info_fbx,
                importer_proc                  = import_fbx,
        }
}
