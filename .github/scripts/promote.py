#!/usr/bin/env python3
"""Promotes the latest nightly release into the moving releases daily, weekly, monthly and yearly.

    promote.py [daily weekly monthly yearly] [--repo OWNER/NAME] [--dry-run] [--force] [--now ISO8601]

Needs the GitHub CLI with GH_TOKEN set (contents: write), and git for creating a missing tag. Without names, all four are
considered. A moving release is promoted when the nightly differs from what it holds (compared by commit) and its last
promotion happened in an earlier day, ISO week, month or year than now. Running every day therefore promotes weekly on the
first run of a new week, monthly on the first of a month, and yearly on January 1st, and a skipped scheduled run is made up
by the next one. --force ignores both checks. --dry-run only reads from GitHub and prints what would be done. --now stands in
for the current time (UTC), to try the schedule logic.

The assets are copied from the nightly release, not from the artifacts of the workflow run, as these expire after 90 days.
"""
import argparse
import datetime
import json
import os
import re
import subprocess
import sys
import tempfile

SOURCE = "nightly"
# Name of the moving tag/release, and the period in which it is promoted at most once.
PERIODS = {
    "daily": lambda t: t.strftime("%Y-%m-%d"),
    "weekly": lambda t: "%d-W%02d" % t.isocalendar()[:2],
    "monthly": lambda t: t.strftime("%Y-%m"),
    "yearly": lambda t: t.strftime("%Y"),
}
SOURCE_COMMIT = re.compile(r"^Source commit: ([0-9a-f]{40})$", re.MULTILINE)
PROMOTED_AT = re.compile(r"^Promoted: (\S+)$", re.MULTILINE)
NIGHTLY_NAME = re.compile(r"^Nightly (\S+) \(")


class PromoteError(Exception):
    pass


def run(*command, check=True, **kwargs):
    result = subprocess.run(command, capture_output=True, text=True, **kwargs)
    if check and result.returncode != 0:
        raise PromoteError(f"{' '.join(command[:4])} failed: {result.stderr.strip() or result.stdout.strip()}")
    return result


def api(path, *args, check=True):
    """Calls the REST API. Returns the parsed JSON, or None for a 404 when check is False."""
    result = run("gh", "api", path, *args, check=False)
    if result.returncode != 0:
        if not check and "404" in result.stderr:
            return None
        raise PromoteError(f"gh api {path} failed: {result.stderr.strip() or result.stdout.strip()}")
    return json.loads(result.stdout) if result.stdout.strip() else None


def parse_time(text):
    return datetime.datetime.fromisoformat(text.replace("Z", "+00:00")).astimezone(datetime.timezone.utc)


def read_nightly(repo):
    """The nightly release as {sha, version, assets}, or raises if it is missing, still being replaced or incomplete."""
    release = api(f"repos/{repo}/releases/tags/{SOURCE}", check=False)
    if release is None:
        raise PromoteError("There is no nightly release yet, nothing to promote.")
    sha = re.search(r"build of ([0-9a-f]{40})", release.get("body") or "")
    name = NIGHTLY_NAME.match(release.get("name") or "")
    if not sha or not name:
        raise PromoteError(f"The nightly release does not name its commit and version (title '{release.get('name')}').")
    version = name.group(1)
    assets = [a for a in release["assets"] if a["state"] == "uploaded"]
    # The Nightly workflow deletes the old assets, edits the notes and then uploads the new ones, so a half replaced release
    # is recognized by file names with another version or by a missing platform.
    stale = [a["name"] for a in assets if version not in a["name"]]
    if stale or len(assets) != len(release["assets"]) or not any(a["name"].endswith("windows-x64.zip") for a in assets):
        raise PromoteError("The nightly release is being replaced right now (assets of another version, or incomplete). Try again later.")
    return {"sha": sha.group(1), "version": version, "assets": assets, "body": release["body"]}


def read_state(repo, tag):
    """What a moving release holds: {sha, promoted, release}, or None if the release does not exist."""
    release = api(f"repos/{repo}/releases/tags/{tag}", check=False)
    if release is None:
        return None
    body = release.get("body") or ""
    sha, promoted = SOURCE_COMMIT.search(body), PROMOTED_AT.search(body)
    return {"sha": sha.group(1) if sha else None, "promoted": parse_time(promoted.group(1)) if promoted else None, "release": release}


def decide(tag, nightly, state, now, force):
    """Returns None if the tag is to be promoted, otherwise the reason why not."""
    if force or state is None or state["sha"] is None or state["promoted"] is None:
        return None
    if state["sha"] == nightly["sha"]:
        return f"already holds the nightly build of {nightly['sha'][:7]}"
    period = PERIODS[tag]
    if period(state["promoted"]) == period(now):
        return f"was already promoted in {period(now)}"
    return None


def notes_for(repo, tag, nightly, committed, now):
    stamp = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    return "\n".join([
        f"The {tag} build: the latest nightly build at {stamp}, version {nightly['version']}.",
        "",
        f"Commit: https://github.com/{repo}/commit/{nightly['sha']}",
        f"Commit date: {committed}",
        "",
        "This release is replaced by a newer nightly build in the next " + {"daily": "day", "weekly": "week", "monthly": "month", "yearly": "year"}[tag] + ", so its files change.",
        "Use a numbered release for a build that stays.",
        "",
        # Read back by the next run (see SOURCE_COMMIT and PROMOTED_AT).
        f"Source commit: {nightly['sha']}",
        f"Source version: {nightly['version']}",
        f"Promoted: {stamp}",
        "",
    ])


