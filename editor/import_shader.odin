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


import_shaders_all_temp :: proc(args: ^Args) {
        project_abs, _ := filepath.abs(args.project)
        defer delete(project_abs)

        res_abs := filepath.join({project_abs, args.resource})
        defer delete(res_abs)
        imported_abs := filepath.join({project_abs, args.imported})
        defer delete(imported_abs)

        // Start in args.resource
        // Walk through all directories, check for .slang extension
        // Call shaderc on each and pass the RELATIVE path (join args.resource, walk_dir)


        w : os2.Walker
        os2.walker_init_path(&w, res_abs)

        for fi in os2.walker_walk(&w) {
                if fi.type != .Regular {
                        continue
                }
                if filepath.ext(fi.name) == ".slang" {
                        slangc(args, res_abs, imported_abs, fi.fullpath)
                }
        }

        os2.walker_destroy(&w)


        slangc :: proc(args: ^Args, abs_res_dir: string, abs_imported_dir: string, abs_shader_dir: string) {
                subpath, _ := filepath.rel(abs_res_dir, abs_shader_dir)
                defer delete(subpath)
               
                file_spv := strings.join({filepath.stem(subpath), ".spv"}, "")
                defer delete(file_spv)
                
                subdir := filepath.dir(subpath)
                defer delete(subdir)

                abs_spv_out_dir := filepath.join({abs_imported_dir, subdir})
                defer delete(abs_spv_out_dir)

                // make sure abs_dir exists
                os2.make_directory_all(abs_spv_out_dir)

                abs_spv_path := filepath.join({abs_spv_out_dir, file_spv})
                defer delete(abs_spv_path)


                // Get subdir of res/
                // Create subdir of imported/
                command : [dynamic]string
                defer delete(command)
                append(&command, "slangc")
                append(&command, abs_shader_dir)
                append(&command, "-profile")
                append(&command, "sm_6_6")
                append(&command, "-o")
                append(&command, abs_spv_path)
        
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
                        log.error("Failed to start shaderc:", subdir, err)
                        return
                }

                state, err2 := os2.process_wait(process)
                if !state.success || state.exit_code != 0 || err2 != {} {
                        log.error(command)
                        log.error("Shaderc failed:", subdir, err2, state.exit_code)
                        return
                }
        }
        

}
