package callisto_runner

import "core:dynlib"
import "core:os"
import "core:path/filepath"
import "../config"
import "../common"

// Used to get absolute path of the game DLL
when ODIN_OS == .Windows {
        DLL_ORIGINAL_FMT :: `{0}\` + config.APP_NAME + ".dll"
        DLL_COPY_FMT     :: `{0}\` + config.APP_NAME + "_{1}.dll"
} else when ODIN_OS == .Darwin {
        DLL_ORIGINAL_FMT :: "{0}/" + config.APP_NAME + ".dylib"
        DLL_COPY_FMT     :: "{0}/" + config.APP_NAME + "_{1}.dylib"
} else {
        DLL_ORIGINAL_FMT :: "{0}/" + config.APP_NAME + ".so"
        DLL_COPY_FMT     :: "{0}/" + config.APP_NAME + "_{1}.so"
}
