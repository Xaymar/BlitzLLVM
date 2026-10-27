#!/usr/bin/env python3
"""The sample programs and games that came with the original Blitz3D and BlitzPlus (the extra/blitz3d and extra/blitzplus_msvc2017 submodules).

  original_programs.py list                    Print the programs, one per line (file names are relative to extra/)
  original_programs.py compile-one BLITZCC PROGRAM OUT   Compile one program, print the output of the compiler when it fails
  original_programs.py compile BLITZCC [OUT]   Compile every program with BLITZCC, print a pass/fail list and the first error of each failure

A program is a .bb file that no other .bb file of the same tree includes; the files that it includes are part of it.
"""
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

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


def compile_one(blitzcc, program, out):
    exe = os.path.join(out, re.sub(r"[^A-Za-z0-9_.-]", "_", program) + ".exe")
    source = os.path.join(ROOT, program)
    try:
        run = subprocess.run([blitzcc, source, "-o", exe], cwd=os.path.dirname(source), capture_output=True, text=True, timeout=300)
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
