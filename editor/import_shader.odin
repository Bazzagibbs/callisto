package callisto_editor

import "slang"
import "core:os/os2"
import "core:strings"
import "core:log"
import "core:path/filepath"
import "core:encoding/cbor"
import "core:slice"
import sdl "vendor:sdl3"
import cal ".."

Slang_User_Data :: struct {
        global_session : ^slang.IGlobalSession,
        session        : ^slang.ISession,
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


slang_parse_enum_stage :: proc(attribute_str: string) -> slang.Stage {
        // Valid options from docs: attribute [Shader]
        switch attribute_str {
        case `"vertex"`        : return .VERTEX
        case `"fragment"`      : return .FRAGMENT
        case `"compute"`       : return .COMPUTE
	case `"geometry"`      : return .GEOMETRY
        case `"hull"`          : return .HULL
	case `"domain"`        : return .DOMAIN
	case `"raygeneration"` : return .RAY_GENERATION
        }

        return .NONE
}


slang_stage_to_sdl_stage :: proc(slang_stage: slang.Stage) -> sdl.GPUShaderStage {
        #partial switch slang_stage {
        case .VERTEX   : return .VERTEX
        case .FRAGMENT : return .FRAGMENT
        }

        return .VERTEX
}


import_slang :: proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string, dst_dir_abs: string, user_data: rawptr) -> (ok: bool) {
        // Maybe we can change this to be a separate directory and import a module all at once?
        // Then expose all the entry points in the material editor

        slang_data := (^Slang_User_Data)(user_data)
	res: slang.Result

        // Output files
        os2.make_directory_all(dst_dir_abs)

        out_filename := strings.concatenate({filepath.stem(src_filename), ".cal"})
        defer delete(out_filename)
        dst_path_abs := filepath.join({dst_dir_abs, out_filename})
        defer delete(dst_path_abs)


        src_fullpath_c := strings.clone_to_cstring(src_fullpath)
        defer delete(src_fullpath_c)

        diag: ^slang.IBlob
        module := slang_data.session->loadModule(src_fullpath_c, &diag)
        slang_check(diag, src_filename) or_return
        defer module->release()


        entry_point_count := module->getDefinedEntryPointCount()
        log.debug("MODULE:", src_filename)

        for i in 0..<entry_point_count {
                if diag != nil {
                        diag = nil
                }

                entry_point: ^slang.IEntryPoint
                _ = module->getDefinedEntryPoint(i, &entry_point)
                // defer entry_point->release()

                // Compile each entry point separately, we'll compose pipelines at runtime through material definitions
                components := []^slang.IComponentType { module, entry_point }
                program: ^slang.IComponentType
                slang_data.session->createCompositeComponentType(raw_data(components), len(components), &program, &diag)
                slang_check(diag) or_continue

                // Reflection
                // Need the following:
                // - Entry point name
                // - Stage
                // - Sampler count
                // - Storage texture count
                // - Storage buffer count
                // - Uniform buffer count
                
                program_layout := program->getLayout(0, &diag)
                slang_check(diag) or_continue

                
                // REFLECTION HERE
                slang_walk_program(program_layout)


                entry_point_refl := slang.Reflection_getEntryPointByIndex(program_layout, 0)
                stage := slang.ReflectionEntryPoint_getStage(entry_point_refl)
                entry_point_name := string(slang.ReflectionEntryPoint_getName(entry_point_refl))


                // Push constants
                push_const_count := slang.ReflectionEntryPoint_getParameterCount(entry_point_refl)
                for param_index in 0..<push_const_count {
                        // param_layout := slang.ReflectionEntryPoint_getParameterByIndex(entry_point_refl, param_index)
                        // slang.ReflectionVariableLayout_
                }
                

                linked_program: ^slang.IComponentType
                program->link(&linked_program, &diag)
                slang_check(diag) or_continue
                // defer linked_program->release()

               

                // TODO: Material - Add resource path to the shader library manifest

                kernel_code: ^slang.IBlob
                linked_program->getEntryPointCode(0, 0, &kernel_code, &diag)
                slang_check(diag) or_continue
                defer kernel_code->release()

                // Compose asset and write kernel code to file 
                f, err := os2.open(dst_path_abs, {.Write, .Trunc, .Create})
                check_result(err, dst_path_abs) or_continue

                defer os2.close(f)
                s := os2.to_writer(f)

                kernel_slice := slice.bytes_from_ptr(kernel_code->getBufferPointer(), int(kernel_code->getBufferSize()))

                // Write a raw spirv file for debugging with cli tools
                if args.dump_spirv {
                        spv_filename := strings.concatenate({filepath.stem(src_filename), ".spirv"})
                        defer delete(spv_filename)
                        spv_path_abs := filepath.join({dst_dir_abs, spv_filename})
                        defer delete(spv_path_abs)

                        spv_err := os2.write_entire_file(spv_path_abs, kernel_slice)
                        if spv_err != nil {
                                log.error("Failed to dump SPIRV:", spv_filename, "-", spv_err)
                        }
                }



                asset_create_info := cal.Asset_Shader {
                        type                 = .Shader,
                        code                 = kernel_slice,
                        entrypoint           = entry_point_name,
                        format               = {.SPIRV},
                        stage                = slang_stage_to_sdl_stage(stage),
                        num_samplers         = 0, // REFLECTION
                        num_storage_buffers  = 0, // REFLECTION
                        num_storage_textures = 0, // REFLECTION
                        num_uniform_buffers  = 0, // REFLECTION
                        props                = 0,
                }

                log.debugf("%#v", asset_create_info)

                cbor_err := cbor.marshal_into_writer(s, asset_create_info, temp_allocator = context.temp_allocator)
                check_result(cbor_err, dst_path_abs) or_continue

                

        }


        return true
}


@(init)
register_importer_shader :: proc() {
        register_importer(".slang", import_slang, import_slang_init, import_slang_destroy)
}


import_slang_init :: proc(args: ^Args, user_data: ^rawptr) {
        slang_data := new(Slang_User_Data)
        user_data^ = slang_data

	res := slang.createGlobalSession(slang.API_VERSION, &slang_data.global_session)
	assert(res == slang.OK, "Failed to create Slang global session")

        compiler_options_spv := []slang.CompilerOptionEntry {
                slang.CompilerOptionEntry{.Capability, {kind = .String, stringValue0 = "spirv_1_3"}},
                // slang.CompilerOptionEntry{.VulkanUseEntryPointName, {kind = .Int, intValue0 = 1}}, // Doesn't seem to work
        }

        target_desc := slang.TargetDesc {
                structureSize               = uint(size_of(slang.TargetDesc)),
                // Change this if compiling for another backend
                format                      = .SPIRV,
                profile                     = slang_data.global_session->findProfile("sm_6_0"),
                flags                       = {},
                floatingPointMode           = .DEFAULT,
                lineDirectiveMode           = .DEFAULT,
                forceGLSLScalarBufferLayout = false,
                compilerOptionEntries       = raw_data(compiler_options_spv),
                compilerOptionEntryCount    = u32(len(compiler_options_spv)),
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

}


import_slang_destroy :: proc(args: ^Args, user_data: rawptr) {
        slang_data := (^Slang_User_Data)(user_data)
        slang_data.session->release()
        slang_data.global_session->release()
        slang.shutdown()
        free(slang_data)
}

