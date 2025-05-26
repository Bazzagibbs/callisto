#!/bin/bash
# TODO: glf2_opengl3 opens in background
odin run sdl2_opengl3 && odin run glfw_opengl3 && odin run sdl2_directx11 && odin run null
# odin run glfw_wgpu (broken?)
# odin run sdl2_sdlrenderer2 (odin version too old)