def ensure_tag(repo, tag):
    """Creates the tag on a blank commit without files if it does not exist. It is never moved afterwards, as the release
    carries what was promoted, so the history is never touched and nothing is force pushed."""
    if api(f"repos/{repo}/git/ref/tags/{tag}", check=False) is not None:
        return
    print(f"Creating tag {tag} on a blank commit")
    remote = f"https://x-access-token:{os.environ['GH_TOKEN']}@github.com/{repo}.git"
    with tempfile.TemporaryDirectory() as directory:
        run("git", "init", "-q", cwd=directory)
        run("git", "-c", "user.name=github-actions", "-c", "user.email=actions@github.com", "commit", "-q", "--allow-empty", "-m", tag.capitalize(), cwd=directory)
        run("git", "push", "-q", remote, f"HEAD:refs/tags/{tag}", cwd=directory)


def download(repo, nightly, directory):
    files = []
    for asset in nightly["assets"]:
        path = os.path.join(directory, asset["name"])
        with open(path, "wb") as f:
            result = subprocess.run(["gh", "api", "-H", "Accept: application/octet-stream", f"repos/{repo}/releases/assets/{asset['id']}"], stdout=f, stderr=subprocess.PIPE)
        if result.returncode != 0:
            raise PromoteError(f"Downloading {asset['name']} failed: {result.stderr.decode().strip()}")
        files.append(path)
    # The nightly must not have been replaced while it was downloaded.
    again = read_nightly(repo)
    if again["sha"] != nightly["sha"] or {a["id"] for a in again["assets"]} != {a["id"] for a in nightly["assets"]}:
        raise PromoteError("The nightly release changed while it was downloaded. Try again later.")
    return files


def publish(repo, tag, nightly, files, body, state):
    ensure_tag(repo, tag)
    title = f"{tag.capitalize()} {nightly['version']} ({nightly['sha'][:7]})"
    if state is None:
        release = api(f"repos/{repo}/releases", "-X", "POST", "-f", f"tag_name={tag}", "-f", f"name={title}", "-f", f"body={body}",
                      "-F", "prerelease=true", "-f", "make_latest=false")
    else:
        release = state["release"]
    wanted = {os.path.basename(f) for f in files}
    # New files first, so the release is never without binaries. The names contain the version, so the old ones are different
    # files that are removed once the new ones are complete.
    run("gh", "release", "upload", tag, "--repo", repo, "--clobber", *files)
    uploaded = {a["name"] for a in api(f"repos/{repo}/releases/{release['id']}")["assets"] if a["state"] == "uploaded"}
    missing = wanted - uploaded
    if missing:
        raise PromoteError(f"These files did not upload to {tag}: {', '.join(sorted(missing))}. The old files are kept.")
    for asset in api(f"repos/{repo}/releases/{release['id']}")["assets"]:
        if asset["name"] not in wanted:
            api(f"repos/{repo}/releases/assets/{asset['id']}", "-X", "DELETE")
    # The notes carry what the release holds, so they are written last. If anything above fails, the next run does it again.
    api(f"repos/{repo}/releases/{release['id']}", "-X", "PATCH", "-f", f"name={title}", "-f", f"body={body}", "-F", "prerelease=true", "-f", "make_latest=false")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("tags", nargs="*", choices=list(PERIODS), metavar="TAG", help="daily, weekly, monthly, yearly (default: all)")
    parser.add_argument("--repo", default=os.environ.get("GITHUB_REPOSITORY", "Xaymar/BlitzLLVM"))
    parser.add_argument("--dry-run", action="store_true", help="only read, print what would be done")
    parser.add_argument("--force", action="store_true", help="promote even if the nightly is already held or the period has not ended")
    parser.add_argument("--now", help="the current time in UTC as ISO 8601, for trying the schedule logic")
    args = parser.parse_args()
    tags = args.tags or list(PERIODS)
    now = parse_time(args.now) if args.now else datetime.datetime.now(datetime.timezone.utc)

    nightly = read_nightly(args.repo)
    commit = api(f"repos/{args.repo}/commits/{nightly['sha']}", check=False)
    committed = commit["commit"]["committer"]["date"] if commit else "unknown (the commit is no longer in the repository)"
    print(f"Nightly {nightly['version']} of {nightly['sha']}, committed {committed}; now {now:%Y-%m-%d %H:%M}Z")

    due = []
    for tag in tags:
        state = read_state(args.repo, tag)
        reason = decide(tag, nightly, state, now, args.force)
        held = f"holds {state['sha'][:7] if state and state['sha'] else 'nothing'}" if state else "does not exist"
        if reason:
            print(f"{tag}: skipped, {reason}")
        else:
            print(f"{tag}: {held}, {'would be' if args.dry_run else 'will be'} promoted")
            due.append((tag, state))
    if not due:
        print("Nothing to promote.")
        return
    if args.dry_run:
        print("Dry run: nothing was changed.")
        return

    failures = []
    with tempfile.TemporaryDirectory() as directory:
        files = download(args.repo, nightly, directory)
        for tag, state in due:
            try:
                publish(args.repo, tag, nightly, files, notes_for(args.repo, tag, nightly, committed, now), state)
                print(f"{tag}: promoted, https://github.com/{args.repo}/releases/tag/{tag}")
            except PromoteError as error:
                # The others are independent of it.
                print(f"::error::{tag}: {error}")
                failures.append(tag)
    if failures:
        raise PromoteError(f"Promoting failed for: {', '.join(failures)}")


if __name__ == "__main__":
    try:
        main()
    except PromoteError as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
