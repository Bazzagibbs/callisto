import argparse
import subprocess
import sys
import os
import re

# This build script is only a little bit complicated because it handles three different use cases cross-platform.
# An alternative would be to create platform-specific build scripts for each config.
# Standalone config:
#   - Build ./callisto/runner with -define:HOT_RELOAD=false
# Runner + DLL config:
#   - Build ./callisto/runner with -define:HOT_RELOAD=true
#   - Build . with -build-mode:dll
# Game DLL only (for hot reloading):
#   - Build . with -build-mode:dll

parser = argparse.ArgumentParser()
parser.add_argument("config", nargs="?", const="reload", default="reload", choices=["reload", "runner", "all", "standalone"])
parser.add_argument("-debug", action="store_true")
parser.add_argument("-out", default="./out/", help="The output directory of compiled files")
parser.add_argument("-name", default="game", help="The base name, without file extension, of the game executable")
parser.add_argument("-callisto", default="./callisto", help="The relative directory of the Callisto package")
args = parser.parse_args()

debug_symbols_enabled = args.config in set(["reload", "runner", "all"]) or args.debug
build_standalone = args.config == "standalone"
build_dll = args.config in set(["reload", "all"])
build_runner = args.config in set(["runner", "all"])

runner_dir = os.path.join(args.callisto, "runner")
runner_dir = os.path.normpath(runner_dir)
out_dir = os.path.join(os.getcwd(), args.out)
out_dir = os.path.normpath(out_dir)
exe_ext = ".exe" if sys.platform == "win32" else ""
dll_ext = ".dll" if sys.platform == "win32" else ".so"
odin_debug_arg = "-debug" if debug_symbols_enabled else ""

# Create output directory
if not os.path.exists(out_dir):
    print(f"Creating directory {out_dir}")
    os.makedirs(out_dir)


# Delete all old hot-reload copies of the game dll
if args.config != "reload":
    pattern = r".*_\d*" + dll_ext
    dll_re = re.compile(pattern)
    for f in os.listdir(out_dir):
        if dll_re.match(f):
            os.remove(os.path.join(out_dir, f))


if build_standalone:
    print("Building standalone" + odin_debug_arg)
    # odin build ./callisto/runner -debug -out=./out/game.exe
    command = f"odin build {runner_dir} {odin_debug_arg} -out={os.path.join(out_dir, args.name)}{exe_ext}"
    print(command)
    subprocess.run(command, cwd=os.getcwd(), stderr=sys.stderr, stdout=sys.stdout)


if build_dll:
    print("Building game DLL")
    # odin build . -debug -out=./out/staging.dll && mv ./out/staging.dll ./out/game.dll
    #                                                 ^^^^^ Make sure file watcher doesn't pick it up before compilation is finished
    staging_dll_name = os.path.join(out_dir, f"staging{dll_ext}")
    out_dll_name = os.path.join(out_dir, f"{args.name}{dll_ext}")

    command = f"odin build . -build-mode=dll {odin_debug_arg} -out={staging_dll_name}"
    print(command)
    result = subprocess.run(command, cwd=os.getcwd(), stderr=sys.stderr, stdout=sys.stdout)
    if result.returncode == 0:
        os.replace(staging_dll_name, out_dll_name)

    else:
        print("Failed to compile DLL")


if build_runner:
    print("Building runner")
    # odin build ./callisto/runner -debug -out=./out/game.exe -define:HOT_RELOAD=true
    command = f"odin build {runner_dir} {odin_debug_arg} -out={os.path.join(out_dir, args.name)}{exe_ext} -define:HOT_RELOAD=true -define:GAME_NAME={args.name}"
    print(command)
    subprocess.run(command, cwd=os.getcwd(), stderr=sys.stderr, stdout=sys.stdout)
