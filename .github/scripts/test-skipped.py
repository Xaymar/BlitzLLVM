#!/usr/bin/env python3
"""Lists the tests that did not run, as Markdown for the job summary of a test job (see test.yml).

  test-skipped.py --platform NAME --gpu ON|OFF --junit ctest-junit.xml [--selection-skipped skipped.json]

Two kinds of tests are left out and they are listed apart: the ones that skip themselves while running (exit code 77, for example
a test that needs a tool that this platform does not have), and the ones that the change does not affect (test-select.py). The tests
that CMake does not register for a platform at all (the ones that need xdotool, X11 or SDL's disk audio driver on Windows) are not
tests there, so they can not be listed; the Building page of the wiki lists them.
"""
import argparse
import json
import xml.etree.ElementTree as ET


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--platform", required=True)
    p.add_argument("--gpu", default="ON")
    p.add_argument("--junit", required=True)
    p.add_argument("--selection-skipped")
    args = p.parse_args()

    itself = []
    total = 0
    for case in ET.parse(args.junit).getroot().iter("testcase"):
        total += 1
        if case.find("skipped") is not None:
            itself.append(case.get("name"))
    print(f"### Test ({args.platform}): {total} tests ran or were skipped")
    print()
    if args.gpu != "ON":
        print("The tests that need a window and a GPU (`_pixels`) are not part of this run: this runner has no GPU.")
        print()
    if itself:
        print(f"{len(itself)} tests skipped themselves (exit code 77):")
        print()
        for name in sorted(itself):
            print(f"- `{name}`")
        print()
    else:
        print("No test skipped itself.")
        print()
    if args.selection_skipped:
        with open(args.selection_skipped, encoding="utf-8") as f:
            left_out = json.load(f)
        print(f"{len(left_out)} tests were left out because the change can not affect them (see `Detect changes`).")


if __name__ == "__main__":
    main()
