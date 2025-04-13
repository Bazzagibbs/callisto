package callisto

import "base:runtime"
import sdl "vendor:sdl3"
import "core:slice"
import "core:mem"
import "core:log"
import "core:image"
import "core:image/png"
import "core:bytes"
import "core:math/linalg"
import "core:fmt"
import "core:strings"


Scene :: struct {
        // Maybe bind a scene to a global variable at the start of a frame
        // Might be worth changing Transform_Data to an arena allocator
        transform_data      : [dynamic]Transform_Data,
        transform_roots     : [dynamic]Transform,
        transform_free_list : [dynamic]Transform,
        allocator           : runtime.Allocator,
        editor_state        : Editor_Scene_State,
        
}

Editor_Scene_State :: struct {
        dirty : bool, // < Does scene have unsaved changes?
        transform_selected_latest : Transform,
        // undo_stack
}


// Create a Scene that contains Transforms and Entities.
scene_create :: proc(allocator := context.allocator) -> Scene {
        scene : Scene
        scene.allocator = allocator

        transform_data      := make([dynamic]Transform_Data, scene.allocator)
        transform_roots     := make([dynamic]Transform, scene.allocator)
        transform_free_list := make([dynamic]Transform, scene.allocator)

        return scene
}


scene_destroy :: proc(scene: ^Scene) {
        for &data in scene.transform_data {
                _transform_destroy_data(scene, &data)
        }
        delete(scene.transform_roots)
        delete(scene.transform_data)
        delete(scene.transform_free_list)
}


scene_set_dirty :: proc(scene: ^Scene) {
        scene.editor_state.dirty = true
}

// scene_save :: proc(scene: ^Scene) {
//
// }


Transform_Flags :: bit_set[Transform_Flag]
Transform_Flag :: enum {
        Tombstone, // < The transform has been destroyed
        Dirty,     // < The transform has been modified and needs to be resolved
        GPU_Used,  // < The transform is used on the GPU
        GPU_Dirty, // < The transform has been modified and needs to be reuploaded to the GPU
}

Transform_Reparent_Flag :: enum {
        Keep_World_Transform,
        Keep_Local_Transform,
        Clear_Local_Transform,
}

Transform :: distinct int
Transform_Data :: struct {
        name            : string,             // < When set through accessor proc, guaranteed to be null-terminated.
        handle          : Transform,
        parent          : Transform,          // < If parent handle is TRANSFORM_NONE, this is a root node.
        children        : [dynamic]Transform, //
        world_matrix    : matrix[4, 4]f32,    // < Read-only. May be invalid if "dirty" flag is set, use accessor proc.
        local_matrix    : matrix[4, 4]f32,    // < Read-only. May be invalid if "dirty" flag is set, use accessor proc.
        world_position  : [3]f32,             // < May be invalid if "dirty" flag is set, use accessor proc.
        world_rotation  : quaternion128,      // < May be invalid if "dirty" flag is set, use accessor proc.
        world_scale     : [3]f32,             // < Note: this will only be accurate if there is no skew in all ancestors. May be invalid if "dirty" flag is set, use accessor proc.
        local_position  : [3]f32,
        local_rotation  : quaternion128,
        local_scale     : [3]f32,
        flags           : Transform_Flags,
        editor_state    : Editor_Transform_State,
}

TRANSFORM_NONE :: Transform(-1)

Editor_Transform_State :: struct {
        // hidden_self         : bool,
        // hidden_in_hierarchy : bool,
        use_hierarchy_color : bool,
        hierarchy_color : [4]f32,
}


transform_data_identity :: proc(handle: Transform) -> Transform_Data {
        return Transform_Data {
                handle         = handle,
                parent         = TRANSFORM_NONE,
                children       = {},
                world_matrix   = linalg.MATRIX4F32_IDENTITY,
                local_matrix   = linalg.MATRIX4F32_IDENTITY,
                world_position = {},
                world_rotation = linalg.QUATERNIONF32_IDENTITY,
                world_scale    = {1, 1, 1},
                local_position = {},
                local_rotation = linalg.QUATERNIONF32_IDENTITY,
                local_scale    = {1, 1, 1},
                flags          = {.Dirty}
        }
}


