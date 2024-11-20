package callisto

APP_NAME                  :: #config(APP_NAME, "game")
COMPANY_NAME              :: #config(COMPANY_NAME, "callisto_default_company")

VERBOSE                   :: ODIN_DEBUG || #config(VERBOSE, false)
PROFILER                  :: #config(PROFILER, false)
PROFILER_FILE             :: #config(PROFILER_FILE, "profiler.spall")
PROFILER_REALTIME_HISTORY :: #config(PROFILER_REALTIME_HISORY, 144 * 5) // Approximately 5 seconds at vsync

