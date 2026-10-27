#!/usr/bin/env python3
"""Publishes a GitHub release for a version tag, using the binaries that the Nightly workflow built for the tagged commit.

    release.py <tag> [--repo OWNER/NAME] [--dry-run] [--notes-file FILE] [--timeout MINUTES]

Needs git (with the full history and all tags) and, unless --dry-run is given, the GitHub CLI with GH_TOKEN set.
--dry-run only prints the release notes and what would be done, and touches neither the network nor GitHub, so it can be
tried against any local clone: .github/scripts/release.py 0.2.0 --dry-run  (the tag does not have to exist yet, then HEAD
is used as the tagged commit).
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

NIGHTLY_WORKFLOW = "nightly.yml"
# Tags of releases: 1.2.3, 1.2.3.4 and 1.2.3-rc1. The moving tags (nightly, daily, weekly, monthly, yearly) do not match.
VERSION_TAG = re.compile(r"^(\d+(?:\.\d+){1,3})(?:-([0-9A-Za-z][0-9A-Za-z.-]*))?$")
# Commits that are noise in a changelog.
IGNORED_SUBJECTS = re.compile(r"^(Update copyright headers|Merge\b|Revert \"Update copyright headers)", re.IGNORECASE)
IGNORED_AUTHORS = re.compile(r"\[bot\]$", re.IGNORECASE)
# A trailing " (#123)" of squash merged pull requests stays, as GitHub turns it into a link.
GROUPS = [
    ("Added", re.compile(r"^(Add|Support|Implement|Introduce)\b", re.IGNORECASE)),
    ("Fixed", re.compile(r"^(Fix|Correct|Repair|Resolve)\b", re.IGNORECASE)),
    ("Documentation", re.compile(r"^(Document|Refresh the wiki|.*\bwiki\b)", re.IGNORECASE)),
    ("Changed", re.compile(r".*")),
]


class ReleaseError(Exception):
    pass


def git(*args):
    result = subprocess.run(["git", *args], capture_output=True, text=True)
    if result.returncode != 0:
        raise ReleaseError(f"git {' '.join(args)} failed: {result.stderr.strip()}")
    return result.stdout.strip()


def gh(*args, check=True):
    result = subprocess.run(["gh", *args], capture_output=True, text=True)
    if check and result.returncode != 0:
        raise ReleaseError(f"gh {' '.join(args)} failed: {result.stderr.strip() or result.stdout.strip()}")
    return result


def parse_tag(tag):
    """Returns (numbers, suffix) of a version tag, or None if it is not one."""
    match = VERSION_TAG.match(tag)
    if not match:
        return None
    return tuple(int(n) for n in match.group(1).split(".")), match.group(2)


def sort_key(tag):
    numbers, suffix = parse_tag(tag)
    numbers = numbers + (0,) * (4 - len(numbers))
    # 1.0.0-rc1 sorts before 1.0.0. Suffixes compare by their numeric and text parts.
    parts = [(0, int(p), "") if p.isdigit() else (1, 0, p) for p in re.findall(r"\d+|[A-Za-z]+", suffix)] if suffix else None
    return numbers, (1, []) if parts is None else (0, parts)


def previous_tag(tag):
    """The closest lower version tag. A stable release compares against the last stable one, a pre-release against any."""
    candidates = [t for t in git("tag", "--list").splitlines() if t != tag and parse_tag(t)]
    if not parse_tag(tag)[1]:
        candidates = [t for t in candidates if not parse_tag(t)[1]]
    lower = [t for t in candidates if sort_key(t) < sort_key(tag)]
    return max(lower, key=sort_key) if lower else None


def changes(previous, target):
    """Groups the commit subjects in previous..target, oldest first, without merges and bot commits."""
    rng = f"{previous}..{target}" if previous else target
    out = git("log", "--no-merges", "--reverse", "--format=%an%x1f%s%x1e", rng)
    grouped = {name: [] for name, _ in GROUPS}
    seen = set()
    for entry in filter(None, (e.strip() for e in out.split("\x1e"))):
        author, subject = entry.split("\x1f", 1)
        subject = subject.strip()
        if IGNORED_AUTHORS.search(author) or IGNORED_SUBJECTS.match(subject) or subject in seen:
            continue
        seen.add(subject)
        for name, pattern in GROUPS:
            if pattern.match(subject):
                grouped[name].append(subject)
                break
    return grouped


def notes(repo, tag, previous, target):
    grouped = changes(previous, target)
    lines = []
    for name, subjects in grouped.items():
        if subjects:
            lines += [f"## {name}", ""] + [f"- {s}" for s in subjects] + [""]
    if not lines:
        lines = ["No notable changes.", ""]
    if previous:
        lines.append(f"**Full changelog**: https://github.com/{repo}/compare/{previous}...{tag}")
    else:
        lines.append(f"**Full changelog**: https://github.com/{repo}/commits/{tag}")
    return "\n".join(lines) + "\n"


def find_nightly_run(repo, sha, timeout):
    """Waits for the Nightly run of the commit and returns its id. Raises a ReleaseError if there is none or it failed."""
    deadline = time.monotonic() + timeout * 60
    missing_since = time.monotonic()
    while True:
        data = json.loads(gh("api", f"repos/{repo}/actions/workflows/{NIGHTLY_WORKFLOW}/runs?head_sha={sha}&per_page=100").stdout)
        runs = sorted(data.get("workflow_runs", []), key=lambda r: r["run_number"], reverse=True)
        if not runs:
            # The Nightly run starts together with the push to root, so give it a few minutes to show up.
            if time.monotonic() - missing_since > 5 * 60:
                raise ReleaseError(
                    f"The Nightly workflow never ran for commit {sha}, so there are no binaries to release. "
                    "Tag a commit that was pushed to the root branch, or run the Nightly workflow for it first.")
            print("No Nightly run found yet, waiting ...")
        else:
            # The newest run counts, as a failed one may have been re-run.
            run = runs[0]
            if run["status"] == "completed":
                if run["conclusion"] == "success":
                    return run["id"]
                raise ReleaseError(
                    f"The Nightly run for commit {sha} ended with '{run['conclusion']}': {run['html_url']}\n"
                    "Fix or re-run it, then re-run this workflow.")
            print(f"Nightly run {run['id']} is {run['status']}, waiting ...")
        if time.monotonic() > deadline:
            raise ReleaseError(f"The Nightly run for commit {sha} did not finish within {timeout} minutes.")
        time.sleep(60)


def collect_assets(repo, run_id, directory):
    """Downloads the artifacts of the run and returns the paths of the files to release, named like the nightly release."""
    data = json.loads(gh("api", f"repos/{repo}/actions/runs/{run_id}/artifacts?per_page=100").stdout)
    artifacts = [a for a in data["artifacts"] if a["name"].startswith("blitzllvm-")]
    expired = [a["name"] for a in artifacts if a["expired"]]
    if expired:
        raise ReleaseError(f"These artifacts of the Nightly run have expired: {', '.join(expired)}. Re-run the Nightly workflow.")
    if not artifacts:
        raise ReleaseError(f"The Nightly run {run_id} has no blitzllvm-* artifacts.")
    downloads, release = os.path.join(directory, "artifacts"), os.path.join(directory, "release")
    os.makedirs(release)
    for artifact in artifacts:
        name = artifact["name"]
        target = os.path.join(downloads, name)
        gh("run", "download", str(run_id), "--repo", repo, "--name", name, "--dir", target)
        if name.endswith("-packages"):
            # Packages are already named after their version and platform.
            for file in os.listdir(target):
                shutil.move(os.path.join(target, file), release)
        else:
            subprocess.run(["zip", "-qr", os.path.join(release, name + ".zip"), "."], cwd=target, check=True)
    files = sorted(os.listdir(release))
    print("Release files:", *files, sep="\n  ")
    return [os.path.join(release, f) for f in files]


def publish(repo, tag, prerelease, notes_file, files):
    flags = ["--prerelease"] if prerelease else ["--latest"]
    if gh("release", "view", tag, "--repo", repo, check=False).returncode == 0:
        # A re-run: replace the assets and the notes.
        print(f"Release {tag} exists, updating it.")
        gh("release", "edit", tag, "--repo", repo, "--title", tag, "--notes-file", notes_file, *flags)
        gh("release", "upload", tag, "--repo", repo, "--clobber", *files)
    else:
        gh("release", "create", tag, "--repo", repo, "--verify-tag", "--title", tag, "--notes-file", notes_file, *flags, *files)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("tag")
    parser.add_argument("--repo", default=os.environ.get("GITHUB_REPOSITORY", "Xaymar/BlitzLLVM"))
    parser.add_argument("--dry-run", action="store_true", help="print the notes and the plan, change nothing")
    parser.add_argument("--notes-file", help="where to write the release notes (default: a temporary file)")
    parser.add_argument("--timeout", type=int, default=120, help="minutes to wait for the Nightly run (default 120)")
    args = parser.parse_args()
    tag = args.tag

    if tag == "nightly" or not parse_tag(tag):
        raise ReleaseError(f"'{tag}' is not a release tag. Release tags look like 1.2.3 or 1.2.3-rc1; the moving tags (nightly, daily, weekly, monthly, yearly) are never released.")
    prerelease = bool(parse_tag(tag)[1])
    exists = subprocess.run(["git", "rev-parse", "-q", "--verify", f"refs/tags/{tag}^{{commit}}"], capture_output=True, text=True)
    if exists.returncode == 0:
        sha = exists.stdout.strip()
        target = tag
    elif args.dry_run:
        sha, target = git("rev-parse", "HEAD"), "HEAD"
    else:
        raise ReleaseError(f"Tag {tag} does not exist in this clone (fetch with full history and tags).")
    if git("rev-parse", "--is-shallow-repository") == "true" and not args.dry_run:
        raise ReleaseError("The clone is shallow, the changelog needs the full history (fetch-depth: 0).")

    previous = previous_tag(tag)
    text = notes(args.repo, tag, previous, target)
    print(f"Release {tag}{' (pre-release)' if prerelease else ''} of {sha}")
    print(f"Previous release tag: {previous or 'none, listing the whole history'}\n")
    print(text)

    if args.dry_run:
        print(f"Dry run: would wait for the {NIGHTLY_WORKFLOW} run of {sha}, zip its artifacts and publish release {tag}.")
        return

    with tempfile.TemporaryDirectory() as directory:
        notes_file = args.notes_file or os.path.join(directory, "notes.md")
        with open(notes_file, "w", encoding="utf-8") as f:
            f.write(text)
        run_id = find_nightly_run(args.repo, sha, args.timeout)
        print(f"Using Nightly run {run_id}")
        files = collect_assets(args.repo, run_id, directory)
        publish(args.repo, tag, prerelease, notes_file, files)
    print(f"Published https://github.com/{args.repo}/releases/tag/{tag}")


if __name__ == "__main__":
    try:
        main()
    except ReleaseError as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