// Create a transform and add it to the `scene`. 
//
// It can be destroyed in the following ways:
//   * `transform_destroy()` - also destroys all child transforms
//   * When its parent is destroyed
//   * When the scene is destroyed
//
// `name` is cloned using the scene's allocator. If no name is provided, one will be generated for it.
transform_create :: proc(scene: ^Scene, name := "", parent: Transform = TRANSFORM_NONE) -> Transform {
        handle: Transform
        if len(scene.transform_free_list) > 0 {
                handle = pop(&scene.transform_free_list)
                scene.transform_data[handle] = transform_data_identity(handle)
        } else {
                handle = Transform(len(scene.transform_data))
                append(&scene.transform_data, transform_data_identity(handle))
        }

        if name != "" {
                transform_get_data(scene, handle).name = string(strings.clone_to_cstring(name, scene.allocator))
        } else {transform_get_data(scene, handle)
                scene.transform_data[handle].name = string(fmt.caprintf("Transform(%d)", handle, allocator = scene.allocator))
        }

        transform_get_data(scene, handle).children = make([dynamic]Transform, scene.allocator)
        transform_set_parent(scene, handle, parent)

        return handle
}


// Recursively destroy this transform and all child transforms.
transform_destroy :: proc(scene: ^Scene, transform: Transform) {
        // Also might need to check for entities that reference this transform
        append(&scene.transform_free_list, transform)
        data := transform_get_data(scene, transform)
        for child in data.children {
                transform_destroy(scene, child)
        }

        _transform_destroy_data(scene, data)
}


// For internal use. Destroy only this transform's data.
_transform_destroy_data :: proc(scene: ^Scene, transform_data: ^Transform_Data) {
        if .Tombstone in transform_data.flags {
                return
        }

        delete(transform_data.name, scene.allocator)
        delete(transform_data.children)

        transform_data.flags = {.Tombstone}
}


// Get a pointer to the backing data of a Transform handle.
// Only store this pointer temporarily as it may be invalidated across frames.
// When reading data's fields, call `transform_resolve_dirty()` to ensure matrices and world-space values are up to date.
// When modifying data's fields, call `transform_set_dirty()` afterwards to recalculate.
transform_get_data :: proc(scene: ^Scene, transform: Transform) -> ^Transform_Data {
        return &scene.transform_data[transform]
}


// Get the name of this transform used in the scene hierarchy and debug messages.
// This string is null-terminated.
transform_get_name :: proc(scene: ^Scene, transform: Transform) -> string {
        if transform == TRANSFORM_NONE {
                return "TRANSFORM_NONE"
        }
        return transform_get_data(scene, transform).name
}


// Set the name of this transform in the scene hierarchy and debug messages.
// Clones `name` using the scene allocator. The clone will be null-terminated.
transform_set_name :: proc(scene: ^Scene, transform: Transform, name: string) {
        data := transform_get_data(scene, transform)
        if data.name != "" {
                delete(data.name)
        }
        data.name = string(strings.clone_to_cstring(name, scene.allocator))
}


// Get a 4x4 matrix that transforms into the world's coordinate space.
transform_get_world_matrix :: proc(scene: ^Scene, transform: Transform) -> matrix[4,4]f32 {
        transform_resolve_dirty(scene, transform)
        return transform_get_data(scene, transform).world_matrix
}


// Get a 4x4 matrix that transforms into its parent's coordinate space.
transform_get_local_matrix :: proc(scene: ^Scene, transform: Transform) -> matrix[4,4]f32 {
        transform_resolve_dirty(scene, transform)
        return transform_get_data(scene, transform).local_matrix
}


// Get a 4x4 matrix that transforms from the world's coordinate space into its local space.
transform_get_inverse_world_matrix :: proc(scene: ^Scene, transform: Transform) -> matrix[4,4]f32 {
        transform_resolve_dirty(scene, transform)
        data := transform_get_data(scene, transform)
        return linalg.matrix4_inverse(data.world_matrix)
}


