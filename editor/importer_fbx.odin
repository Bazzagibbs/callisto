package callisto_editor

import "core:os/os2"
import "core:fmt"
import "core:container/queue"
import "core:log"
import "core:math/linalg"
import "base:runtime"

import "ufbx"
import cal ".."


check_result_ufbx :: proc(u_err: ^ufbx.Error) -> Result {
        if u_err.type == .NONE {
                return .Ok
        }

        log.error("FBX: Load scene failed:", u_err.description)
        switch u_err.type {
        case .NONE, .UNKNOWN: 
                return .File_Invalid
        case .FILE_NOT_FOUND, .EXTERNAL_FILE_NOT_FOUND: 
                return .File_Not_Found
        case .EMPTY_FILE: 
                return .File_Invalid
        case .OUT_OF_MEMORY, .MEMORY_LIMIT, .ALLOCATION_LIMIT:
                return .Out_Of_Memory_CPU
        case .TRUNCATED_FILE:
                return .File_Invalid
        case .IO:
                return .Platform_Error
        case .CANCELLED:
                return .User_Interrupt
        case .UNRECOGNIZED_FILE_FORMAT:
                return .File_Invalid
        case .UNINITIALIZED_OPTIONS:
                return .Argument_Invalid
        case .ZERO_VERTEX_SIZE, .TRUNCATED_VERTEX_STREAM, .INVALID_UTF8:
                return .Argument_Invalid
        case .FEATURE_DISABLED:
                return .Configuration_Invalid
        case .BAD_NURBS:
                return .Argument_Invalid
        case .BAD_INDEX:
                return .File_Invalid
        case .NODE_DEPTH_LIMIT:
                return .Configuration_Invalid
        case .THREADED_ASCII_PARSE:
                return .File_Invalid
        case .UNSAFE_OPTIONS:
                return .Configuration_Invalid
        case .DUPLICATE_OVERRIDE:
                return .Argument_Invalid
        }

        return .File_Invalid
}

Asset :: struct {}

Fbx_Import_Metadata :: struct {
}

import_fbx :: proc(file: ^os2.File, meta: Fbx_Import_Metadata) -> (construct: cal.Construct, meshes: []cal.Mesh, res: Result) {
        file_data, err := os2.read_entire_file_from_file(file, context.allocator)
        // check_result(err) or_return
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
        check_result(&u_err) or_return
        defer ufbx.free_scene(scene)


        // NODES -> construct transforms
        construct_build_from_fbx(scene)

        // MESHES -> construct asset ref + mesh asset
        // meshes = make([]cal.Mesh, len(scene.meshes))
        
        // ANIMATIONS -> animation asset
        
        // BLEND CHANNELS -> mesh blend shapes


        return {}, {}, .Ok
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



        cal.construct_resolve(&construct)

        log.infof("%#v", construct)

        return construct, .Ok
}
