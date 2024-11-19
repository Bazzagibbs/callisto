import argparse
import subprocess
import sys
import os

APP_NAME           = "callisto_app"
COMPANY_NAME       = "callisto_default_company"

ASSET_DIRECTORY    = "./assets"
CALLISTO_DIRECTORY = "./callisto"
OUT_DIRECTORY      = "./out"

# all
# - App dll + debug symbols
# - Runner + debug symbols
# - Copy assets
#
# release
# - App dll
# - Runner
# - Copy assets

parser = argparse.ArgumentParser()
parser.add_argument("config", nargs="?", const="reload", default="reload", choices=["reload", "all", "release"])
parser.add_argument("-out", default=OUT_DIRECTORY, help="The output directory of compiled files")
args = parser.parse_args()

debug_symbols_enabled = args.config in ["reload", "all"]
hot_reload_enabled    = args.config in ["reload", "all"]
build_runner          = args.config in ["all", "release"]
copy_assets           = args.config in ["all", "release"]

if os.path.basename(os.getcwd()) == "callisto":
    print("ERROR: build script called from callisto package. Call this script from the root directory of your project.")
    exit(1)

runner_dir            = os.path.normpath(os.path.join(CALLISTO_DIRECTORY, "runner"))
out_dir               = os.path.normpath(os.path.join(os.getcwd(), args.out))
exe_ext               = ".exe" if sys.platform == "win32" else ""
dll_ext               = ".dll" if sys.platform == "win32" else ".so"

odin_debug_arg        = "-debug" if debug_symbols_enabled else ""
odin_hot_reload_arg   = "-define:HOT_RELOAD=true" if hot_reload_enabled else ""
odin_app_name_arg     = f"-define:APP_NAME={APP_NAME}"
odin_company_name_arg = f"-define:COMPANY_NAME={COMPANY_NAME}"

COLOR_DIM = '\033[2;37m'
COLOR_END = '\033[0m'

# Create output directory
if not os.path.exists(out_dir):
    print(f"Creating directory {out_dir}")
    os.makedirs(out_dir)


# Delete all exe-related files from output directory (not assets)
if args.config != "reload":
    extensions_to_delete = [".exe", ".pdb", ".exp", ".rdi", ".dll", ".so", ".dynlib", ".lib"]
    for f in os.listdir(out_dir):
        _, ext = os.path.splitext(f)
        if ext in extensions_to_delete:
            os.remove(os.path.join(out_dir, f))


if build_runner:
    print("[+] Building runner")
    # odin build ./callisto/runner -debug -out=./out/callisto-app.exe -define:HOT_RELOAD=true -define:APP_NAME=callisto-app
    command = f"odin build {runner_dir} {odin_debug_arg} -out={os.path.join(out_dir, APP_NAME)}{exe_ext} {odin_hot_reload_arg} {odin_app_name_arg} {odin_company_name_arg}"
    print(COLOR_DIM + "    > " + command + COLOR_END)
    result = subprocess.run(command, cwd=os.getcwd(), stderr=sys.stderr, stdout=sys.stdout)
    if result.returncode != 0:
        print("\n[---] Failed to build runner")


print("\n[+] Building app DLL")
# odin build . -debug -build-mode=shared -out=./out/staging.dll -define:GAME_NAME="game" 
#       && mv ./out/staging.dll ./out/game.dll
#       ^^^^^ Make sure file watcher doesn't pick it up before compilation is finished
staging_dll_name = os.path.join(out_dir, f"staging{dll_ext}")
out_dll_name = os.path.join(out_dir, f"{APP_NAME}{dll_ext}")

command = f"odin build . -build-mode=shared {odin_debug_arg} -out={staging_dll_name} {odin_app_name_arg} {odin_company_name_arg}"
print(COLOR_DIM + "    > " + command + COLOR_END)
result = subprocess.run(command, cwd=os.getcwd(), stderr=sys.stderr, stdout=sys.stdout)
if result.returncode == 0:
    print("Renaming " + staging_dll_name + " -> " + out_dll_name)
    os.replace(staging_dll_name, out_dll_name)

else:
    print("\n[---] Failed to compile DLL")


