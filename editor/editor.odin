package callisto_editor

import "core:crypto"
import "core:log"
import "core:flags"
import "core:os/os2"
import "core:path/filepath"

import "../common"
import cal ".."

Result :: common.Result

Args :: struct {
        command : Run_Command `args:"pos=0" usage:"Available options: 
        - editor (default)
        - build
        - run
        - reload"`,
        project      : string `args:"pos=1" usage:"The root directory of the project. Default: ./"`,
        out          : string `usage:"The output directory for build/run/reload, relative to the project directory. Default: ./out/"`,
        app_name     : string `args:"name=app-name" usage:"The name of the application. Default: callisto_app"`,
        company_name : string `args:"name=company-name" usage:"The name of the company. Default: callisto_default_company"`,
        release      : bool `usage:"Build/run the project without Hot Reload functionality."`,
        debug        : bool `usage:"Build/run/reload the project with Debug symbols."`,
        clean        : bool `usage:"Clean the output directory and reimport all resources before build/run."`,
}

Run_Command :: enum {
        editor, 
        build,
        run,
        reload,
}

main :: proc() {
        context.logger = log.create_console_logger(cal.Logger_Level_DEFAULT, cal.Logger_Options_DEFAULT)
        defer log.destroy_console_logger(context.logger)

        context.random_generator = crypto.random_generator()

        res := program_main()
        if res != .Ok {
                os2.exit(int(res))
        }

}

program_main :: proc() -> Result {
        args: Args
        flags.parse_or_exit(&args, os2.args, .Odin)

        if args.project == "" {
                args.project = "."
        } 
        temp_project := args.project
        args.project, _ = filepath.abs(args.project)
        // delete(temp_project)
        defer delete(args.project)
        check_project_dir(args.project) or_return


        if args.out == "" {
                args.out = "./out"
        }
        check_out_dir(args.out) or_return

        if args.app_name == "" {
                args.app_name = "callisto app"
        }

        if args.company_name == "" {
                args.company_name = "callisto default company"
        }

        log.debugf("%#v", args)

        switch args.command {
        case .editor:
                log.info("Launching in Editor mode")

        case .build:
                build_runner(&args) or_return
                build_app_dll(&args) or_return

        case .run:
                build_runner(&args) or_return
                build_app_dll(&args) or_return
                run(&args) or_return

        case .reload:
                build_app_dll(&args) or_return
        }

        return .Ok
}

@(private="file")
check_project_dir :: proc(dir: string) -> Result {
        if !os2.exists(dir) {
                log.error("Project directory does not exist:", dir)
                return .File_Not_Found
        }
        if !os2.is_dir(dir) {
                log.error("Project directory is invalid:", dir)
                return .File_Invalid
        }

        return .Ok
}

@(private="file")
check_out_dir :: proc(dir: string) -> Result {
        if os2.exists(dir) && os2.is_file(dir) {
                log.error("Output directory is invalid:", dir)
                return .File_Invalid
        }

        return .Ok
}

