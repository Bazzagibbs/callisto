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

1. Copy the commented interface from `api.odin` into `<rhi>_api.odin`. These are the user-facing procedures and structs.
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


### App Init

- Create a `Device` for the entire application. This is a logical representation of a GPU and the RHI instance.
- Create a `Swapchain` for each target window. These will provide the `Texture` to be used as the final render target.
- Create a `Shader` for each shader stage (vertex, fragment, compute, etc.)
- Create `Buffer`s for a mesh's vertex and index data
- Create `Texture`s for texturing the mesh
- Create a `Sampler` for sampling the `Texture`s
- Create a `Blend_State` for setting alpha blending


### Loop

- Acquire the current `Command_Buffer` from the `Swapchain`
- Acquire the current `Texture` from the `Swapchain`
- `cmd_set_render_targets()`
- For each unique material:
    - `cmd_set_shaders()`
    - `cmd_set_blend_state()`
    - `cmd_set_vertex_buffers()`
    - `cmd_set_index_buffers()`
    - `cmd_set_uniforms()`
    - `cmd_draw()`
- Submit the `Command_Buffer`
- Present the `Command_Buffer`


### Async Compute

If compute is required outside of the render path (e.g. terrain generation), a separate command buffer can be created.

- Create a `Fence` to wait on for task completion.
- Create a `Command_Buffer` using the Fence.
    - `cmd_bind_shaders()`
    - `cmd_bind_uniforms()`
    - `cmd_dispatch()`
- Submit the `Command_Buffer`
