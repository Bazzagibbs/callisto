package callisto_config

ENGINE_VERSION_MAJOR      :: 0
ENGINE_VERSION_MINOR      :: 0
ENGINE_VERSION_PATCH      :: 1

APP_NAME                  :: #config(APP_NAME, "game")
APP_VERSION_MAJOR         :: #config(APP_VERSION_MAJOR, 0)
APP_VERSION_MINOR         :: #config(APP_VERSION_MINOR, 0)
APP_VERSION_PATCH         :: #config(APP_VERSION_PATCH, 1)

COMPANY_NAME              :: #config(COMPANY_NAME, "callisto_default_company")

SHIPPING_LIBS_PATH        :: "data/libs"
ASSET_DB_PATH             :: "data/assets"

VERBOSE                   :: ODIN_DEBUG || #config(VERBOSE, false)

NO_LOG_FILE               :: #config(NO_LOG_FILE, false)
LOG_FILE_MAX_SIZE         :: #config(LOG_MAX_FILE_SIZE, 10_000_000) // 10 MB x 2 files
// LOG_FILE_MAX_SIZE      :: #config(LOG_MAX_FILE_SIZE, 10_000) // 10 KB for testing

PROFILER_ENABLED          :: #config(PROFILER_ENABLED, false)
PROFILER_FILENAME         :: #config(PROFILER_FILENAME, "profiler.spall")
PROFILER_REALTIME_HISTORY :: #config(PROFILER_REALTIME_HISORY, 144 * 10) // Approximately 10 seconds at vsync


RHI :: #config(RHI, "vulkan")

