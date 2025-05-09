package callisto_editor

import "slang"
import "core:os/os2"
import "core:strings"
import "core:log"
import "core:path/filepath"

Slang_User_Data :: struct {
        global_session : ^slang.IGlobalSession,
        session        : ^slang.ISession,
        // store loaded modules/entry points here and do pipeline linking while parsing material assets
}


slang_check :: proc {
        slang_check_result,
        slang_check_diag_blob,
}


slang_check_result :: #force_inline proc(#any_int result: int, message: string = "", loc := #caller_location) -> (ok: bool) {
	result := slang.Result(result)
	if slang.FAILED(result) {
		code := slang.GET_RESULT_CODE(result)
		facility := slang.GET_RESULT_FACILITY(result)
		estr: string
		switch slang.Result(result) {
		case:
			estr = "Unknown error"
		case slang.E_NOT_IMPLEMENTED():
			estr = "E_NOT_IMPLEMENTED"
		case slang.E_NO_INTERFACE():
			estr = "E_NO_INTERFACE"
		case slang.E_ABORT():
			estr = "E_ABORT"
		case slang.E_INVALID_HANDLE():
			estr = "E_INVALID_HANDLE"
		case slang.E_INVALID_ARG():
			estr = "E_INVALID_ARG"
		case slang.E_OUT_OF_MEMORY():
			estr = "E_OUT_OF_MEMORY"
		case slang.E_BUFFER_TOO_SMALL():
			estr = "E_BUFFER_TOO_SMALL"
		case slang.E_UNINITIALIZED():
			estr = "E_UNINITIALIZED"
		case slang.E_PENDING():
			estr = "E_PENDING"
		case slang.E_CANNOT_OPEN():
			estr = "E_CANNOT_OPEN"
		case slang.E_NOT_FOUND():
			estr = "E_NOT_FOUND"
		case slang.E_INTERNAL_FAIL():
			estr = "E_INTERNAL_FAIL"
		case slang.E_NOT_AVAILABLE():
			estr = "E_NOT_AVAILABLE"
		case slang.E_TIME_OUT():
			estr = "E_TIME_OUT"
		}

		log.errorf("Slang failed with error: %v (%v) Facility: %v - %v", estr, code, facility, message, location = loc)
                return false
	}

        return true
}


slang_check_diag_blob :: #force_inline proc(blob: ^slang.IBlob, message: string = "", loc := #caller_location) -> (ok: bool) {
        if blob != nil {
                log.errorf("Slang failed with diagnostic: %v - %v", cstring(blob->getBufferPointer()), message, location = loc)
                return false
        }

        return true
}


slang_parse_shader_stage :: proc(attribute_str: string) -> slang.Stage {
        // Valid options from docs: attribute [Shader]
        switch attribute_str {
        case `"vertex"`: return .VERTEX
        case `"fragment"`: return .FRAGMENT
        case `"compute"`: return .COMPUTE
	case `"geometry"`: return .GEOMETRY
        case `"hull"`: return .HULL
	case `"domain"`: return .DOMAIN
	case `"raygeneration"`: return .RAY_GENERATION
        }

        return .NONE
}

