package callisto_editor

import "slang"
import "core:os/os2"
import "core:strings"
import "core:log"
import "core:path/filepath"

global_session: ^slang.IGlobalSession


// import_shader_init :: proc() {
// 	// res := slang.createGlobalSession(slang.API_VERSION, &global_session)
// 	// dll_loader := global_session->getSharedLibraryLoader()
//  //        dll_loader.loadSharedLibrary = slang_load_shared_library
// 	// assert(res == slang.OK)
// }



// import_shader_destroy :: proc() {
// 	// global_session->release()
// }


// import_shader :: proc(res_path: string) {
// 	// res: slang.Result
// 	//
// 	// target_desc := slang.TargetDesc {
// 	// 	structureSize = size_of(slang.TargetDesc),
// 	// 	format        = .SPIRV,
// 	// 	profile       = global_session->findProfile("sm_6_0"),
// 	// 	flags         = {.GENERATE_SPIRV_DIRECTLY},
// 	// }
// 	//
// 	// compiler_option_entries := []slang.CompilerOptionEntry{}
// 	//
// 	// session_desc := slang.SessionDesc {
// 	// 	structureSize            = size_of(slang.SessionDesc),
// 	// 	targets                  = &target_desc,
// 	// 	targetCount              = 1,
// 	// 	compilerOptionEntries    = raw_data(compiler_option_entries),
// 	// 	compilerOptionEntryCount = u32(len(compiler_option_entries)),
// 	// }
// 	//
// 	// session: ^slang.ISession
// 	// res = global_session->createSession(session_desc, &session)
// 	// assert(res == slang.OK)
// 	//
// 	//
// 	// blob: ^slang.IBlob
// 	// code: ^slang.IBlob
// 	// diagnostics: ^slang.IBlob
// 	//
// 	// session->loadModuleFromSourceString()
// }


import_slang_temp :: proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string, dst_dir_abs: string) -> (ok: bool) {
        file_spv := strings.join({filepath.stem(src_filename), ".spv"}, "")
        defer delete(file_spv)

        // make sure abs_dir exists
        os2.make_directory_all(dst_dir_abs)

        dst_path_abs := filepath.join({dst_dir_abs, file_spv})
        defer delete(dst_path_abs)


        // Get subdir of res/
        // Create subdir of imported/
        command : [dynamic]string
        defer delete(command)
        append(&command, "slangc")
        append(&command, src_fullpath)
        append(&command, "-profile")
        append(&command, "sm_6_0")
        append(&command, "-capability")
        append(&command, "spirv_1_3")
        append(&command, "-o")
        append(&command, dst_path_abs)

        log.info("OUTPUT:", dst_path_abs)

        desc := os2.Process_Desc {
                working_dir = args.project,
                command     = command[:],
                env         = {},
                stderr      = os2.stderr,
                stdout      = os2.stdout,
                stdin       = os2.stdin,
        }
        process, err := os2.process_start(desc)
        if err != {} {
                log.error(command)
                log.error("Failed to start shaderc:", dir_rel, err)
                return false
        }

        state, err2 := os2.process_wait(process)
        if !state.success || state.exit_code != 0 || err2 != {} {
                log.error(command)
                log.error("Shaderc failed:", dir_rel, err2, state.exit_code)
                return false
        }

        return true
}
        


@(init)
register_importer_shader :: proc() {
        register_importer(".slang", import_slang_temp)
}
