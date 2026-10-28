#!/usr/bin/env python3
"""The sample programs and games that came with the original Blitz3D and BlitzPlus (the extra/blitz3d and extra/blitzplus_msvc2017 submodules).

  original_programs.py list                    Print the programs, one per line (file names are relative to extra/)
  original_programs.py compile-one BLITZCC PROGRAM OUT   Compile one program, print the output of the compiler when it fails
  original_programs.py run-one OUT PROGRAM     Run a compiled program without a window (BLITZ_HEADLESS=1) for a few seconds: still running or exit code 0 is a pass
  original_programs.py compile BLITZCC [OUT]   Compile every program with BLITZCC, print a pass/fail list and the first error of each failure

A program is a .bb file that no other .bb file of the same tree includes; the files that it includes are part of it.
"""
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "."))
import procutil  # noqa: E402

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "extra"))
TREES = [
    "blitz3d/_release/samples",
    "blitz3d/_release/Games",
    "blitzplus_msvc2017/_release/samples",
    "blitzplus_msvc2017/_release/games",
]
INCLUDE = re.compile(r'^\s*include\s+"([^"]+)"', re.IGNORECASE | re.MULTILINE)


def resolve(base, name):
    """Find a file below base the way Windows would, ignoring the case of every path component."""
    path = base
    for part in name.replace("\\", "/").split("/"):
        if part in ("", "."):
            continue
        if part == "..":
            path = os.path.dirname(path)
            continue
        try:
            entries = os.listdir(path)
        except OSError:
            return None
        match = next((e for e in entries if e.lower() == part.lower()), None)
        if match is None:
            return None
        path = os.path.join(path, match)
    return path


def programs():
    """Every program in TREES as a path relative to ROOT, sorted."""
    result = []
    for tree in TREES:
        top = os.path.join(ROOT, tree)
        files = [os.path.join(d, f) for d, _, fs in os.walk(top) for f in fs if f.lower().endswith(".bb")]
        included = set()
        for f in files:
            with open(f, "r", encoding="latin-1") as handle:
                for name in INCLUDE.findall(handle.read()):
                    target = resolve(os.path.dirname(f), name)
                    if target:
                        included.add(os.path.normcase(os.path.realpath(target)))
        result += [os.path.relpath(f, ROOT) for f in files if os.path.normcase(os.path.realpath(f)) not in included]
    return sorted(result, key=str.lower)


def exe_path(out, program):
    return os.path.join(out, re.sub(r"[^A-Za-z0-9_.-]", "_", program) + ".exe")


def snapshot(folder):
    """The files below folder with their contents, so that what a program writes there can be undone."""
    files = {}
    for directory, _, names in os.walk(folder):
        for name in names:
            path = os.path.join(directory, name)
            with open(path, "rb") as handle:
                files[path] = handle.read() if os.path.getsize(path) <= 1 << 20 else None
    return files


def restore(folder, files):
    for directory, _, names in os.walk(folder):
        for name in names:
            path = os.path.join(directory, name)
            if path not in files:
                os.remove(path)
    for path, data in files.items():
        if data is not None and (not os.path.exists(path) or open(path, "rb").read() != data):
            with open(path, "wb") as handle:
                handle.write(data)


def run_one(out, program, seconds=5):
    """Programs of the originals are games and demos that loop until a key is pressed, so one that is still running after a few
    seconds without a window has got past its start and counts as good. One that stops with an error, or crashes, does not.
    Some write their settings or scores next to themselves, and what they find there changes what they do, so the folder is put back
    afterwards. Programs of one folder must not run at the same time. Requesters (RequestFont, RequestColor) are accepted as they start."""
    source = os.path.join(ROOT, program)
    folder = os.path.dirname(source)
    env = dict(os.environ, BLITZ_HEADLESS="1", BLITZ_DIALOG_ANSWER="0")  # Requesters are accepted as they start.
    files = snapshot(folder)
    try:
        run = procutil.run([exe_path(out, program)], cwd=folder, env=env, capture_output=True, text=True, timeout=seconds, stdin=subprocess.DEVNULL)
    except subprocess.TimeoutExpired:
        return True, "still running"
    finally:
        restore(folder, files)
    return run.returncode == 0, (run.stdout + run.stderr).strip()


def compile_one(blitzcc, program, out):
    exe = exe_path(out, program)
    source = os.path.join(ROOT, program)
    try:
        run = procutil.run([blitzcc, source, "-o", exe], cwd=os.path.dirname(source), capture_output=True, text=True, timeout=300)
        text = (run.stdout + run.stderr).strip()
        return program, run.returncode == 0, text
    except subprocess.TimeoutExpired:
        return program, False, "timeout"


def main(argv):
    if len(argv) >= 2 and argv[1] == "list":
        print("\n".join(programs()))
        return 0
    if len(argv) == 5 and argv[1] == "compile-one":
        os.makedirs(argv[4], exist_ok=True)
        _, ok, text = compile_one(os.path.abspath(argv[2]), argv[3], os.path.abspath(argv[4]))
        if not ok:
            print(text)
        return 0 if ok else 1
    if len(argv) == 4 and argv[1] == "run-one":
        ok, text = run_one(os.path.abspath(argv[2]), argv[3])
        if not ok:
            print(text)
        return 0 if ok else 1
    if len(argv) >= 3 and argv[1] == "compile":
        out = argv[3] if len(argv) > 3 else "original_programs_out"
        os.makedirs(out, exist_ok=True)
        with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as pool:
            results = list(pool.map(lambda p: compile_one(os.path.abspath(argv[2]), p, os.path.abspath(out)), programs()))
        failed = [r for r in results if not r[1]]
        for program, ok, text in results:
            print(("PASS " if ok else "FAIL ") + program)
            if not ok:
                lines = [l for l in text.splitlines() if l.strip()]
                print("     " + (lines[-1] if lines else "(no output)"))
        print(f"{len(results) - len(failed)}/{len(results)} compile")
        return 1 if failed else 0
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
