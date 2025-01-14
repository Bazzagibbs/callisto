package ufbx

import "core:c"

as_slice :: proc {
        void_list_as_slice,
        bool_list_as_slice,
        uint32_list_as_slice,
        real_list_as_slice,
        vec2_list_as_slice,
        vec3_list_as_slice,
        vec4_list_as_slice,
        string_list_as_slice,
        dom_value_list_as_slice,
        dom_node_list_as_slice,
        prop_list_as_slice,
        element_list_as_slice,
        unknown_list_as_slice,
        connection_list_as_slice,
        node_list_as_slice,
        uv_set_list_as_slice,
        color_set_list_as_slice,
        edge_list_as_slice,
        face_list_as_slice,
        mesh_part_list_as_slice,
        face_group_list_as_slice,
        subdivision_weight_list_as_slice,
        mesh_list_as_slice,
        light_list_as_slice,
        camera_list_as_slice,
        bone_list_as_slice,
        empty_list_as_slice,
        line_segment_list_as_slice,
        line_curve_list_as_slice,
        nurbs_curve_list_as_slice,
        nurbs_surface_list_as_slice,
        nurbs_trim_surface_list_as_slice,
        nurbs_trim_boundary_list_as_slice,
        procedural_geometry_list_as_slice,
        stereo_camera_list_as_slice,
        camera_switcher_list_as_slice,
        marker_list_as_slice,
        lod_level_list_as_slice,
        lod_group_list_as_slice,
        skin_vertex_list_as_slice,
        skin_weight_list_as_slice,
        skin_deformer_list_as_slice,
        skin_cluster_list_as_slice,
        blend_deformer_list_as_slice,
        blend_keyframe_list_as_slice,
        blend_channel_list_as_slice,
        blend_shape_list_as_slice,
        cache_frame_list_as_slice,
        cache_channel_list_as_slice,
        cache_deformer_list_as_slice,
        cache_file_list_as_slice,
        material_texture_list_as_slice,
        material_list_as_slice,
        texture_layer_list_as_slice,
        shader_texture_input_list_as_slice,
        texture_file_list_as_slice,
        texture_list_as_slice,
        video_list_as_slice,
        shader_list_as_slice,
        shader_prop_binding_list_as_slice,
        shader_binding_list_as_slice,
        prop_override_list_as_slice,
        transform_override_list_as_slice,
        anim_stack_list_as_slice,
        anim_prop_list_as_slice,
        anim_layer_list_as_slice,
        anim_value_list_as_slice,
        keyframe_list_as_slice,
        anim_curve_list_as_slice,
        display_layer_list_as_slice,
        selection_set_list_as_slice,
        selection_node_list_as_slice,
        character_list_as_slice,
        constraint_target_list_as_slice,
        constraint_list_as_slice,
        audio_layer_list_as_slice,
        audio_clip_list_as_slice,
        bone_pose_list_as_slice,
        pose_list_as_slice,
        metadata_object_list_as_slice,
        name_element_list_as_slice,
        warning_list_as_slice,
        baked_vec3_list_as_slice,
        baked_quat_list_as_slice,
        baked_node_list_as_slice,
        baked_prop_list_as_slice,
        baked_element_list_as_slice,
}


void_list_as_slice :: proc(list: Void_List) -> []rawptr {
        return (transmute([^]rawptr)list.data)[:list.count]
}

bool_list_as_slice :: proc(list: Bool_List) -> []c.bool {
        return list.data[:list.count]
}


uint32_list_as_slice :: proc(list: Uint32_List) -> []u32 {
        return list.data[:list.count]
}

real_list_as_slice :: proc(list: Real_List) -> []Real {
        return list.data[:list.count]
}

vec2_list_as_slice :: proc(list: Vec2_List) -> []Vec2 {
        return list.data[:list.count]
}

vec3_list_as_slice :: proc(list: Vec3_List) -> []Vec3 {
        return list.data[:list.count]
}

vec4_list_as_slice :: proc(list: Vec4_List) -> []Vec4 {
        return list.data[:list.count]
}

string_list_as_slice :: proc(list: String_List) -> []String {
        return list.data[:list.count]
}

dom_value_list_as_slice :: proc(list: Dom_Value_List) -> []Dom_Value {
        return list.data[:list.count]
}

dom_node_list_as_slice :: proc(list: Dom_Node_List) -> []Dom_Node {
        return list.data[:list.count]
}

prop_list_as_slice :: proc(list: Prop_List) -> []Prop {
        return list.data[:list.count]
}

element_list_as_slice :: proc(list: Element_List) -> []^Element {
        return list.data[:list.count]
}

unknown_list_as_slice :: proc(list: Unknown_List) -> []^Unknown {
        return list.data[:list.count]
}

connection_list_as_slice :: proc(list: Connection_List) -> []Connection {
        return list.data[:list.count]
}

