#!/usr/bin/env python3
# Helpers shared by the benchmark runners.
#
# Every benchmark program is built under a random file name. Windows (Auto HDR, the game detection of Game Bar) and graphics drivers
# (NVIDIA and AMD application profiles) pick settings by the name of the executable, and a known name such as dungeon.exe can get a
# frame rate cap or a different present path that has nothing to do with the program: on a 180 Hz HDR display, Windows turned Auto HDR
# on for dungeon.exe, and dungeon.exe and bigmesh.exe were held to the refresh rate with BlitzLLVM and the original Blitz3D alike.
import os
import platform
import secrets


def program_name():
    """A file name, without extension, that no program, game or driver profile has: a letter and 12 random hex digits."""
    return "b" + secrets.token_hex(6)


def program_path(directory, exe=None):
    """Where to build a benchmark program in directory, under a random name (.exe on Windows, or when exe is true)."""
    if exe is None:
        exe = platform.system() == "Windows"
    return os.path.join(directory, program_name() + (".exe" if exe else ""))
