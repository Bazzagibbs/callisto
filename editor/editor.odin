package callisto_editor

import "core:log"
import "core:flags"
import "core:os/os2"

import "../common"
import cal ".."

Result :: common.Result



main :: proc() {
        context.logger = log.create_console_logger(cal.Logger_Level_DEFAULT, cal.Logger_Options_DEFAULT)
        defer log.destroy_console_logger(context.logger)


        src_file :: "resources/meshes/basis.fbx"
        // dst_file :: "asset_lib/meshes/basis.gali"

        basis_fbx, _ := os2.open(src_file)
        basis_construct, basis_meshes, _ := import_fbx(basis_fbx, {})
        os2.close(basis_fbx)
}


check_result :: proc {
        check_result_ufbx,
}

