# Galileo Asset File Specification

_Version 0.1.0_

With binary encoding, values are little-endian.

With ASCII encoding, each field is newline (`\n`) delimited for better version control support, and buffers are base64 encoded 

Info structs are referenced by index into their respective array of structs.

Buffers are referenced by byte index. `*_slice_begin` determines the first byte in the struct, and `*_slice_size` determines how many bytes the slice should span.


## File header

- \[4]u8: Magic ("GALI")
- u32: Asset type
- u32: Specification version
- u64: Checksum ([xxhash XXH3](https://github.com/Cyan4973/xxHash) of the file, EXCLUDING file header.)

## File Body: Mesh

A _Mesh_ may contain one or many _Vertex Group_s. Each _Vertex Group_ corresponds to one draw call in the renderer, and may be used to draw different parts of a _Mesh_ with a different material or shader.

A _Vertex Group_ contains information for constructing _Vertex Attribute_ slices. All _Vertex Attribute_ data for a given _Vertex Group_ is contiguous and de-interleaved.

```
buffer:
[ indices | vert_position | vert_normal | vert_tangent | uv_0 | uv_1 | color_0 | joints_0 | weights_0 | ext_0 ]
```



### Manifest

- \[3]f32: `bounds_center`
- \[3]f32: `bounds_extents`
- u32: `n_vertex_groups`
- u32: `n_extensions`
- u64: `buffer_total_size` (bytes)

### Vertex Group Info (Array)

- \[3]f32: `bounds_center`
- \[3]f32: `bounds_extents`
- u64: `buffer_slice_size` (bytes)
- u64: `buffer_slice_begin`

- u32: `n_indices`
- u32: `n_vertices`

- u8: `n_uv_channels`
- u8: `n_color_channels`
- u8: `n_joint_weight_channels`

- u64: `p_extension_attribute`

#### Notes on vertex attributes

- Indices are u32. `n_indices` should be a multiple of 3, drawing indexed triangles, unless otherwise specified by an extension.

| Attribute | Element type | Note |
| --- | --- | --- |
| `position` | \[3]f32 | |
| `normal` | \[3]f32 | | 
| `tangent` | \[4]f32 | `xyz` is normalized, `w` is +1 or -1 indicating handedness of the tangent basis |
| `uv` | \[2]f32 | y-down, x-right ( (0, 0) is top left) |
| `color` | [4]u8 | `rgba` , 0-255 per channel |
| `joints` | [4]u16 | |
| `weights` | [4]u16 | |

### Extension Info (Array)

Extensions can be used for application-specific information. Implementations may choose to ignore extension data.

- \[16]char: `extension_name` (string, null terminated or max 16)
- u32: `extension_version`
- u64: `p_data`
- u64: `p_next`

### Buffers

(per vertex group)
- \[buffer\_slice\_size]u8: `buffer_data`
