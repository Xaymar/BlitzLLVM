#!/usr/bin/env python3
"""
Builds benchmarks/spacebattle.bb with blitzcc, runs it and prints the frame times and what each part of a frame costs: a space
battle of two fleets with stations, asteroids, planets and traders, for the game code, picking, collisions and physics. The result
is also saved as JSON (and added to a CSV) in benchmarks/results/.

    python3 benchmarks/spacebattle.py [--blitzcc PATH] [--ships N] [--asteroids N] [--debris N] [--frames N] [--seed N] [--size WxH]
                                      [--depth N] [--gpu N] [--debug] [--profile] [--label NAME] [--shot FILE] [--no-save]

--ships defaults to $BENCH_SHIPS or 2000, --asteroids to 1500, --debris (the most pieces at once) to 2000, --frames to
$BENCH_FRAMES or 3000; "--quick" is 200 ships, 150 asteroids and 60 frames for a look whether it works. -d builds without
optimization; the build configuration is part of the result so runs are not mixed up.

The original Blitz3D works too, so that its speed can be compared: --blitzcc C:\\Blitz3D\\bin\\blitzcc.exe (BLITZPATH is set to the
folder with bin\\ in it unless it is set). It has no -O3, no --profile, no draw counters (they are 0) and no physics: its debris
fly in straight lines and physics_ms is 0.

Without a display the program runs under xvfb-run, which with Mesa means llvmpipe: the times are then mostly the CPU
rasterizing and only a smoke test.
"""
import argparse
import csv
import datetime
import json
import os
import platform
import re
import shutil
import sys
import tempfile
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "../tools"))
import procutil  # noqa: E402
import benchutil  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


# Direct3D 7 limits the window to 2048 in each direction (measured on Areldir: 2048x2048 works, 2049x1080 and 500x3000 fail): the original Blitz3D then stops with
# "Unable to create 3D Scene".
ORIGINAL_MAX_SIZE = 2048

