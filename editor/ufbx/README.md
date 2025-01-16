# `ufbx` Bindings for Odin

- `/src` contains the C source files used to build `ufbx.lib` and their license
- `/example` contains a simple example of using the API from Odin

The layout of some UFBX structs match the internal layout of their equivalent Odin types and can be used as such without any further translation.
- `ufbx_<type>_list` is interpreted as Odin slices `[]<type>`.
- `ufbx_string` is interpreted as an Odin `string`
- `ufbx_blob` is interpreted as `[]u8`

## Running the Example

From this directory, simply run `odin run example`. You should see a spinning Suzanne head.

## Compiling `ufbx.c`

A build script is provided for Windows using clang. Run it from a Developer Command Prompt.

On Windows, `ufbx.lib` is produced with:

```powershell
clang -c deps/ufbx.c -o deps/ufbx.obj -target x86_64-pc-windows-msvc -O3
lib /OUT:ufbx/ufbx.lib deps/ufbx.obj
rm deps/ufbx.obj
```

Feel free to add builds for other platforms.
