# Galileo Asset File Specification

_Version 0.1.0 DRAFT_ 

With binary encoding, values are little-endian.

With ASCII encoding, each field is newline (`\n`) delimited for better version control support, and buffers are base64 encoded 

Info structs are referenced by index into their respective array of structs.

Buffers are referenced by byte index. `*_slice_begin` determines the first byte in the struct, and `*_slice_size` determines how many bytes the slice should span.


## File header

```odin
File_Header :: struct {
    magic:                  [4]u8,      // "GALI"
    specification_version:  u32,        // Semantic versioning - major: u8, minor: u8, patch: u16
    asset_uuid:             u128,       // or UUID string in 8-4-4-4-12 format (36 characters) in ascii encoding
    asset_type:             u32,        // Asset_Type enum
    checksum:               u64,        // xxhash XXH3 of the file, EXCLUDING file header.
}
```
see also: ([Cyan4973/xxhash](https://github.com/Cyan4973/xxHash)

## File Body: Mesh

A _Mesh_ must contain one or many _Vertex Groups_ . Each _Vertex Group_ corresponds to one draw call in the renderer, and may be used to draw different parts of a _Mesh_ with a different material or shader.

A _Vertex Group_ contains information for constructing _Vertex Attribute_ slices. All _Vertex Attribute_ data for a given _Vertex Group_ is contiguous and de-interleaved.

```
buffer:
[ indices | vert_position | vert_normal | vert_tangent | uv_0 | uv_1 | color_0 | joints_0 | weights_0 | ext_0 ]
```



### Manifest
```odin
Mesh_Manifest :: struct {
    bounds_center:      [3]f32,
    bounds_extents:     [3]f32,
    n_vertex_groups:    u32,
    n_extensions:       u32,
    buffer_total_size:  u64,    // in bytes
}
```
### Vertex Group Info (Array)

```odin
Vertex_Group_Info :: struct {
    bounds_center:              [3]f32,
    bounds_extents:             [3]f32,
    buffer_slice_size:          u64,    // in bytes
    buffer_slice_begin:         u64,

    n_indices:                  u32,
    n_vertices:                 u32,

    n_uv_channels:              u8,
    n_color_channels:           u8,
    n_joint_weight_channels:    u8,

    p_extension_attribute:      u32,    // U32_MAX indicates no extensions.
}
```

- Indices are u32. `n_indices` should be a multiple of 3, drawing indexed triangles.

| Attribute | Element type | Note |
| --- | --- | --- |
| `position` | \[3]f32 | |
| `normal` | \[3]f32 | | 
| `tangent` | \[4]f32 | `xyz` is normalized, `w` is +1 or -1 indicating handedness of the tangent basis |
| `uv` | \[2]f32 | y-down, x-right ( (0, 0) is top left) |
| `color` | \[4]u8 | `rgba` , 0-255 per channel |
| `joints` | \[4]u16 | |
| `weights` | \[4]u16 | |

### Extension Info (Array)

Extensions can be used for application-specific information. Implementations may choose to ignore extension data.

```odin
Extension_Info :: struct {
    extension_name:     [16]u8,     // ascii string, null terminated or max length 16
    extension_version:  u32,
    p_data:             u64,        // Index into buffer containing extension user data
    p_next:             u32,        // Index into extension info array, indicating the next extension to apply. U32_MAX indicates end of list.
}
```
### Buffers

(per vertex group)
- \[buffer\_slice\_size]u8: `buffer_data`
