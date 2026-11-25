#!/usr/bin/env python3
"""
Builds benchmarks/spacebattle.bb with blitzcc, runs it and prints the frame times and what each part of a frame costs: a space
battle of two fleets with stations, asteroids, planets and traders, for the game code, picking, collisions and physics. The result
is also saved as JSON (and added to a CSV) in benchmarks/results/.

    python3 benchmarks/spacebattle.py [--ships N] [--asteroids N] [--debris N] [common options, see --help]

--ships defaults to $BENCH_SHIPS or 2000, --asteroids to 1500, --debris (the most pieces at once) to 2000, --frames to
$BENCH_FRAMES or 3000, --warmup to 30; "--quick" is 200 ships, 150 asteroids and 60 frames for a look whether it works. -d builds
without optimization; the build configuration is part of the result so runs are not mixed up.

The original Blitz3D works too, so that its speed can be compared: --blitzcc C:\\Blitz3D\\bin\\blitzcc.exe (BLITZPATH is set to the
folder with bin\\ in it unless it is set). It has no -O3, no --profile, no draw counters (they are 0) and no physics: its debris
fly in straight lines and physics_ms is 0.

Without a display the program runs under xvfb-run, which with Mesa means llvmpipe: the times are then mostly the CPU
rasterizing and only a smoke test.
"""
import os
import benchutil


def main():
    runner = benchutil.Runner("spacebattle", __doc__, frames=3000, quick_frames=60, warmup=30)
    parser = runner.parser
    parser.add_argument("--ships", type=int, default=int(os.environ.get("BENCH_SHIPS", 2000)))
    parser.add_argument("--asteroids", type=int, default=int(os.environ.get("BENCH_ASTEROIDS", 1500)))
    parser.add_argument("--debris", type=int, default=int(os.environ.get("BENCH_DEBRIS", 2000)), help="the most pieces of debris at once")
    args = runner.parse()
    if args.quick:
        args.ships, args.asteroids = 200, 150
    env = {"BENCH_SHIPS": args.ships, "BENCH_ASTEROIDS": args.asteroids, "BENCH_DEBRIS": args.debris}
    v = runner.run(env, "%d ships, %d asteroids" % (args.ships, args.asteroids))
    runner.report(["scene       %d ships (%d alive on average), %d asteroids, debris up to %d%s"
                   % (v["ships"], v["alive"], v["asteroids"], v["debriscap"], "" if v["physics"] else " (no physics)"),
                   "parts       ai %.2f  picks %.2f  effects %.2f  collisions %.2f  physics %.2f  render %.2f ms/frame"
                   % (v["ai_ms"], v["pick_ms"], v["effects_ms"], v["collide_ms"], v["physics_ms"], v["render_ms"]),
                   "objects     %.0f bolts, %.0f pieces of debris per frame" % (v["bolts"], v["debris"]),
                   "game        %d kills, %d shots (%d hits), %d line of sight checks (%d blocked), %d ship collisions, %d of %d camera picks hit"
                   % (v["kills"], v["shots"], v["hits"], v["los"], v["los_blocked"], v["collided"], v["camera_hits"], v["camera_picks"])],
                  update="ai, picks, effects, collisions and physics")
    runner.save(str(args.ships), ("ships", "asteroids", "debriscap", "physics", "ai_ms", "pick_ms", "effects_ms", "collide_ms", "physics_ms", "render_ms",
                                  "alive", "bolts", "debris", "kills", "respawns", "shots", "hits", "los", "los_blocked", "collided", "camera_picks",
                                  "camera_hits", "debris_made"))


if __name__ == "__main__":
    main()