// Get a 4x4 matrix that transforms from its parent's coordinate space into its local space.
transform_get_inverse_local_matrix :: proc(scene: ^Scene, transform: Transform) -> matrix[4,4]f32 {
        transform_resolve_dirty(scene, transform)
        data := transform_get_data(scene, transform)
        return linalg.matrix4_inverse(data.local_matrix)
}


// Get this transform's position in the world's coordinate space.
transform_get_world_position :: proc(scene: ^Scene, transform: Transform) -> [3]f32 {
        transform_resolve_dirty(scene, transform)
        return transform_get_data(scene, transform).world_position
}


// Set this transform's position in the world's coordinate space.
transform_set_world_position :: proc(scene: ^Scene, transform: Transform, world_position: [3]f32) {
        transform_resolve_dirty(scene, transform)
        data := transform_get_data(scene, transform)
        inv_mat := linalg.matrix4_inverse(data.world_matrix)
        world_pos := [4]f32{world_position.x, world_position.y, world_position.z, 1}
        data.local_position = (world_pos * inv_mat).xyz
        transform_set_dirty(scene, transform)
}


// Get this transform's rotation in the world's coordinate space.
transform_get_world_rotation :: proc(scene: ^Scene, transform: Transform) -> quaternion128 {
        transform_resolve_dirty(scene, transform)
        return transform_get_data(scene, transform).world_rotation
}


// Set this transform's rotation in the world's coordinate space.
transform_set_world_rotation :: proc(scene: ^Scene, transform: Transform, world_rotation: quaternion128) {
        transform_resolve_dirty(scene, transform)
        data := transform_get_data(scene, transform)
        inv_quat := linalg.quaternion_inverse(data.world_rotation)
        data.local_rotation = world_rotation * inv_quat
        transform_set_dirty(scene, transform)
}


// Get this transform's scale in the world's coordinate system.
// Note that this is not guaranteed to be accurate! If any of the transform's ancestors are non-uniformly scaled and rotated,
// this value will not be correct.
transform_get_world_scale_lossy :: proc(scene: ^Scene, transform: Transform) -> [3]f32 {
        transform_resolve_dirty(scene, transform)
        return transform_get_data(scene, transform).world_scale
}


// Get this transform's position in its parent's coordinate space.
transform_get_local_position :: proc(scene: ^Scene, transform: Transform) -> [3]f32 {
        return transform_get_data(scene, transform).local_position
}


// Set this transform's position in its parent's coordinate space.
transform_set_local_position :: proc(scene: ^Scene, transform: Transform, local_position: [3]f32) {
        transform_get_data(scene, transform).local_position = local_position
        transform_set_dirty(scene, transform)
}


// Get this transform's rotation in its parent's coordinate space.
transform_get_local_rotation :: proc(scene: ^Scene, transform: Transform) -> quaternion128 {
        return transform_get_data(scene, transform).local_rotation
}


// set this transform's rotation in its parent's coordinate space.
transform_set_local_rotation :: proc(scene: ^Scene, transform: Transform, local_rotation: quaternion128) {
        transform_get_data(scene, transform).local_rotation = local_rotation
        transform_set_dirty(scene, transform)
}


// Get this transform's scale in its parent's coordinate space.
transform_get_local_scale :: proc(scene: ^Scene, transform: Transform) -> [3]f32 {
        return transform_get_data(scene, transform).local_scale
}


// Set this transform's scale in its parent's coordinate space.
transform_set_local_scale :: proc(scene: ^Scene, transform: Transform, local_scale: [3]f32) {
        transform_get_data(scene, transform).local_scale = local_scale
        transform_set_dirty(scene, transform)
}


// Get this transform's parent.
// If this transform is a root transform, returns TRANSFORM_NONE
transform_get_parent :: proc(scene: ^Scene, transform: Transform) -> Transform {
        return transform_get_data(scene, transform).parent
}


