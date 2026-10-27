#!/usr/bin/env python3
"""Plans and publishes the moving releases daily, weekly, monthly and yearly, which are built from scratch, not promoted.

    periodic.py plan [daily weekly monthly yearly] --sha COMMIT [--repo OWNER/NAME] [--force] [--now ISO8601]
    periodic.py publish TAG... --sha COMMIT --version VERSION --files DIRECTORY [--repo OWNER/NAME] [--now ISO8601]

Needs the GitHub CLI with GH_TOKEN set (contents: write), and git for creating a missing tag.

plan prints the names of the releases that are due, separated by spaces (and writes them to GITHUB_OUTPUT as `tags`). A release
is due when it does not hold COMMIT yet and its last build happened in an earlier day, ISO week (starting Monday), month or
year than now. Running every day therefore builds weekly on the first run of a new week, monthly on the first of a month, and
yearly on January 1st, and a skipped scheduled run is made up by the next one. --force ignores both checks.

publish uploads the files of one clean build (built by the Nightly workflow with clean: true) to every named release, replacing
what the release held. The new files are uploaded first, the old ones deleted afterwards, and the notes are written last, so a
failed run is simply repeated by the next one.
"""
import argparse
import datetime
import json
import os
import re
import subprocess
import sys
import tempfile

# Name of the moving tag/release, and the period in which it is built at most once.
PERIODS = {
    "daily": lambda t: t.strftime("%Y-%m-%d"),
    "weekly": lambda t: "%d-W%02d" % t.isocalendar()[:2],
    "monthly": lambda t: t.strftime("%Y-%m"),
    "yearly": lambda t: t.strftime("%Y"),
}
UNITS = {"daily": "day", "weekly": "week", "monthly": "month", "yearly": "year"}
SOURCE_COMMIT = re.compile(r"^Source commit: ([0-9a-f]{40})$", re.MULTILINE)
BUILT_AT = re.compile(r"^Built: (\S+)$", re.MULTILINE)


class PeriodicError(Exception):
    pass


def run(*command, check=True, **kwargs):
    result = subprocess.run(command, capture_output=True, text=True, **kwargs)
    if check and result.returncode != 0:
        raise PeriodicError(f"{' '.join(command[:4])} failed: {result.stderr.strip() or result.stdout.strip()}")
    return result


def api(path, *args, check=True):
    """Calls the REST API. Returns the parsed JSON, or None for a 404 when check is False."""
    result = run("gh", "api", path, *args, check=False)
    if result.returncode != 0:
        if not check and "404" in result.stderr:
            return None
        raise PeriodicError(f"gh api {path} failed: {result.stderr.strip() or result.stdout.strip()}")
    return json.loads(result.stdout) if result.stdout.strip() else None


def parse_time(text):
    return datetime.datetime.fromisoformat(text.replace("Z", "+00:00")).astimezone(datetime.timezone.utc)


def read_state(repo, tag):
    """What a moving release holds: {sha, built, release}, or None if the release does not exist."""
    release = api(f"repos/{repo}/releases/tags/{tag}", check=False)
    if release is None:
        return None
    body = release.get("body") or ""
    sha, built = SOURCE_COMMIT.search(body), BUILT_AT.search(body)
    return {"sha": sha.group(1) if sha else None, "built": parse_time(built.group(1)) if built else None, "release": release}


def decide(tag, sha, state, now, force):
    """Returns None if the tag is to be built, otherwise the reason why not."""
    if force or state is None or state["sha"] is None or state["built"] is None:
        return None
    if state["sha"] == sha:
        return f"already holds {sha[:7]}"
    period = PERIODS[tag]
    if period(state["built"]) == period(now):
        return f"was already built in {period(now)}"
    return None


def notes_for(repo, tag, sha, version, committed, now):
    stamp = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    return "\n".join([
        f"The {tag} build: built from scratch at {stamp} from the latest commit, version {version}. Nothing was restored from a cache.",
        "",
        f"Commit: https://github.com/{repo}/commit/{sha}",
        f"Commit date: {committed}",
        "",
        f"This release is replaced by a newer build in the next {UNITS[tag]}, so its files change.",
        "Use a numbered release for a build that stays.",
        "",
        # Read back by the next plan (see SOURCE_COMMIT and BUILT_AT).
        f"Source commit: {sha}",
        f"Source version: {version}",
        f"Built: {stamp}",
        "",
    ])


def ensure_tag(repo, tag):
    """Creates the tag on a blank commit without files if it does not exist. It is never moved afterwards, as the release
    carries what was built, so the history is never touched and nothing is force pushed."""
    if api(f"repos/{repo}/git/ref/tags/{tag}", check=False) is not None:
        return
    print(f"Creating tag {tag} on a blank commit")
    remote = f"https://x-access-token:{os.environ['GH_TOKEN']}@github.com/{repo}.git"
    with tempfile.TemporaryDirectory() as directory:
        run("git", "init", "-q", cwd=directory)
        run("git", "-c", "user.name=github-actions", "-c", "user.email=actions@github.com", "commit", "-q", "--allow-empty", "-m", tag.capitalize(), cwd=directory)
        run("git", "push", "-q", remote, f"HEAD:refs/tags/{tag}", cwd=directory)


