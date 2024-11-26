package callisto

APP_NAME                  :: #config(APP_NAME, "game")
COMPANY_NAME              :: #config(COMPANY_NAME, "callisto_default_company")

VERBOSE                   :: ODIN_DEBUG || #config(VERBOSE, false)
PROFILER_ENABLED          :: #config(PROFILER_ENABLED, false)
PROFILER_FILENAME         :: #config(PROFILER_FILENAME, "profiler.spall")
PROFILER_REALTIME_HISTORY :: #config(PROFILER_REALTIME_HISORY, 144 * 10) // Approximately 10 seconds at vsync

