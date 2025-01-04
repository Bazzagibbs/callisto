# Callisto GPU abstraction layer

## Integrating into application code

Although this package is intended to be used internally by Callisto's engine layer, it may be used directly in
application code.


Instructions WIP

## Implementing RHI backends

Should it be required that another graphics API backend be implemented, 
this is a map of all the files that need to be modified.

If you're an application developer, ignore this section.

### API Interface

1. Copy the commented interface from `api.odin` into `<rhi>_api_impl.odin`. These are the user-facing procedures and structs.
2. Wrap the file in a `when RHI == "<rhi>"` block
3. Implement all the procedure and struct stubs.
    - Create internal rhi-specific files using the naming convention `<rhi>_filename[_platform].odin`.

### Debug logger

An RHI's logger callback must be owned by the Runner executable.

1. Create the callback signature in `callisto/common/runner_api.odin`
    - `when RHI == "<rhi>" { Proc_Rhi_Logger :: <rhi_logger_signature> }`
2. Implement the callback in `callisto/runner/<rhi>_logger.odin`
3. Register the callback in `callisto/runner/runner.odin`
    - `when RHI == "<rhi>" { runner.<rhi>_logger = <rhi_logger_implementation> }` 

Now in `device_init`, set up the logger with the callback in `Device_Init_Info.runner.rhi_logger`.


## Design

Thin wrapper around some Vulkan features (shader object + dynamic rendering workflow).
This should be portable to other graphics APIs (GNM is apparently lower level than Vulkan)

- Maybe replace texture transitions with something more ergonomic? 
    - Per-thread `Texture_State` struct that keeps track of the current layout/access
    - Several specialized `cmd_transition` commands that only take this struct as a parameter

Currently all API-specific implementation details are accessable immediately in the struct.
Replace the implementation-specific structs with the following pattern:
```odin
Texture :: struct {
    // fields that are safe to access from the application side
    extent    : [3]int,
    full_view : Texture_View,
    _impl     : Texture_Impl, // This is the only part implemented per-api
}
```

This also replaces the getter procs `gpu.texture_get_extent()` etc.

## Future development

Some code is commented out alongside a corresponding `// FEATURE()` comment.
These are areas of the code that need to be modified should the feature be implemented.

Potential features include:
- `// FEATURE(Stereo rendering)` for VR headset support
- `// FEATURE(Ray tracing)`
- `// FEATURE(Mesh shading)`
- `// FEATURE(Texture limit)` in case an application requires more than the current arbitrary limit.
