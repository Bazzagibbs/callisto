#+feature dynamic-literals
package callisto_editor

import "core:os/os2"
import "core:log"
import "core:fmt"
import "core:path/filepath"
import "core:path/slashpath"
import "core:time"
import "core:strings"

import cal ".."

when ODIN_OS == .Windows {
        BIN_EXT :: ".exe"
        DLL_EXT :: ".dll"
}


clean :: proc(args: ^Args) -> Result {
        out_dir := filepath.join({args.project, args.out}, context.temp_allocator)
        if os2.exists(out_dir) {
                err := os2.remove_all(out_dir)
                check_result(err, "Failed to clean output directory") or_return
        }

        // Reimport resources
        resource_dir := filepath.join({args.project, "resources"}, context.temp_allocator)
        imported_dir := filepath.join({args.project, "resources_imported"}, context.temp_allocator)
        import_directory(resource_dir, imported_dir, true)

        out_data_dir := filepath.join({args.project, args.out, "data", "assets"}, context.temp_allocator)
        
        // Rebuild asset database
        log.debug("Copying data from", imported_dir, "to", out_data_dir)
        cal.copy_directory(out_data_dir, imported_dir)
        
        log.info("[+++] Output directory clean complete")

        return .Ok
}


build_runner :: proc(args: ^Args) -> (sys_time: time.Duration, res: Result) {
        hot_reload_enabled := args.release == false

        if args.clean {
                clean(args)
        }

        command := [dynamic]string {
                "odin",
                "build",
                "./callisto/runner",
        }
        defer delete(command)

        if args.debug {
                append(&command, "-debug")
        }

        out_path := slashpath.join({args.out, args.app_name}, context.temp_allocator)
        append(&command, fmt.tprintf("-out=%s%s", out_path, BIN_EXT)) // -out=./out/callisto_app.exe

        append(&command, fmt.tprintf("-define:APP_NAME=%s", args.app_name))

        append(&command, fmt.tprintf("-define:COMPANY_NAME=%s", args.company_name))

        if hot_reload_enabled {
                append(&command, "-define:HOT_RELOAD=true")
        }

        if args.release && ODIN_OS == .Windows {
                append(&command, "-subsystem=windows")
        }


        cmd, _ := strings.join(command[:], " ", context.temp_allocator)
        log.debug(cmd)
        // e.g. odin build ./callisto/runner -debug -out=./out/callisto_app.exe -define:APP_NAME="callisto_app" -define:COMPANY_NAME="callisto_default_company" -define:HOT_RELOAD=true -subsystem=windows
        desc := os2.Process_Desc {
                working_dir = args.project,
                command     = command[:],
                env         = {},
                stderr      = os2.stderr,
                stdout      = os2.stdout,
                stdin       = os2.stdin,
        }
        process, err := os2.process_start(desc)
        check_result(err, "Failed to start runner build process") or_return

        state, err2 := os2.process_wait(process)
        if !state.success || state.exit_code != 0{
                log.error("Failed to build Runner")
                return state.system_time, .Platform_Error
        }
        check_result(err2, "Failed to build Runner") or_return

        log.info("[+++] Runner build complete")

        return state.system_time, .Ok
}

build_app_dll :: proc(args: ^Args) -> (sys_time: time.Duration, res: Result) {
        command := [dynamic]string {
                "odin",
                "build",
                ".",
                "-build-mode=shared",
        }
        defer delete(command)

        if args.debug {
                append(&command, "-debug")
        }

        staging_path := slashpath.join({args.out, "staging"}, context.temp_allocator)
        append(&command, fmt.tprintf("-out=%s%s", staging_path, DLL_EXT)) // -out=./out/staging.dll

        append(&command, fmt.tprintf("-define:APP_NAME=%s", args.app_name))

        append(&command, fmt.tprintf("-define:COMPANY_NAME=%s", args.company_name))



        // e.g. odin build . -build-mode=shared -debug -out=./out/staging.dll -define:APP_NAME="callisto_app" -define:COMPANY_NAME=callisto_default_company
        // then move staging.dll to app_name.dll
        cmd, _ := strings.join(command[:], " ", context.temp_allocator)
        log.debug(cmd)
        desc := os2.Process_Desc {
                working_dir = args.project,
                command     = command[:],
                env         = {},
                stderr      = os2.stderr,
                stdout      = os2.stdout,
                stdin       = os2.stdin,
        }
        process, err := os2.process_start(desc)
        check_result(err, "Failed to start App DLL build process") or_return

        state, err2 := os2.process_wait(process)
        if !state.success || state.exit_code != 0 {
                log.error("Failed to build App DLL")
                return state.system_time, .Platform_Error
        }
        check_result(err2, "Failed to build App DLL") or_return


        log.info("[+++] App DLL build complete")

        // Recalculated as to not change the current working directory
        staging_path_2 := fmt.tprintf("%s%s", filepath.join({args.project, args.out, "staging"}, context.temp_allocator), DLL_EXT)
        app_path_2     := fmt.tprintf("%s%s", filepath.join({args.project, args.out, args.app_name}, context.temp_allocator), DLL_EXT)

        err3 := os2.rename(staging_path_2, app_path_2)
        check_result(err3, "Failed to rename App DLL") or_return

        return state.system_time, .Ok
}

run :: proc(args: ^Args) -> Result {
        log.info("Running app")
        exe_path := filepath.join({args.project, args.out, args.app_name}, context.temp_allocator)
        command := fmt.tprintf("%s%s", exe_path, BIN_EXT)

        log.debug(command)
        desc := os2.Process_Desc {
                working_dir = args.project,
                command     = {command},
                env         = {},
                // stderr      = os2.stderr,
                // stdout      = os2.stdout,
                // stdin       = os2.stdin,
        }
        process, err := os2.process_start(desc)
        check_result(err, "Failed to run app") or_return

        return .Ok
}
