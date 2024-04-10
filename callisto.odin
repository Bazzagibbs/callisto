package callisto

import "common"
import "core:log"
import "platform"
import "window"
import "graphics"
import "input"
import "debug"
import "core:time"
import "core:math"


// Initialize Callisto engine. If successful, call `engine.shutdown()` before exiting the program.
create :: proc(description: ^Engine_Description) -> (engine: Engine, res: Result) {
    debug.profile_scope()
    
    log.info("Initializing Callisto engine")

    validate_engine_description(description) or_return

    engine.user_data   = description.user_data
    engine.update_proc = description.update_proc
    engine.tick_proc   = description.tick_proc
   
    // PLATFORM
    platform.init()
    res = platform.init(); 
    check_result(res, "Platform") or_return
    defer if res != .Ok do platform.destroy()

    // WINDOW
    engine.window, res = window.create(description.display_description)
    check_result(res, "Window") or_return
    defer if res != .Ok do window.destroy(engine.window)

    // INPUT
    engine.input, res = input.create()
    defer if res != .Ok do input.destroy(engine.input)

    platform.input_bind(engine.window, engine.input)

    // RENDERER
    engine.renderer, res = graphics.renderer_create(description, engine.window)
    check_result(res, "Renderer") or_return
    defer if res != .Ok do graphics.renderer_destroy(engine.renderer)

    // TIME
    engine.time.scale = 1

    return engine, .Ok
}


// Shut down Callisto engine, cleaning up internal allocations.
destroy :: proc(engine: ^Engine) {
    debug.profile_scope()
   
    input.destroy(engine.input)
    graphics.renderer_destroy(engine.renderer)
    window.destroy(engine.window)
    platform.destroy()
}


run :: proc(engine: ^Engine) {
    time.stopwatch_reset(&engine.time.stopwatch_epoch)
    time.stopwatch_start(&engine.time.stopwatch_epoch)

    for !window.should_close(engine.window) {
        // Update Frame_Time struct

        delta_duration := time.stopwatch_duration(engine.time.stopwatch_delta)
        engine.time.delta_unscaled = f32(time.duration_seconds(delta_duration))
        time.stopwatch_reset(&engine.time.stopwatch_delta)
        time.stopwatch_start(&engine.time.stopwatch_delta)
        
        if (engine.time.maximum_delta > 0) {
            engine.time.delta_unscaled = math.clamp(engine.time.delta_unscaled, 0, engine.time.maximum_delta)
        }

        engine.time.delta = engine.time.delta_unscaled * engine.time.scale
        
        // Allow user to submit custom render commands
        graphics.cmd_graphics_begin(engine.renderer)
       
        // Call user code
        if engine.update_proc != nil {
            engine.update_proc(engine)
        }

        // Built-in render loop
        graphics.cmd_graphics_end(engine.renderer)
        graphics.cmd_graphics_present(engine.renderer)

        // window.present(engine.window)
        platform.poll_events()
    }

    time.stopwatch_stop(&engine.time.stopwatch_epoch)
}


check_result :: common.check_result


validate_engine_description :: proc(desc: ^Engine_Description) -> (res: Result) {
    validate_application_description(desc.application_description) or_return
    validate_display_description(desc.display_description) or_return
    validate_renderer_description(desc.renderer_description) or_return

    return .Ok
}


validate_application_description :: proc(desc: ^Application_Description) -> (res: Result) {
    res = .Invalid_Description

    if desc              == nil       do return

    if len(desc.name)    == 0         do return
    if len(desc.company) == 0         do return
    if desc.version      == {0, 0, 0} do return

    return .Ok
}


validate_display_description :: proc(desc: ^Display_Description) -> (res: Result) {
    res = .Invalid_Description
   
    if desc == nil do return

    return .Ok
}


validate_renderer_description :: proc(desc: ^Renderer_Description) -> (res: Result) {
    res = .Invalid_Description
    
    if desc == nil do return

    return .Ok
}
