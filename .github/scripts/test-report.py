#!/usr/bin/env python3
"""Renders the comment that lists every test with its Debug and Release result (see test.yml).

  test-report.py --state pending|done|skipped|cancelled|failed --sha SHA [--run-url URL]
                 [--platform NAME=ctest-tests.json,ctest-junit.xml,skipped.json]...

One --platform per platform, each with a column for Debug and one for Release. The names of the tests come from
`ctest --show-only=json-v1`, the results from `ctest --output-junit`, and the tests a change does not affect (written by
test-select.py, {test name: reason}) show as skipped with the reason in a Note column. A platform without these files shows dashes.
The comment shows the summary line and the tests that failed (with the end of their output) directly; the table of the tests that
passed or were skipped, and the table of a run that is still pending, are folded away in <details>.
The Debug and the Release run of a test are told apart by "debug" in its name (suite-debug-run-x, gui-autosuspend-debug-on),
and shown in one row. The markdown goes to standard output.

"""
import argparse
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

MARKER = "<!-- blitzllvm-tests -->"
LIMIT = 60000  # GitHub allows 65536 characters in a comment.
OUTPUT_LINES = 30  # How many lines at the end of the output of a failed test are shown.
OUTPUT_CHARS = 3000  # ... and at most this many characters of them.

PASS, FAIL, SKIP, PENDING, MISSING, NOTRUN = "✅", "❌", "⏭️", "⏳", "—", "⚪"
STATES = {
    "pending": "⏳ Tests pending",
    "skipped": "⏭️ Tests skipped",
    "cancelled": "⚪ Tests cancelled",
}


DEBUG_NAMES = {}


def split(name):
    """Returns (row name, 'debug' or 'release') for the name of a ctest test."""
    if name.startswith("suite-debug-"):
        return "suite-" + name[len("suite-debug-"):], "debug"
    if not name.startswith("suite-") and re.search(r"-debug(?=[-_]|$)", name):
        row = re.sub(r"-debug(?=[-_]|$)", "", name, count=1)
        DEBUG_NAMES[row] = name
        return row, "debug"
    return name, "release"


def join(row, config):
    """The reverse of split()."""
    if config == "release":
        return row
    if row.startswith("suite-"):
        return "suite-debug-" + row[len("suite-"):]
    # The first "-debug" was removed in front of "-", "_" or the end; put it back after the first word group that follows.
    return DEBUG_NAMES.get(row, row + "-debug")


def read_names(tests):
    """The (row, config) pairs of a `ctest --show-only=json-v1` file."""
    if not tests:
        return []
    with open(tests, encoding="utf-8") as f:
        raw = [t["name"] for t in json.load(f).get("tests", [])]
    pairs = [split(n) for n in raw]
    # A name with "debug" in it that has no Release test to pair with is a test of its own (cli-debug), not a Debug run.
    release = {r for r, c in pairs if c == "release"}
    return [(r, c) if c == "release" or r in release or n.startswith("suite-debug-") else (n, "release") for n, (r, c) in zip(raw, pairs)]


def tail(text):
    """The end of the output of a failed test, the part that says why it failed."""
    text = "\n".join(text.strip().replace("```", "``\u200b`").splitlines()[-OUTPUT_LINES:])
    return ("..." + text[-OUTPUT_CHARS:]) if len(text) > OUTPUT_CHARS else text


