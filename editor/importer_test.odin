package callisto_editor

import "core:encoding/cbor"
import "core:encoding/json"
import "core:io"
import cal ".."


Import_Info_Test :: struct {
        name: string,
}


write_default_import_info_test :: proc(w: io.Writer) -> Result {
        info := Import_Info_Test {
                name = "Test info hello",
        }

        opts := json_marshal_opts_default()
        err := json.marshal_to_writer(w, info, &opts)
        check_result(err, "Failed to marshal default Import info") or_return

        return .Ok
}

import_test :: proc(import_builder: ^Import_Builder) -> Result {
        asset_create(import_builder)
}
