package callisto_config

ENGINE_VERSION_MAJOR      :: 0
ENGINE_VERSION_MINOR      :: 0
ENGINE_VERSION_PATCH      :: 1

APP_NAME                  :: #config(APP_NAME, "game")
APP_VERSION_MAJOR         :: #config(APP_VERSION_MAJOR, 0)
APP_VERSION_MINOR         :: #config(APP_VERSION_MINOR, 0)
APP_VERSION_PATCH         :: #config(APP_VERSION_PATCH, 1)

COMPANY_NAME              :: #config(COMPANY_NAME, "callisto_default_company")

SHIPPING_LIBS_PATH        :: #config(SHIPPING_LIBS_PATH, "data/libs")
ASSET_DB_PATH             :: #config(ASSET_DB_PATH, "data/assetdb")

VERBOSE                   :: ODIN_DEBUG || #config(VERBOSE, false)
PROFILER_ENABLED          :: #config(PROFILER_ENABLED, false)
PROFILER_FILENAME         :: #config(PROFILER_FILENAME, "profiler.spall")
PROFILER_REALTIME_HISTORY :: #config(PROFILER_REALTIME_HISORY, 144 * 10) // Approximately 10 seconds at vsync


RHI :: #config(RHI, "vulkan")

