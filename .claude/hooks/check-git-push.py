#!/usr/bin/env python3
# PreToolUse hook for Bash: pushes of branches starting with claude/ need no permission prompt, even when forced, and a
# force push of anything else is refused. A permission rule such as "Bash(git push --force-with-lease origin claude/*)" can not
# do this, because its * also matches further words ("... origin claude/x main:root"). Everything else (a plain push of another
# branch, any other command) gets no decision here, so the usual prompt applies.
import json
import re
import shlex
import sys

BRANCH = re.compile(r"^claude/[A-Za-z0-9._/-]+$")
FLAGS = {"-u", "--set-upstream", "--force-with-lease"}
# Anything that can overwrite or remove remote history or reach more than the named branch.
RISKY = re.compile(r"^(-f|--force\S*|--mirror|--all|--delete|-d|--prune|\+\S*)$")
SHELL = re.compile(r"[;&|<>$`()\n]")


def decide(command):
    if "git" not in command or "push" not in command:
        return None
    try:
        tokens = shlex.split(command)
    except ValueError:
        tokens = command.split()
    pushes = [i for i, t in enumerate(tokens) if t == "push" and i and tokens[i - 1] == "git"]
    if not pushes:
        return None
    args = tokens[pushes[0] + 1:]
    exact = (len(pushes) == 1 and pushes[0] == 1 and not SHELL.search(command)
             and len(args) >= 2 and args[-2] == "origin" and BRANCH.match(args[-1]) and all(a in FLAGS for a in args[:-2]))
    if exact:
        return "allow", "Push of a claude/ branch."
    if any(RISKY.match(t) for t in tokens) or any(t.startswith("--force-with-lease=") for t in tokens):
        return "deny", "Force pushing (or any push that is not a single claude/ branch to origin) is only allowed for branches starting with claude/."
    return None


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    result = decide((data.get("tool_input") or {}).get("command", ""))
    if result:
        json.dump({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": result[0],
                                          "permissionDecisionReason": result[1]}}, sys.stdout)


if __name__ == "__main__":
    main()
