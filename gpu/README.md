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

1. Copy the interface procs from `api.odin` into `<api>_api_impl.odin`.
2. Wrap the file in a `when RHI_BACKEND == "<api>"` block
3. Implement all the procedure stubs and struct `_impl`s.

GPU object structs follow the pattern:

```odin
Gpu_Object :: struct {
    read_only_a : int,
    read_only_b : bool,
    _impl       : _Gpu_Object_Impl,
}
```

This is to prevent application code from accidentally relying on implementation-specific details, causing issues when porting to a different graphics API.
