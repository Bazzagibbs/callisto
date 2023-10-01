@echo off
zig build-lib mikktspace.c -lc -target x86_64-linux -femit-bin=../linux/mikktspace.a
zig build-lib mikktspace.c -lc -target x86_64-macos -femit-bin=../macos/mikktspace.a
zig build-lib mikktspace.c -lc -target x86_64-windows -femit-bin=../windows/mikktspace.lib
zig build-lib mikktspace.c -lc -target aarch64-macos -femit-bin=../macos-arm64/mikktspace.a