node_list_as_slice :: proc(list: Node_List) -> []^Node {
        return list.data[:list.count]
}

uv_set_list_as_slice :: proc(list: Uv_Set_List) -> []Uv_Set {
        return list.data[:list.count]
}

color_set_list_as_slice :: proc(list: Color_Set_List) -> []Color_Set {
        return list.data[:list.count]
}

edge_list_as_slice :: proc(list: Edge_List) -> []Edge {
        return list.data[:list.count]
}

face_list_as_slice :: proc(list: Face_List) -> []Face {
        return list.data[:list.count]
}

mesh_part_list_as_slice :: proc(list: Mesh_Part_List) -> []Mesh_Part {
        return list.data[:list.count]
}

face_group_list_as_slice :: proc(list: Face_Group_List) -> []Face_Group {
        return list.data[:list.count]
}

subdivision_weight_list_as_slice :: proc(list: Subdivision_Weight_List) -> []Subdivision_Weight {
        return list.data[:list.count]
}

mesh_list_as_slice :: proc(list: Mesh_List) -> []^Mesh {
        return list.data[:list.count]
}

light_list_as_slice :: proc(list: Light_List) -> []^Light {
        return list.data[:list.count]
}

camera_list_as_slice :: proc(list: Camera_List) -> []^Camera {
        return list.data[:list.count]
}

bone_list_as_slice :: proc(list: Bone_List) -> []^Bone {
        return list.data[:list.count]
}

empty_list_as_slice :: proc(list: Empty_List) -> []^Empty {
        return list.data[:list.count]
}

line_segment_list_as_slice :: proc(list: Line_Segment_List) -> []Line_Segment {
        return list.data[:list.count]
}

line_curve_list_as_slice :: proc(list: Line_Curve_List) -> []^Line_Curve {
        return list.data[:list.count]
}

nurbs_curve_list_as_slice :: proc(list: Nurbs_Curve_List) -> []^Nurbs_Curve {
        return list.data[:list.count]
}

nurbs_surface_list_as_slice :: proc(list: Nurbs_Surface_List) -> []^Nurbs_Surface {
        return list.data[:list.count]
}

nurbs_trim_surface_list_as_slice :: proc(list: Nurbs_Trim_Surface_List) -> []^Nurbs_Trim_Surface {
        return list.data[:list.count]
}

nurbs_trim_boundary_list_as_slice :: proc(list: Nurbs_Trim_Boundary_List) -> []^Nurbs_Trim_Boundary {
        return list.data[:list.count]
}

procedural_geometry_list_as_slice :: proc(list: Procedural_Geometry_List) -> []^Procedural_Geometry {
        return list.data[:list.count]
}

stereo_camera_list_as_slice :: proc(list: Stereo_Camera_List) -> []^Stereo_Camera {
        return list.data[:list.count]
}

camera_switcher_list_as_slice :: proc(list: Camera_Switcher_List) -> []^Camera_Switcher {
        return list.data[:list.count]
}

marker_list_as_slice :: proc(list: Marker_List) -> []^Marker {
        return list.data[:list.count]
}

lod_level_list_as_slice :: proc(list: Lod_Level_List) -> []Lod_Level {
        return list.data[:list.count]
}

lod_group_list_as_slice :: proc(list: Lod_Group_List) -> []^Lod_Group {
        return list.data[:list.count]
}

skin_vertex_list_as_slice :: proc(list: Skin_Vertex_List) -> []Skin_Vertex {
        return list.data[:list.count]
}

skin_weight_list_as_slice :: proc(list: Skin_Weight_List) -> []Skin_Weight {
        return list.data[:list.count]
}

skin_deformer_list_as_slice :: proc(list: Skin_Deformer_List) -> []^Skin_Deformer {
        return list.data[:list.count]
}

skin_cluster_list_as_slice :: proc(list: Skin_Cluster_List) -> []^Skin_Cluster {
        return list.data[:list.count]
}

blend_deformer_list_as_slice :: proc(list: Blend_Deformer_List) -> []^Blend_Deformer {
        return list.data[:list.count]
}

blend_keyframe_list_as_slice :: proc(list: Blend_Keyframe_List) -> []Blend_Keyframe {
        return list.data[:list.count]
}

blend_channel_list_as_slice :: proc(list: Blend_Channel_List) -> []^Blend_Channel {
        return list.data[:list.count]
}

blend_shape_list_as_slice :: proc(list: Blend_Shape_List) -> []^Blend_Shape {
        return list.data[:list.count]
}

cache_frame_list_as_slice :: proc(list: Cache_Frame_List) -> []Cache_Frame {
        return list.data[:list.count]
}

cache_channel_list_as_slice :: proc(list: Cache_Channel_List) -> []Cache_Channel {
        return list.data[:list.count]
}

cache_deformer_list_as_slice :: proc(list: Cache_Deformer_List) -> []^Cache_Deformer {
        return list.data[:list.count]
}

