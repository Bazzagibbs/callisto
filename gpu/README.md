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