def read_results(path, outputs=None):
    results = {}
    if not path:
        return results
    for case in ET.parse(path).getroot().iter("testcase"):
        if case.find("failure") is not None or case.find("error") is not None:
            results[case.get("name")] = FAIL
            if outputs is not None:
                outputs[case.get("name")] = tail(case.findtext("system-out") or case.findtext("failure") or case.findtext("error") or "")
        elif case.find("skipped") is not None:
            results[case.get("name")] = SKIP
        else:
            results[case.get("name")] = PASS
    return results


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--state", required=True)
    p.add_argument("--sha", required=True)
    p.add_argument("--run-url", default="")
    p.add_argument("--platform", action="append", default=[], help="NAME=tests.json,junit.xml,skipped.json (every part may be empty)")
    args = p.parse_args()

    platforms = []  # (name, names, results, outputs, skipped, listed)
    for spec in args.platform:
        name, _, files = spec.partition("=")
        tests, junit, skip = (files.split(",") + ["", "", ""])[:3]
        skipped = {}
        if skip and os.path.exists(skip):
            with open(skip, encoding="utf-8") as f:
                skipped = json.load(f)
        tests = tests if tests and os.path.exists(tests) else ""
        junit = junit if junit and os.path.exists(junit) else ""
        outputs = {}
        results = {} if args.state == "pending" else read_results(junit, outputs)
        platforms.append((name, read_names(tests), results, outputs, skipped, bool(tests), bool(junit)))

    # What a test that has no result means: pending while the run goes on, "not run" once it is over.
    default = PENDING if args.state == "pending" else NOTRUN
    columns = [(plat[0], config) for plat in platforms for config in ("debug", "release")]
    rows = {}
    notes = {}
    skipped_count = 0
    for name, names, results, outputs, skipped, listed, has_results in platforms:
        skipped_count += len(skipped)
        for row, config in names:
            test = join(row, config)
            if test in skipped:
                rows.setdefault(row, {})[(name, config)] = SKIP
                notes.setdefault(row, skipped[test])
            else:
                rows.setdefault(row, {})[(name, config)] = results.get(test, default)

    header = STATES.get(args.state)
    if header is None:
        bad = any(FAIL in r.values() for r in rows.values()) or any(NOTRUN in r.values() for r in rows.values())
        header = "❌ Tests failed" if args.state == "failed" or bad else "✅ Tests passed"
    out = [MARKER, f"## {header}", ""]
    link = f" · [Workflow run]({args.run_url})" if args.run_url else ""
    out.append(f"Commit `{args.sha[:7]}`{link}")
    out.append("")

    if args.state == "skipped":
        out.append("Nothing that the tests depend on changed (documentation, the wiki, other workflows), so there was nothing to test.")
        print("\n".join(out))
        return
    if not rows:
        out.append("The list of tests is made once the project was built." if args.state == "pending" else "No tests were listed.")
        print("\n".join(out))
        return
    broken = [plat[0] for plat in platforms if not plat[5] or not (plat[6] or args.state == "pending")]
    if broken:
        out += [f"No results from {', '.join(broken)}: the build or the test run failed before the results were written. See the workflow run for the log.", ""]

    def line(row):
        r = rows[row]
        note = f" {notes.get(row, '')} |" if notes else ""
        return f"| `{row}` | " + " | ".join(r.get(c, MISSING) for c in columns) + f" |{note}"

    bad = [r for r in sorted(rows) if any(v in (FAIL, NOTRUN) for v in rows[r].values())]
    waiting = [r for r in sorted(rows) if r not in bad and any(v == PENDING for v in rows[r].values())]
    rest = [r for r in sorted(rows) if r not in bad and r not in waiting]
    counts = {PASS: 0, FAIL: 0, SKIP: 0, PENDING: 0, NOTRUN: 0}
    for r in rows.values():
        for v in r.values():
            counts[v] = counts.get(v, 0) + 1
    out.append(f"{sum(len(r) for r in rows.values())} test runs on {', '.join(plat[0] for plat in platforms)} · {PASS} {counts[PASS]} · {FAIL} {counts[FAIL]} · {SKIP} {counts[SKIP]} skipped"
               + (f" · {PENDING} {counts[PENDING]}" if counts[PENDING] else "") + (f" · {NOTRUN} {counts[NOTRUN]} not run" if counts[NOTRUN] else ""))
    out.append("")
    if skipped_count:
        out += ["Tests were skipped, as the files that this change touches do not affect them, or because they skip themselves on a platform (see the Note column). "
                "Everything runs on root, and on a pull request with the label `run-all-tests`.", ""]
    heads = " | ".join(f"{plat} {config.capitalize()}" for plat, config in columns)
    table = [f"| Test | {heads} |" + (" Note |" if notes else ""), "| --- | " + " | ".join(":---:" for _ in columns) + " |" + (" --- |" if notes else "")]

    shown = bad + waiting
    if args.state == "pending" or not rest:
        listing = table + [line(r) for r in shown + rest]
        if bad:
            text = "\n".join(out + listing)
        else:
            text = "\n".join(out + [f"<details><summary>Tests ({len(rows)})</summary>", ""] + listing + ["", "</details>"])
    else:
        text = "\n".join(out + (table + [line(r) for r in shown] if shown else []))
    # The end of the output of every failed test, as far as it fits.
    for row in bad:
        for plat in platforms:
            for config in ("debug", "release"):
                test = join(row, config)
                if rows[row].get((plat[0], config)) == FAIL and plat[3].get(test):
                    block = f"\n\n**`{test}`** ({plat[0]})\n\n```\n{plat[3][test]}\n```"
                    if len(text) + len(block) <= LIMIT // 2:
                        text += block
    if rest and args.state != "pending":
        text += "\n"
        details = ["", f"<details><summary>Passed or skipped ({len(rest)})</summary>", ""] + table + [line(r) for r in rest] + ["", "</details>"]
        if len(text) + len("\n".join(details)) > LIMIT:
            details = ["", f"{len(rest)} tests that passed or were skipped are not listed, as the comment would be too long."]
        text += "\n".join(details)
    if len(text) > LIMIT:
        text = text[:LIMIT].rsplit("\n", 1)[0] + "\n\nThe list was cut, as the comment would be too long."
    print(text)


if __name__ == "__main__":
    sys.exit(main())
