#!/usr/bin/env python3
"""Renders the comment that lists every test with its Debug and Release result (see test.yml).

  test-report.py --state pending|done|skipped|cancelled|failed --sha SHA [--run-url URL]
                 [--tests ctest-tests.json] [--junit ctest-junit.xml] [--previous previous-comment.md]

The names of the tests come from `ctest --show-only=json-v1` (--tests), the results from `ctest --output-junit` (--junit). If
there is no list yet (the comment is reset before the project was configured), the names are taken from the previous comment.
The Debug and the Release run of a test are told apart by "debug" in its name (suite-debug-run-x, gui-autosuspend-debug-on),
and shown in one row. The markdown goes to standard output.
"""
import argparse
import json
import re
import sys
import xml.etree.ElementTree as ET

MARKER = "<!-- blitzllvm-tests -->"
LIMIT = 60000  # GitHub allows 65536 characters in a comment.

PASS, FAIL, SKIP, PENDING, MISSING, NOTRUN = "☑️", "❌", "⏭️", "⏳", "—", "⚪"
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


def read_names(args):
    if args.tests:
        with open(args.tests, encoding="utf-8") as f:
            return [split(t["name"]) for t in json.load(f).get("tests", [])]
    if args.previous:
        names = []
        with open(args.previous, encoding="utf-8") as f:
            for line in f:
                m = re.match(r"^\| `([^`]+)` \| (\S+) \| (\S+) \|", line)
                if m:
                    # A column that shows a dash has no test.
                    names += [(m.group(1), c) for c, v in (("debug", m.group(2)), ("release", m.group(3))) if v != MISSING]
        return names
    return []


def read_results(path):
    results = {}
    if not path:
        return results
    for case in ET.parse(path).getroot().iter("testcase"):
        if case.find("failure") is not None or case.find("error") is not None:
            results[case.get("name")] = FAIL
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
    p.add_argument("--tests")
    p.add_argument("--junit")
    p.add_argument("--previous")
    args = p.parse_args()

    names = read_names(args)
    results = {} if args.state == "pending" else read_results(args.junit)
    # What a test that has no result means: pending while the run goes on, "not run" once it is over.
    default = PENDING if args.state == "pending" else NOTRUN

    rows = {}
    for row, config in names:
        # The result is looked up by the name ctest gave the test.
        rows.setdefault(row, {})[config] = results.get(join(row, config), default)

    header = STATES.get(args.state)
    if header is None:
        bad = any(FAIL in r.values() for r in rows.values()) or any(NOTRUN in r.values() for r in rows.values())
        header = "❌ Tests failed" if args.state == "failed" or bad else "☑️ Tests passed"
    out = [MARKER, f"## {header}", ""]
    link = f" · [Workflow run]({args.run_url})" if args.run_url else ""
    out.append(f"Commit `{args.sha[:7]}`{link}")
    out.append("")

    if args.state == "skipped":
        out.append("Neither the compiler, the runtime, the dependencies, the build files nor the tests changed, so there was nothing new to test.")
        print("\n".join(out))
        return
    if not rows:
        out.append("The list of tests is made once the project was configured." if args.state == "pending" else "No tests were listed.")
        print("\n".join(out))
        return
    if args.state == "failed":
        out += ["The build or the test run failed before the results were written. See the workflow run for the log.", ""]

    def line(row):
        r = rows[row]
        return f"| `{row}` | {r.get('debug', MISSING)} | {r.get('release', MISSING)} |"

    bad = [r for r in sorted(rows) if any(v in (FAIL, NOTRUN) for v in rows[r].values())]
    waiting = [r for r in sorted(rows) if r not in bad and any(v == PENDING for v in rows[r].values())]
    rest = [r for r in sorted(rows) if r not in bad and r not in waiting]
    counts = {PASS: 0, FAIL: 0, SKIP: 0, PENDING: 0, NOTRUN: 0}
    for r in rows.values():
        for v in r.values():
            counts[v] = counts.get(v, 0) + 1
    out.append(f"{len(rows)} tests · {PASS} {counts[PASS]} · {FAIL} {counts[FAIL]} · {SKIP} {counts[SKIP]} skipped"
               + (f" · {PENDING} {counts[PENDING]}" if counts[PENDING] else "") + (f" · {NOTRUN} {counts[NOTRUN]} not run" if counts[NOTRUN] else ""))
    out.append("")
    table = ["| Test | Debug | Release |", "| --- | :---: | :---: |"]

    shown = bad + waiting
    body = out + table + [line(r) for r in shown]
    if args.state == "pending" or not rest:
        # Everything is waiting (or failed): one table.
        body = out + table + [line(r) for r in shown + rest]
        text = "\n".join(body)
    else:
        text = "\n".join(body)
        if shown:
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
