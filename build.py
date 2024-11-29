import argparse
import subprocess
import sys
import os
import shutil

APP_NAME           = "callisto_app"
COMPANY_NAME       = "callisto_default_company"

ASSET_DIRECTORY    = "./assets"
CALLISTO_DIRECTORY = "./callisto"
OUT_DIRECTORY      = "./out"

# reload
# - App dll + debug symbols
#
# develop
# - App dll + debug symbols
# - Runner + debug symbols + hot reload
# - Copy assets
#
# debug
# - App dll + debug symbols
# - Runner + debug symbols
# - Copy assets
#
# release
# - App dll
# - Runner
# - Copy assets

parser = argparse.ArgumentParser()
parser.add_argument("config", nargs="?", const="reload", default="reload", choices=["reload", "develop", "debug", "release"])
parser.add_argument("-out", default=OUT_DIRECTORY, help="The output directory of compiled files")
args = parser.parse_args()

debug_symbols_enabled = args.config in ["reload", "develop", "debug"]
hot_reload_enabled    = args.config in ["reload", "develop"]
build_runner          = args.config in ["develop", "debug", "release"]
copy_assets           = args.config in ["develop", "debug", "release"]
hide_console          = args.config in ["release"] and sys.platform == "win32"

if os.path.basename(os.getcwd()) == "callisto":
    print("ERROR: build script called from callisto package. Call this script from the root directory of your project.")
    exit(1)

runner_dir     = os.path.normpath(os.path.join(CALLISTO_DIRECTORY, "runner"))
out_dir        = os.path.normpath(os.path.join(os.getcwd(), args.out))
data_dest_dir  = os.path.normpath(os.path.join(out_dir, "data"))

exe_ext        = ".exe" if sys.platform=="win32" else ""
dll_ext        = ".dll" if sys.platform=="win32" else ".so"


odin_debug_arg        = "-debug" if debug_symbols_enabled else ""
odin_hot_reload_arg   = "-define:HOT_RELOAD=true" if hot_reload_enabled else ""
odin_app_name_arg     = f"-define:APP_NAME={APP_NAME}"
odin_company_name_arg = f"-define:COMPANY_NAME={COMPANY_NAME}"
odin_subsystem_arg    = "-subsystem:windows" if hide_console else ""

asset_src_dir   = os.path.normpath(ASSET_DIRECTORY)
asset_dest_dir  = os.path.normpath(os.path.join(data_dest_dir, "assets"))
libs_src_subdir = "debug" if debug_symbols_enabled else "release"
libs_src_dir    = os.path.normpath(os.path.join(CALLISTO_DIRECTORY, "shipping_libs", libs_src_subdir))
libs_dest_dir   = os.path.normpath(os.path.join(data_dest_dir, "libs"))

COLOR_DIM = '\033[2;37m'
COLOR_END = '\033[0m'

ok = True

# Create output directory
if not os.path.exists(out_dir):
    try:
        print(f"Creating directory {out_dir}")
        os.makedirs(out_dir)
    except Exception as e:
        print(e)
        exit(1)

            


# Delete all exe-related files from output directory (not assets)
print("Args config: " + args.config)
if args.config != "reload":
    extensions_to_delete = [".exe", ".pdb", ".exp", ".rdi", ".dll", ".so", ".dynlib", ".lib"]
    try:
        if os.path.exists(data_dest_dir):
            shutil.rmtree(data_dest_dir)

        # TODO(RHI): only copy subdirs if built with the corresponding option, e.g. RHI="vulkan"
        shutil.copytree(libs_src_dir, libs_dest_dir)
        if os.path.exists(asset_src_dir):
            shutil.copytree(asset_src_dir, asset_dest_dir)

    except Exception as e:
        print(e)
        exit(1)

    for f in os.listdir(out_dir):
        _, ext = os.path.splitext(f)
        if ext in extensions_to_delete:
            os.remove(os.path.join(out_dir, f))


if build_runner:
    print("[+] Building runner")
    # odin build ./callisto/runner -debug -subsystem=windows -out=./out/callisto-app.exe -define:HOT_RELOAD=true -define:APP_NAME=callisto-app
    command = f"odin build {runner_dir} {odin_debug_arg} {odin_subsystem_arg} -out={os.path.join(out_dir, APP_NAME)}{exe_ext} {odin_hot_reload_arg} {odin_app_name_arg} {odin_company_name_arg}"
    print(COLOR_DIM + "    > " + command + COLOR_END)
    result = subprocess.run(command, cwd=os.getcwd(), stderr=sys.stderr, stdout=sys.stdout)
    if result.returncode != 0:
        print("\n[---] Failed to build runner")
        ok = False


print("\n[+] Building app DLL")
# odin build . -debug -build-mode=shared -out=./out/staging.dll -define:APP_NAME="callisto_application" -define:COMPANY_NAME="callisto_default_company"
#       && mv ./out/staging.dll ./out/game.dll
#       ^^^^^ Make sure file watcher doesn't pick it up before compilation is finished
staging_dll_name = os.path.join(out_dir, f"staging{dll_ext}")
out_dll_name = os.path.join(out_dir, f"{APP_NAME}{dll_ext}")

command = f"odin build . -build-mode=shared {odin_debug_arg} -out={staging_dll_name} {odin_app_name_arg} {odin_company_name_arg}"
print(COLOR_DIM + "    > " + command + COLOR_END)
result = subprocess.run(command, cwd=os.getcwd(), stderr=sys.stderr, stdout=sys.stdout)
if result.returncode == 0:
    print("[+] Renaming " + staging_dll_name + " -> " + out_dll_name)
    try:
        os.replace(staging_dll_name, out_dll_name)
    except Exception as e:
        print("\n[---] Failed to rename DLL: " + e)
        ok = False

else:
    print("\n[---] Failed to compile DLL")
    ok = False

if not ok:
    exit(1)

print("[+++] Compilation complete\n")
