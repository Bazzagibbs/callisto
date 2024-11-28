// NOTE: This package is incomplete. Use CBOR instead until I get around to finishing it.
//
// A package for serializing and deserializing structs in a performant and resilient manner.
//
//   Author: Bailey Gibbons
//
//
// An asset has a manifest that describes the layout of the data buffer, along with field names.
// It also contains the file offset of the data buffer. The data buffer is constructed in such a way
// that it can be memcpy'd and transmuted into its final struct.
//
// Although the manifest contains type information, this format is intended to be used where the data
// is well-known by the application. The type information is used to reconcile changes in application
// data layout without losing authored data, such as temporarily removing or renaming a struct field.
//
// ```
// callisto_asset_file :: struct {
//      data_offset : u32,
//      manifest    : [data_offset - 4]u8,
//      data_buffer : []u8,
// }
// ```
package callisto_serial

