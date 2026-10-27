#!/usr/bin/env python3
"""Decides which tests a change has to run (see test.yml and docs/wiki/Testing.md).

  test-select.py changes --changed files.txt [--force REASON]   Reads the changed files (one per line), prints the selection as JSON.
  test-select.py apply --selection JSON --tests ctest-tests.json --selected out.txt --skipped out.json
                                                                 Splits the tests of `ctest --show-only=json-v1` into the ones to
                                                                 run (one name per line, for `ctest --tests-from-file`) and the
                                                                 ones to skip (name -> reason).

The rules are in tests/test_selection.json: every test belongs to at most one area (by its name), and every changed file maps to a
list of areas, to "all" or to "none". Whatever has no rule runs everything. A test that is in no area (lex-test, suite-coverage, ...)
is cheap and always runs when anything runs.
"""
import argparse
import json
import os
import re
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
CONFIG = os.path.join(ROOT, "tests", "test_selection.json")


def load_config(path=CONFIG):
    with open(path, encoding="utf-8") as f:
        cfg = json.load(f)
    for name, area in cfg["areas"].items():
        area["_tests"] = [re.compile(p) for p in area["tests"]]
    for rule in cfg["rules"]:
        rule["_match"] = re.compile(rule["match"])
    return cfg


def expand(cfg, areas):
    """Turns "all", "none", one area, an alias or a list of those into ("all" | "none" | set of areas)."""
    if isinstance(areas, str):
        areas = [areas]
    result = set()
    for a in areas:
        if a in ("all", "none"):
            return a
        names = cfg.get("aliases", {}).get(a, [a])
        for n in names:
            if n not in cfg["areas"]:
                raise ValueError(f"unknown area '{n}'")
            result.add(n)
    return result


def classify(cfg, path):
    """Returns (areas, suite, note) for a changed file: areas is "all", "none" or a set. suite is the name of the suite program it is."""
    for rule in cfg["rules"]:
        m = rule["_match"].search(path)
        if m:
            suite = m.groupdict().get("suite")
            return expand(cfg, rule["areas"]), (suite.replace("/", "-") if suite else None), rule.get("note")
    return "all", None, "no rule for this file"


def select(cfg, files, force=None):
    """The selection for a list of changed files: {"mode": "all"|"partial"|"none", "areas": [...], "suites": [...], "reason": str}."""
    if force:
        return {"mode": "all", "areas": [], "suites": [], "reason": force}
    files = [f.strip() for f in files if f.strip()]
    if not files:
        return {"mode": "all", "areas": [], "suites": [], "reason": "no changed files known"}
    areas, suites, ran = set(), set(), False
    for f in files:
        a, suite, note = classify(cfg, f)
        if a == "all":
            return {"mode": "all", "areas": [], "suites": [], "reason": f"{f} ({note or 'can change every test'})"}
        if a == "none":
            continue
        ran = True
        areas |= a
        if suite:
            suites.add(suite)
    if not ran:
        return {"mode": "none", "areas": [], "suites": [], "reason": "nothing that the tests depend on changed"}
    return {"mode": "partial", "areas": sorted(areas), "suites": sorted(suites), "reason": "only parts of the tests are affected"}


def area_of(cfg, name):
    for area, spec in cfg["areas"].items():
        if any(p.search(name) for p in spec["_tests"]):
            return area
    return None


def suite_test(name, suites):
    return any(re.fullmatch(rf"suite-(debug-)?(compile|run)-{re.escape(s)}", name) for s in suites)


def split_tests(cfg, selection, names):
    """Returns (selected names, {skipped name: reason})."""
    if selection["mode"] == "all":
        return list(names), {}
    if selection["mode"] == "none":
        return [], {n: "nothing that the tests depend on changed" for n in names}
    selected, skipped = [], {}
    for n in names:
        area = area_of(cfg, n)
        if area is None or area in selection["areas"] or suite_test(n, selection["suites"]):
            selected.append(n)
        else:
            skipped[n] = f"area {area} is not affected"
    return selected, skipped


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="command", required=True)
    c = sub.add_parser("changes")
    c.add_argument("--changed", help="file with the changed files, one per line")
    c.add_argument("--force", help="run everything, for this reason")
    a = sub.add_parser("apply")
    a.add_argument("--selection", required=True, help="the JSON that 'changes' printed")
    a.add_argument("--tests", required=True)
    a.add_argument("--selected", required=True)
    a.add_argument("--skipped", required=True)
    p.add_argument("--config", default=CONFIG)
    args = p.parse_args()
    cfg = load_config(args.config)

    if args.command == "changes":
        files = []
        if args.changed:
            with open(args.changed, encoding="utf-8") as f:
                files = f.read().splitlines()
        print(json.dumps(select(cfg, files, args.force)))
        return 0

    with open(args.tests, encoding="utf-8") as f:
        names = [t["name"] for t in json.load(f).get("tests", [])]
    selected, skipped = split_tests(cfg, json.loads(args.selection), names)
    with open(args.selected, "w", encoding="utf-8") as f:
        f.write("".join(n + "\n" for n in selected))
    with open(args.skipped, "w", encoding="utf-8") as f:
        json.dump(skipped, f, indent=1)
    print(f"{len(selected)} of {len(names)} tests selected, {len(skipped)} skipped", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