import_slang :: proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string, dst_dir_abs: string, user_data: rawptr) -> (ok: bool) {
        // How should this work?
        // - prepass the shaders to generate a list of all vertex/fragment entry points
        // - on material definition import, create linked modules to be used as pipelines

        slang_data := (^Slang_User_Data)(user_data)
	res: slang.Result

        // Output files
        out_filename := strings.concatenate({filepath.stem(src_filename), ".cal"})
        defer delete(out_filename)

        os2.make_directory_all(dst_dir_abs)

        dst_path_abs := filepath.join({dst_dir_abs, out_filename})
        defer delete(dst_path_abs)



        src_fullpath_c := strings.clone_to_cstring(src_fullpath)
        defer delete(src_fullpath_c)

        diag: ^slang.IBlob
        module := slang_data.session->loadModule(src_fullpath_c, &diag)
        slang_check(diag, src_filename) or_return
        defer module->release()


        entry_point_count := module->getDefinedEntryPointCount()
        log.info("MODULE:", module->getName())

        for i in 0..<entry_point_count {
                entry_point: ^slang.IEntryPoint
                _ = module->getDefinedEntryPoint(i, &entry_point)
                refl := entry_point->getFunctionReflection()
                entry_point_name := slang.ReflectionFunction_GetName(refl)
                log.info("Entry point:", entry_point_name)

                shader_attr := slang.ReflectionFunction_FindUserAttributeByName(refl, slang_data.global_session, "shader")
                if shader_attr == nil {
                        log.errorf("No \"shader\" attribute on entry point \"%v\"", entry_point_name)
                        continue
                }
               
                // Entry point stage reflection isn't available until linking ????? it's in the attributes!
                shader_attr_value_size: int
                shader_attr_value := slang.ReflectionUserAttribute_GetArgumentValueString(shader_attr, 0, &shader_attr_value_size)
                shader_stage_str := strings.string_from_ptr((^u8)(shader_attr_value), shader_attr_value_size)
                stage := slang_parse_shader_stage(shader_stage_str)
                log.info(" - Stage:", stage)

                // TODO: Add stage entry point to available options for materials
        }


        // layout := module->getLayout()


        // Generate shader create info from reflection


        return true
}


import_slang_temp :: proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string, dst_dir_abs: string, user_data: rawptr) -> (ok: bool) {
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
        register_importer(".slang", import_slang, import_slang_init, import_slang_destroy)
        // register_importer(".slang", import_slang_temp)
}


import_slang_init :: proc(args: ^Args, user_data: ^rawptr) {
        slang_data := new(Slang_User_Data)
        user_data^ = slang_data

	res := slang.createGlobalSession(slang.API_VERSION, &slang_data.global_session)
	assert(res == slang.OK, "Failed to create Slang global session")

        compiler_options := []slang.CompilerOptionEntry {
                slang.CompilerOptionEntry{.Capability, {kind = .String, stringValue0 = "spirv_1_3"}},
        }

        target_desc := slang.TargetDesc {
                structureSize               = uint(size_of(slang.TargetDesc)),
                // Change this if compiling for another backend
                format                      = .SPIRV,
                profile                     = slang_data.global_session->findProfile("sm_6_0"),
                flags                       = {.GENERATE_SPIRV_DIRECTLY},
                floatingPointMode           = .DEFAULT,
                lineDirectiveMode           = .DEFAULT,
                forceGLSLScalarBufferLayout = false,
                compilerOptionEntries       = raw_data(compiler_options),
                compilerOptionEntryCount    = u32(len(compiler_options)),
        }

        search_paths := []cstring{
                strings.clone_to_cstring(args.resource),
                // TODO: add builtin shader includes
        }

        defer for str in search_paths {
                delete(str)
        }

        session_desc := slang.SessionDesc {
                structureSize            = uint(size_of(slang.SessionDesc)),
                targets                  = &target_desc,
                targetCount              = 1,
                flags                    = {},
                defaultMatrixLayoutMode  = .COLUMN_MAJOR,
                searchPaths              = raw_data(search_paths),
                searchPathCount          = len(search_paths),
                preprocessorMacros       = nil,
                preprocessorMacroCount   = 0,
                // fileSystem = ??,
                enableEffectAnnotations  = false,
                allowGLSLSyntax          = false,
                compilerOptionEntries    = nil,
                compilerOptionEntryCount = 0,
        }

        res = slang_data.global_session->createSession(session_desc, &slang_data.session)
        slang_check(res, "Failed to create Slang session")

	// dll_loader := slang_data.global_session->getSharedLibraryLoader()
        // dll_loader.loadSharedLibrary = 
}


import_slang_destroy :: proc(args: ^Args, user_data: rawptr) {
        slang_data := (^Slang_User_Data)(user_data)
        slang_data.session->release()
        slang_data.global_session->release()
        slang.shutdown()
        free(slang_data)
}

