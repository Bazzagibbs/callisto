## Platform support

Currently these bindings only support Windows. Bindings for Linux will need some changes:

- Add "imports_file" to bindgen
- Add conditional compilation of struct fields in `Compress_Options` wrapped in `#ifdef USE_3DMESH_OPTIMIZE` - Windows only