// Set this transform's parent.
// If `parent` is TRANSFORM_NONE, this transform will be made a root node.
// `index` determines where this transform will be inserted in the parent's child list. A value of -1 will append.
transform_set_parent :: proc(scene: ^Scene, transform: Transform, parent: Transform = TRANSFORM_NONE, index := -1, reparent_mode := Transform_Reparent_Flag.Keep_World_Transform, location := #caller_location) {
        // Edge cases:
        //      - Transform is NONE             // invalid
        //      - Old parent is NONE            // remove from scene.transform_roots
        //      - New parent is NONE            // add to scene.transform_roots
        //      - Old parent is new parent      // ok, early return
        //      - New parent is a descendent    // invalid?

        if transform == TRANSFORM_NONE {
                log.error("Failed to set parent of TRANSFORM_NONE", location = location)
                return
        }

        if transform_is_ancestor(scene, transform, parent) {
                log.error("Failed to set parent", transform_get_name(scene, parent), "->", transform_get_name(scene, transform), ": transform is currently an ancestor of the new parent", location = location)
                return
        }


        data := transform_get_data(scene, transform)
        // new_parent_data := transform_get_data(scene, parent)


        // Existing parent, may need to keep world transform
        world_pos   : [3]f32
        world_rot   : quaternion128
        world_scale : [3]f32

        if reparent_mode == .Keep_World_Transform {
                transform_resolve_dirty(scene, transform)
                world_pos   = data.world_position
                world_rot   = data.world_rotation
                world_scale = data.world_scale
        }

        // Remove child from old parent
        _transform_remove_child(scene, data.parent, transform)
        _transform_add_child(scene, parent, transform, index)
        data.parent = parent

        // Apply transform
        switch reparent_mode {
        case .Keep_World_Transform:
                // old world -> parent space
                if parent == TRANSFORM_NONE {
                        data.local_position = world_pos
                        data.local_rotation = world_rot
                        data.local_scale    = world_scale
                } else {
                        transform_resolve_dirty(scene, parent)
                        new_parent_data := transform_get_data(scene, parent)
                        data.local_position = ([4]f32{world_pos.x, world_pos.y, world_pos.z, 1} * linalg.matrix4_inverse_f32(new_parent_data.world_matrix)).xyz
                        data.local_rotation = world_rot * linalg.quaternion_inverse(new_parent_data.world_rotation)
                        data.local_scale    = world_scale / new_parent_data.world_scale // This might not work properly if either the new parent or old parent has skew
                }
        case .Keep_Local_Transform:
                // Do nothing
        case .Clear_Local_Transform:
                data.local_position = {}
                data.local_rotation = linalg.QUATERNIONF32_IDENTITY
                data.local_scale    = {1, 1, 1}
        }

        transform_set_dirty(scene, transform)




}


// Get a read-only slice of a transform's children.
// If `transform` is TRANSFORM_NONE, returns a slice of all root transforms.
transform_get_children :: proc(scene: ^Scene, transform: Transform) -> []Transform {
        if transform == TRANSFORM_NONE {
                return scene.transform_roots[:]
        }
        return transform_get_data(scene, transform).children[:]
}


// Returns true if `ancestor` is above `descendant` in the hierarchy, false otherwise
transform_is_ancestor :: proc(scene: ^Scene, ancestor, descendent: Transform) -> bool {
        if descendent == TRANSFORM_NONE || ancestor == TRANSFORM_NONE {
                return false
        }

        d_data := transform_get_data(scene, descendent)
        if d_data.parent == ancestor {
                return true
        }

        return transform_is_ancestor(scene, d_data.parent, ancestor)
}


// Sets the `.dirty` flag, indicating that its matrices and world trs need to be recalculated before being accessed or drawn.
transform_set_dirty :: proc(scene: ^Scene, transform: Transform) {
        data := transform_get_data(scene, transform)

        // If already dirty, children will already be dirty and we can skip
        if .Dirty in data.flags {
                return
        }
        
        data.flags += {.Dirty}
        for child in data.children {
                transform_set_dirty(scene, child)
        }
}


// Traverse the transform hierarchy top-down to resolve all dirty nodes, starting at the root node. 
// To resolve a single transform node during logic, use `transform_resolve_dirty()` instead.
scene_resolve_dirty :: proc(scene: ^Scene) {
        for transform in scene.transform_roots {
                transform_resolve_dirty_subtree(scene, transform)
        }
}


