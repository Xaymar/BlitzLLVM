#!/usr/bin/env python3
# report.py - summarises the output of sampler.exe.
# Usage: py report.py <prefix> [windows.txt] > report.txt
#   windows.txt: optional lines "name<TAB>start_ms<TAB>end_ms" (time since the sampler started); one report section per window.
# Also writes <prefix>.main.folded (collapsed stacks of the main thread, for flamegraph.pl / speedscope).
import sys
from collections import Counter, defaultdict

prefix = sys.argv[1]
syms = {}
with open(prefix + ".sym", encoding="utf-8", errors="replace") as f:
    for line in f:
        i, _, name = line.rstrip("\n").partition("\t")
        syms[int(i)] = name
threads = {}
main_tid = None
with open(prefix + ".thr", encoding="utf-8", errors="replace") as f:
    for line in f:
        if line.startswith("#"):
            main_tid = int(line.rsplit(" ", 1)[1])
            continue
        parts = line.rstrip("\n").split("\t")
        threads[int(parts[0])] = parts[1]

windows = [("whole run", 0, 1 << 62)]
if len(sys.argv) > 2:
    with open(sys.argv[2], encoding="utf-8") as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                n, s, e = line.rstrip("\n").split("\t")
                windows.append((n, int(s), int(e)))


def module(name):
    return name.split("!", 1)[0]


def section(title, samples):
    print("=" * 100)
    print(title)
    print("=" * 100)
    if not samples:
        print("(no samples)")
        return
    per_thread = Counter()
    main_idle = 0
    main_total = 0
    for t, tid, idle, st in samples:
        if tid == main_tid:
            main_total += 1
            main_idle += idle
        if not idle:
            per_thread[tid] += 1
    span = (samples[-1][0] - samples[0][0]) / 1000.0 or 1
    print(f"span {span:.1f} s, main thread samples {main_total} ({main_idle} while not using CPU = {100.0 * main_idle / max(1, main_total):.1f}%)")
    print("busy samples per thread (thread start function):")
    for tid, c in per_thread.most_common(25):
        print(f"  {c:8d}  tid {tid:6d}  {threads.get(tid, '?')}{'  (main)' if tid == main_tid else ''}")
    for label, sel in (("MAIN THREAD (all samples, waits included)", lambda tid, idle: tid == main_tid),
                       ("MAIN THREAD (busy only)", lambda tid, idle: tid == main_tid and not idle),
                       ("OTHER THREADS (busy only)", lambda tid, idle: tid != main_tid and not idle)):
        excl = Counter()
        incl = Counter()
        mods = Counter()
        n = 0
        for t, tid, idle, st in samples:
            if not sel(tid, idle):
                continue
            n += 1
            names = [syms.get(i, "?") for i in st]
            excl[names[0]] += 1
            mods[module(names[0])] += 1
            for nm in set(names):
                incl[nm] += 1
        print("-" * 100)
        print(f"{label}: {n} samples")
        if not n:
            continue
        print("  by module (exclusive):")
        for m, c in mods.most_common(15):
            print(f"    {100.0 * c / n:6.2f}%  {m}")
        print("  top exclusive:")
        for nm, c in excl.most_common(60):
            print(f"    {100.0 * c / n:6.2f}%  {nm}")
        print("  top inclusive:")
        for nm, c in incl.most_common(60):
            print(f"    {100.0 * c / n:6.2f}%  {nm}")


samples = []
with open(prefix + ".smp") as f:
    for line in f:
        p = line.split()
        if len(p) < 4:
            continue
        samples.append((int(p[0]), int(p[1]), int(p[2]), [int(x) for x in p[3].split(",")]))

folded = Counter()
for t, tid, idle, st in samples:
    if tid == main_tid:
        folded[";".join(syms.get(i, "?").replace(";", ":").replace(" ", "_") for i in reversed(st))] += 1
with open(prefix + ".main.folded", "w", encoding="utf-8") as f:
    for k, v in folded.most_common():
        f.write(f"{k} {v}\n")

for name, s, e in windows:
    section(f"{name} ({s} - {e} ms)", [x for x in samples if s <= x[0] < e])