def find_compiler(given):
    if given:
        return given
    for candidate in (os.path.join(ROOT, "build", "code_compiler", "blitzcc"), os.path.join(ROOT, "build", "code_compiler", "blitzcc.exe"),
                      os.path.join(ROOT, "build", "distrib", "bin", "blitzcc.exe")):
        if os.path.isfile(candidate):
            return candidate
    return shutil.which("blitzcc") or sys.exit("blitzcc not found, build it or pass --blitzcc.")


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--blitzcc")
    parser.add_argument("--ships", type=int, default=int(os.environ.get("BENCH_SHIPS", 2000)))
    parser.add_argument("--asteroids", type=int, default=int(os.environ.get("BENCH_ASTEROIDS", 1500)))
    parser.add_argument("--debris", type=int, default=int(os.environ.get("BENCH_DEBRIS", 2000)), help="the most pieces of debris at once")
    parser.add_argument("--frames", type=int, default=int(os.environ.get("BENCH_FRAMES", 3000)))
    parser.add_argument("--seed", type=int, default=int(os.environ.get("BENCH_SEED", 1)))
    parser.add_argument("--size", default=os.environ.get("BENCH_SIZE", "640x360"))
    parser.add_argument("--depth", type=int, default=int(os.environ.get("BENCH_DEPTH", 0)), help="colour depth for Graphics3D (0: the default)")
    parser.add_argument("--gpu", type=int, default=int(os.environ.get("BENCH_GPU", 0)), help="graphics driver for SetGfxDriver (0: the default)")
    parser.add_argument("--quick", action="store_true", help="200 ships, 150 asteroids, 60 frames")
    parser.add_argument("--debug", action="store_true", help="build with -d (no optimization)")
    parser.add_argument("--profile", action="store_true", help="build with --profile, for BLITZLLVM_PROFILE_FPS=1")
    parser.add_argument("--label", default="", help="name of this run in the result, such as the GPU")
    parser.add_argument("--shot", help="save the last frame to this file")
    parser.add_argument("--no-save", action="store_true", help="don't write benchmarks/results/")
    args = parser.parse_args()
    if args.quick:
        args.ships, args.asteroids, args.frames = 200, 150, 60
    width, height = args.size.lower().split("x")

    compiler = find_compiler(args.blitzcc)
    # The original Blitz3D prints only a version number for -v and has no optimization level or profiling, BlitzLLVM prints
    # "Compiler version:...". The same program is built with either, so that their speeds can be compared.
    version = " ".join(procutil.run([compiler, "-v"], capture_output=True, text=True).stdout.split())
    llvm = bool(re.search(r"Compiler version:20\d\d\.", version))
    flags = ["-d"] if args.debug else (["-O3"] if llvm else [])
    if args.profile and llvm:
        flags.append("--profile")
    if not llvm and (int(width) > ORIGINAL_MAX_SIZE or int(height) > ORIGINAL_MAX_SIZE):
        sys.exit("The original Blitz3D (Direct3D 7) cannot open a window above %dx%d (asked for %sx%s)." % (ORIGINAL_MAX_SIZE, ORIGINAL_MAX_SIZE, width, height))
    if not llvm:
        # The original compiler reads its runtime and libraries from BLITZPATH, the folder that has bin\ in it.
        os.environ.setdefault("BLITZPATH", os.path.dirname(os.path.dirname(os.path.abspath(compiler))))
        version = " ".join(procutil.run([compiler, "-v"], capture_output=True, text=True).stdout.split())
    runner = [] if os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY") or platform.system() == "Windows" else ["xvfb-run", "-a", "-s", "-screen 0 %sx%sx24" % (width, height)]
    if runner and not shutil.which("xvfb-run"):
        sys.exit("There is no display and no xvfb-run.")

    with tempfile.TemporaryDirectory() as directory:
        program = benchutil.program_path(directory)
        # Compiled from a copy with the include of this compiler next to it, whatever folder the original compiler resolves
        # includes from.
        source = os.path.join(directory, "spacebattle.bb")
        shutil.copy(os.path.join(HERE, "spacebattle.bb"), source)
        shutil.copy(os.path.join(HERE, "spacebattle_llvm.bi" if llvm else "spacebattle_original.bi"), os.path.join(directory, "spacebattle_counters.bi"))
        build = procutil.run([compiler, "-q"] + flags + ["-o", program, source], cwd=directory, capture_output=True, text=True)
        if build.returncode != 0:
            sys.exit("Building the benchmark failed (exit code %d):\n%s" % (build.returncode, (build.stdout + build.stderr)[-2000:]))
        env = dict(os.environ, BENCH_SHIPS=str(args.ships), BENCH_ASTEROIDS=str(args.asteroids), BENCH_DEBRIS=str(args.debris), BENCH_FRAMES=str(args.frames),
                   BENCH_SEED=str(args.seed), BENCH_W=width, BENCH_H=height, BENCH_DEPTH=str(args.depth), BENCH_GPU=str(args.gpu),
                   BENCH_FRAMETIMES=os.path.join(directory, "frametimes.txt"), BENCH_RESULT=os.path.join(directory, "result.txt"))
        if args.profile and llvm:
            env["BLITZLLVM_PROFILE_FPS"] = "1"
        if args.shot:
            env["BENCH_SHOT"] = os.path.abspath(args.shot)
        print("Running %d ships, %d asteroids, %d frames, %sx%s, build %s" % (args.ships, args.asteroids, args.frames, width, height, " ".join(flags)), flush=True)
        result = procutil.run(runner + [program], env=env, capture_output=True, text=True)
        output = result.stdout + result.stderr
        # The original Blitz3D has no stdout for a program, so the result is read from a file.
        line = None
        if os.path.isfile(env["BENCH_RESULT"]):
            line = next((l for l in open(env["BENCH_RESULT"]).read().splitlines() if "RESULT " in l), None)
        if result.returncode != 0 or line is None:
            sys.exit("The benchmark failed (exit code %d):\n%s" % (result.returncode, output[-2000:]))
        values = {k: float(v) for k, v in re.findall(r"(\w+)=([-+\d.eE]+)", line.split("RESULT ", 1)[1])}
        frametimes = []
        if os.path.isfile(env["BENCH_FRAMETIMES"]):
            frametimes = [int(l) for l in open(env["BENCH_FRAMETIMES"]).read().split()]

    record = {
        "date": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
        "label": args.label,
        "compiler": version if llvm else "Blitz3D " + version,
        "build": " ".join(flags),
        "platform": platform.platform(),
        "display": "xvfb" if runner else "native",
        "result": values,
    }
    v = values
    print("\n  scene       %d ships (%d alive on average), %d asteroids, debris up to %d%s" % (v["ships"], v["alive"], v["asteroids"], v["debriscap"], "" if v["physics"] else " (no physics)"))
    print("  created in  %12.0f ms" % v["create_ms"])
    print("  ms/frame    avg %.2f  min %.2f  median %.2f  p95 %.2f  max %.2f" % (v["ms_avg"], v["ms_min"], v["ms_median"], v["ms_p95"], v["ms_max"]))
    print("  fps         %12.1f" % v["fps"])
    print("  parts       ai %.2f  picks %.2f  effects %.2f  collisions %.2f  physics %.2f  render %.2f ms/frame"
          % (v["ai_ms"], v["pick_ms"], v["effects_ms"], v["collide_ms"], v["physics_ms"], v["render_ms"]))
    print("  per frame   %.0f triangles, %.0f draw calls, %.0f bolts, %.0f pieces of debris" % (v["tris"], v["draws"], v["bolts"], v["debris"]))
    print("  game        %d kills, %d shots (%d hits), %d line of sight checks (%d blocked), %d ship collisions, %d of %d camera picks hit"
          % (v["kills"], v["shots"], v["hits"], v["los"], v["los_blocked"], v["collided"], v["camera_hits"], v["camera_picks"]))
    print("  build       %s (%s)" % (record["build"] or "no options", version or "unknown compiler"))

    if not args.no_save:
        out = os.path.join(HERE, "results")
        os.makedirs(out, exist_ok=True)
        stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        name = "spacebattle-%s-%d" % (stamp, args.ships)
        with open(os.path.join(out, name + ".json"), "w") as f:
            json.dump(dict(record, frame_times_us=frametimes), f, indent=1)
        columns = ["ships", "asteroids", "debriscap", "physics", "frames", "seed", "ai_ms", "pick_ms", "effects_ms", "collide_ms", "physics_ms", "render_ms",
                   "ms_avg", "ms_min", "ms_median", "ms_p95", "ms_max", "fps", "tris", "draws", "kills", "shots", "hits", "los", "collided"]
        csv_path = os.path.join(out, "spacebattle.csv")
        new = not os.path.isfile(csv_path)
        with open(csv_path, "a", newline="") as f:
            writer = csv.writer(f)
            if new:
                writer.writerow(["date", "label", "build", "display"] + columns)
            writer.writerow([record["date"], args.label, record["build"], record["display"]] + [v[k] for k in columns])
        print("  saved       benchmarks/results/%s.json and spacebattle.csv" % name)


main()
