#!/usr/bin/env python3
"""The click that brings a window to the front reaches the program: a canvas in a window that is not in front gets its $201, as
on Win32 in the original, so that a program can start dragging at once.

  focus_click.py BLITZCC WORKDIR

Needs an X server (run it under xvfb-run) and xdotool, which gives a window the focus and clicks into it right away, as a window
manager does on a click. Without them it is skipped (exit code 77).
"""
import os
import shutil
import subprocess
import sys
import time
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../tools"))
import procutil  # noqa: E402

SKIP = 77


def clicks(path):
    # The program replaces the file with CopyFile, which is not atomic: a read in the middle of it sees an empty file.
    for _ in range(20):
        try:
            with open(path) as f:
                text = f.read().strip()
            if text:
                return text.lstrip("-")
        except OSError:
            pass
        time.sleep(0.01)
    return None


def wait_for(condition, seconds):
    end = time.time() + seconds
    while time.time() < end:
        if condition():
            return True
        time.sleep(0.05)
    return False


def main():
    blitzcc, work = sys.argv[1], os.path.abspath(sys.argv[2])
    if not os.environ.get("DISPLAY") or not shutil.which("xdotool"):
        print("focus_click: there is no X server or no xdotool, so this is skipped.")
        return SKIP
    os.makedirs(work, exist_ok=True)
    source = os.path.join(os.path.dirname(os.path.abspath(__file__)), "focus_click.bb")
    exe = os.path.join(work, "focus_click")
    # BLITZCC_OPTIONS (for example "-d") adds options to the compiler, so that the test runs in Debug as well.
    procutil.run([blitzcc] + os.environ.get("BLITZCC_OPTIONS", "").split() + [source, "-o", exe], check=True, stdout=subprocess.DEVNULL)
    progress = os.path.join(work, "progress.txt")
    if os.path.exists(progress):
        os.remove(progress)
    env = dict(os.environ, BLITZLLVM_TEST_PROGRESS=progress, BLITZLLVM_TEST_SECONDS="20")
    env.pop("SDL_MOUSE_FOCUS_CLICKTHROUGH", None)  # The runtime's own choice is what is tested.
    program = procutil.Popen([exe], env=env, cwd=work)
    try:
        windows = {}

        def found():
            for name in ("A", "B"):
                if name not in windows:
                    out = procutil.run(["xdotool", "search", "--onlyvisible", "--name", f"^FocusClick{name}$"], capture_output=True, text=True).stdout.split()
                    if out:
                        windows[name] = out[0]
            return len(windows) == 2 and clicks(progress) is not None

        assert wait_for(found, 20), "the windows of the program were not found"

        # Each round puts one window in front, then gives the other the focus and clicks into its canvas in the same breath, as a
        # window manager does when a window that is not in front is clicked. Every one of those clicks has to arrive.
        expected = ""
        for front, target in (("A", "B"), ("B", "A"), ("A", "B")):
            procutil.run(["xdotool", "windowfocus", "--sync", windows[front]], check=True)
            time.sleep(0.3)
            procutil.run(["xdotool", "windowfocus", "--sync", windows[target], "mousemove", "--window", windows[target], "100", "75", "click", "1"], check=True)
            expected += target
            assert wait_for(lambda: clicks(progress) == expected, 5), f"the click that gave window {target} the focus was lost: clicks {clicks(progress)!r}, expected {expected!r}"
            time.sleep(0.2)

        # A click into the window that already has the focus arrives as well, of course.
        procutil.run(["xdotool", "mousemove", "--window", windows[target], "120", "80", "click", "1"], check=True)
        expected += target
        assert wait_for(lambda: clicks(progress) == expected, 5), f"a click into the window in front was lost: clicks {clicks(progress)!r}, expected {expected!r}"
    finally:
        program.kill()
        program.wait()
    print("focus_click: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
