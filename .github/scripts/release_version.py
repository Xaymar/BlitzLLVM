#!/usr/bin/env python3
"""Prints the version of a commit: the release tag that matches what 'blitzcc -v' reports for a build of it.

    release_version.py [commit] [--repo DIR]

The version is YEAR.MONTH.DAY.TWEAK of the UTC commit date, TWEAK being the time of day in units of 2 seconds. This is the
same calculation as cmake/project_version.cmake, which is the authority: the Release workflow compares the tag against it.
Version overrides (BlitzLLVM_VERSION, version.ignore) only exist for out-of-repository builds and are not considered.
"""
import argparse
import subprocess
import sys
from datetime import datetime, timezone


def commit_version(commit="HEAD", repo="."):
    result = subprocess.run(["git", "-C", repo, "log", "-1", "--format=%ct", commit], capture_output=True, text=True)
    if result.returncode != 0 or not result.stdout.strip():
        raise SystemExit(f"error: cannot read commit '{commit}': {result.stderr.strip()}")
    when = datetime.fromtimestamp(int(result.stdout.strip()), timezone.utc)
    tweak = (when.hour * 3600 + when.minute * 60 + when.second) // 2
    return f"{when.year}.{when.month}.{when.day}.{tweak}"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("commit", nargs="?", default="HEAD")
    parser.add_argument("--repo", default=".")
    args = parser.parse_args()
    print(commit_version(args.commit, args.repo))
