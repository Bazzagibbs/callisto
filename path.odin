package callisto

import "core:strings"
import "core:fmt"
import "core:path/slashpath"

Path :: struct {
        root: Path_Root,
        sb: strings.Builder,
}

Path_Root :: enum {
        Resource,
        User,
        // Cloud,
}