cache_file_list_as_slice :: proc(list: Cache_File_List) -> []^Cache_File {
        return list.data[:list.count]
}

material_texture_list_as_slice :: proc(list: Material_Texture_List) -> []Material_Texture {
        return list.data[:list.count]
}

material_list_as_slice :: proc(list: Material_List) -> []^Material {
        return list.data[:list.count]
}

texture_layer_list_as_slice :: proc(list: Texture_Layer_List) -> []Texture_Layer {
        return list.data[:list.count]
}

shader_texture_input_list_as_slice :: proc(list: Shader_Texture_Input_List) -> []Shader_Texture_Input {
        return list.data[:list.count]
}

texture_file_list_as_slice :: proc(list: Texture_File_List) -> []Texture_File {
        return list.data[:list.count]
}

texture_list_as_slice :: proc(list: Texture_List) -> []^Texture {
        return list.data[:list.count]
}

video_list_as_slice :: proc(list: Video_List) -> []^Video {
        return list.data[:list.count]
}

shader_list_as_slice :: proc(list: Shader_List) -> []^Shader {
        return list.data[:list.count]
}

shader_prop_binding_list_as_slice :: proc(list: Shader_Prop_Binding_List) -> []Shader_Prop_Binding {
        return list.data[:list.count]
}

shader_binding_list_as_slice :: proc(list: Shader_Binding_List) -> []^Shader_Binding {
        return list.data[:list.count]
}

prop_override_list_as_slice :: proc(list: Prop_Override_List) -> []Prop_Override {
        return list.data[:list.count]
}

transform_override_list_as_slice :: proc(list: Transform_Override_List) -> []Transform {
        return list.data[:list.count]
}

anim_stack_list_as_slice :: proc(list: Anim_Stack_List) -> []^Anim_Stack {
        return list.data[:list.count]
}

anim_prop_list_as_slice :: proc(list: Anim_Prop_List) -> []Anim_Prop {
        return list.data[:list.count]
}

anim_layer_list_as_slice :: proc(list: Anim_Layer_List) -> []^Anim_Layer {
        return list.data[:list.count]
}

anim_value_list_as_slice :: proc(list: Anim_Value_List) -> []^Anim_Value {
        return list.data[:list.count]
}

keyframe_list_as_slice :: proc(list: Keyframe_List) -> []Keyframe {
        return list.data[:list.count]
}

anim_curve_list_as_slice :: proc(list: Anim_Curve_List) -> []^Anim_Curve {
        return list.data[:list.count]
}

display_layer_list_as_slice :: proc(list: Display_Layer_List) -> []Display_Layer {
        return list.data[:list.count]
}

selection_set_list_as_slice :: proc(list: Selection_Set_List) -> []^Selection_Set {
        return list.data[:list.count]
}

selection_node_list_as_slice :: proc(list: Selection_Node_List) -> []^Selection_Node {
        return list.data[:list.count]
}

character_list_as_slice :: proc(list: Character_List) -> []^Character {
        return list.data[:list.count]
}

constraint_target_list_as_slice :: proc(list: Constraint_Target_List) -> []Constraint_Target {
        return list.data[:list.count]
}

constraint_list_as_slice :: proc(list: Constraint_List) -> []^Constraint {
        return list.data[:list.count]
}

audio_layer_list_as_slice :: proc(list: Audio_Layer_List) -> []Audio_Layer {
        return list.data[:list.count]
}

audio_clip_list_as_slice :: proc(list: Audio_Clip_List) -> []Audio_Clip {
        return list.data[:list.count]
}

bone_pose_list_as_slice :: proc(list: Bone_Pose_List) -> []Bone_Pose {
        return list.data[:list.count]
}

pose_list_as_slice :: proc(list: Pose_List) -> []^Pose {
        return list.data[:list.count]
}

metadata_object_list_as_slice :: proc(list: Metadata_Object_List) -> []^Metadata_Object {
        return list.data[:list.count]
}

name_element_list_as_slice :: proc(list: Name_Element_List) -> []Name_Element {
        return list.data[:list.count]
}

warning_list_as_slice :: proc(list: Warning_List) -> []Warning {
        return list.data[:list.count]
}

baked_vec3_list_as_slice :: proc(list: Baked_Vec3_List) -> []Baked_Vec3 {
        return list.data[:list.count]
}

baked_quat_list_as_slice :: proc(list: Baked_Quat_List) -> []Baked_Quat {
        return list.data[:list.count]
}

baked_node_list_as_slice :: proc(list: Baked_Node_List) -> []Baked_Node {
        return list.data[:list.count]
}

baked_prop_list_as_slice :: proc(list: Baked_Prop_List) -> []Baked_Prop {
        return list.data[:list.count]
}

baked_element_list_as_slice :: proc(list: Baked_Element_List) -> []Baked_Element {
        return list.data[:list.count]
}