// Traverse the transform hierarchy bottom-up until a non-dirty node is found, then resolve the branch until this node.
transform_resolve_dirty :: proc(scene: ^Scene, transform: Transform) {
        if transform == TRANSFORM_NONE {
                return
        }

        data := transform_get_data(scene, transform)
        if .Dirty not_in data.flags {
                return
        }

        transform_resolve_dirty(scene, data.parent)

        data.local_matrix   = linalg.matrix4_from_trs_f32(data.local_position, data.local_rotation, data.local_scale)

        if data.parent == TRANSFORM_NONE {
                data.world_matrix   = data.local_matrix
                data.world_position = data.local_position
                data.world_rotation = data.local_rotation
                data.world_scale    = data.local_scale
        } else {
                parent_data := transform_get_data(scene, data.parent)
                data.world_matrix   = parent_data.world_matrix * data.local_matrix                                                             // < check order
                data.world_position = ([4]f32{data.local_position.x, data.local_position.y, data.local_position.z, 1} * data.world_matrix).xyz // < check order
                data.world_rotation = parent_data.world_rotation * data.local_rotation                                                         // < check order
                data.world_scale    = parent_data.world_scale * data.local_scale                                                               // lossy if there is skew
        }

        data.flags         -= {.Dirty}
}


// Traverse the transform hierarchy top-down to resolve all dirty nodes, starting at the provided `subtree_root`. 
// To resolve a single transform node during logic, use `transform_resolve_dirty()` instead.
transform_resolve_dirty_subtree :: proc(scene: ^Scene, subtree_root: Transform) {
        data := transform_get_data(scene, subtree_root)

        if .Dirty in data.flags {
                data.local_matrix   = linalg.matrix4_from_trs_f32(data.local_position, data.local_rotation, data.local_scale)

                if data.parent == TRANSFORM_NONE {
                        data.world_matrix   = data.local_matrix
                        data.world_position = data.local_position
                        data.world_rotation = data.local_rotation
                        data.world_scale    = data.local_scale
                } else {
                        parent_data := transform_get_data(scene, data.parent)
                        data.world_matrix   = parent_data.world_matrix * data.local_matrix // < check order
                        data.world_position = ([4]f32{data.local_position.x, data.local_position.y, data.local_position.z, 1} * data.world_matrix).xyz // < check order
                        data.world_rotation = parent_data.world_rotation * data.local_rotation // < check order
                        data.world_scale    = parent_data.world_scale * data.local_scale // lossy if there is skew
                        data.flags         -= {.Dirty}
                }
        }

        for child in data.children {
                transform_resolve_dirty_subtree(scene, child)
        }
}


// For internal use. This only removes the parent->child relationship. 
// Use `transform_set_parent()` with parent = TRANSFORM_NONE to unparent a child without destroying it. 
_transform_remove_child :: proc(scene: ^Scene, parent, child: Transform) {
        if parent == TRANSFORM_NONE {
                for c, i in scene.transform_roots {
                        if c == child {
                                ordered_remove(&scene.transform_roots, i)
                                return
                        }
                }
        } else {
                parent_data := transform_get_data(scene, parent)
                for c, i in parent_data.children {
                        if c == child {
                                ordered_remove(&parent_data.children, i)
                                return
                        }
                }
        }
}
        

// For internal use. This only adds the parent->child relationship to the parent.
// Use `transform_set_parent()` instead.
_transform_add_child :: proc(scene: ^Scene, parent: Transform, child: Transform, index: int = -1) {
        index := index
        if parent == TRANSFORM_NONE {
                if index < 0 || index > len(scene.transform_roots) {
                        index = len(scene.transform_roots)
                }
                inject_at(&scene.transform_roots, index, child)
                return
        } else {
                parent_data := transform_get_data(scene, parent)
                if index < 0 || index > len(parent_data.children){
                        index = len(parent_data.children)
                }
                inject_at(&parent_data.children, index, child)
                return
        }
}