def publish_release(repo, tag, sha, version, files, body, state):
    ensure_tag(repo, tag)
    title = f"{tag.capitalize()} {version} ({sha[:7]})"
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
        raise PeriodicError(f"These files did not upload to {tag}: {', '.join(sorted(missing))}. The old files are kept.")
    for asset in api(f"repos/{repo}/releases/{release['id']}")["assets"]:
        if asset["name"] not in wanted:
            api(f"repos/{repo}/releases/assets/{asset['id']}", "-X", "DELETE")
    # The notes carry what the release holds, so they are written last. If anything above fails, the next run does it again.
    api(f"repos/{repo}/releases/{release['id']}", "-X", "PATCH", "-f", f"name={title}", "-f", f"body={body}", "-F", "prerelease=true", "-f", "make_latest=false")


def summarize(lines):
    """Prints the table of results and appends it to the job summary of the workflow run, if there is one."""
    table = ["| Tier | Result |", "| --- | --- |"] + ["| %s | %s |" % line for line in lines]
    print("\n".join(table))
    path = os.environ.get("GITHUB_STEP_SUMMARY")
    if path:
        with open(path, "a", encoding="utf-8") as f:
            f.write("\n".join(table) + "\n")


def plan(args, now):
    sha = args.sha
    due, lines = [], []
    for tag in args.tags or list(PERIODS):
        state = read_state(args.repo, tag)
        reason = decide(tag, sha, state, now, args.force)
        held = f"holds {state['sha'][:7] if state and state['sha'] else 'nothing'}" if state else "does not exist"
        if reason:
            print(f"{tag}: skipped, {reason}")
            lines.append((tag, f"skipped, {reason}"))
        else:
            print(f"{tag}: {held}, due for a clean build of {sha[:7]}")
            lines.append((tag, f"due for a clean build of {sha[:7]}"))
            due.append(tag)
    summarize(lines)
    print("Due: " + (" ".join(due) or "nothing"))
    output = os.environ.get("GITHUB_OUTPUT")
    if output:
        with open(output, "a", encoding="utf-8") as f:
            f.write("tags=" + " ".join(due) + "\n")


def publish(args, now):
    if not args.tags:
        raise PeriodicError("publish needs at least one release name.")
    files = sorted(os.path.join(args.files, name) for name in os.listdir(args.files))
    if not any(f.endswith("windows-x64.zip") for f in files):
        raise PeriodicError(f"{args.files} holds no Windows x64 build: {', '.join(os.path.basename(f) for f in files) or 'nothing'}.")
    commit = api(f"repos/{args.repo}/commits/{args.sha}", check=False)
    committed = commit["commit"]["committer"]["date"] if commit else "unknown"
    failures, lines = [], []
    for tag in args.tags:
        try:
            publish_release(args.repo, tag, args.sha, args.version, files, notes_for(args.repo, tag, args.sha, args.version, committed, now), read_state(args.repo, tag))
            print(f"{tag}: published, https://github.com/{args.repo}/releases/tag/{tag}")
            lines.append((tag, f"published, [{tag}](https://github.com/{args.repo}/releases/tag/{tag})"))
        except PeriodicError as error:
            # The others are independent of it.
            print(f"::error::{tag}: {error}")
            lines.append((tag, f"**failed**: {error}"))
            failures.append(tag)
    summarize(lines)
    if failures:
        raise PeriodicError(f"Publishing failed for: {', '.join(failures)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=["plan", "publish"])
    parser.add_argument("tags", nargs="*", choices=list(PERIODS), metavar="TAG", help="daily, weekly, monthly, yearly (plan: default all)")
    parser.add_argument("--repo", default=os.environ.get("GITHUB_REPOSITORY", "Xaymar/BlitzLLVM"))
    parser.add_argument("--sha", required=True, help="the commit that is or was built")
    parser.add_argument("--version", help="publish: the version of the build")
    parser.add_argument("--files", help="publish: directory with the files of the build")
    parser.add_argument("--force", action="store_true", help="plan: build even if the commit is already held or the period has not ended")
    parser.add_argument("--now", help="the current time in UTC as ISO 8601, for trying the schedule logic")
    args = parser.parse_args()
    now = parse_time(args.now) if args.now else datetime.datetime.now(datetime.timezone.utc)
    if args.command == "publish" and not (args.version and args.files):
        parser.error("publish needs --version and --files")
    (plan if args.command == "plan" else publish)(args, now)


if __name__ == "__main__":
    try:
        main()
    except PeriodicError as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
