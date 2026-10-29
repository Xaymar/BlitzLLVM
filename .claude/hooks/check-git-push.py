#!/usr/bin/env python3
# PreToolUse hook for Bash: the one push that needs no permission prompt is "git push [-u] [--force-with-lease] origin claude/<name>", spelled
# exactly like that, because a permission rule such as "Bash(git push --force-with-lease origin claude/*)" can not do this: its * also matches
# further words ("... origin claude/x main:root"). Any other command that pushes, however it is written (git -C <dir> push, command git push,
# sudo, an environment prefix, bash -c "...", an alias, a second refspec), asks for permission even where a permission rule would allow it, and
# is refused when it could force, delete or mirror, or run something on the remote. Aliases and push URL overrides always ask. Commands without git push get no decision.
import json
import re
import sys

BRANCH = r"claude/[A-Za-z0-9_-][A-Za-z0-9._-]*(?:/[A-Za-z0-9_-][A-Za-z0-9._-]*)*"
FLAGS = ("-u", "--set-upstream", "--force-with-lease", "--force-if-includes")
EXACT = re.compile(r"git push(?: (?:" + "|".join(re.escape(f) for f in FLAGS) + r"))* origin (" + BRANCH + r")")
# Anything that can overwrite or remove remote history, reach more than the named branch, or run a program.
RISKY = re.compile(r"^(-f|--force(?!-with-lease$|-if-includes$)\S*|--mirror|--all|--delete|-d|--prune|--receive-pack\S*|--exec\S*|\+\S*|:\S*)$")
# Anything that makes git push mean something else: aliases, a different push target, git configuration from the environment.
REDIRECT = re.compile(r"(^|[.=])(alias\.|\S*pushurl|\S*insteadof|GIT_CONFIG)", re.I)
WORD = re.compile(r"[^\s'\";&|()`$<>{}]+")


def valid_branch(name):
    """The name must also be one git accepts and must not climb out of the pattern: no '..', no component ending in '.lock' or '.'."""
    return ".." not in name and not any(part.endswith((".lock", ".")) for part in name.split("/"))


def only_claude_targets(words):
    """Whether every word after 'push' that is not an option is origin or a valid claude/ branch (so a lease-protected force is harmless)."""
    rest = [w for w in words[words.index("push") + 1:] if not w.startswith("-")] if "push" in words else ["?"]
    return all(w == "origin" or (re.fullmatch(BRANCH, w) and valid_branch(w)) for w in rest)


def decide(command):
    words = WORD.findall(command)
    if not any(w == "git" or w.endswith(("/git", "\\git", "git.exe", "=git")) for w in words):
        return None
    if not any(w == "push" or w.endswith("=push") for w in words) and not any(REDIRECT.search(w) for w in words):
        return None
    exact = EXACT.fullmatch(command)
    if exact and valid_branch(exact.group(1)):
        return "allow", "Push of a claude/ branch."
    if any(RISKY.match(w) for w in words) or any(w.startswith("--force-with-lease=") for w in words) or (
            any(w.startswith(("--force", "-f")) for w in words) and not only_claude_targets(words)):
        return "deny", "Force pushing, deleting or mirroring (or any push that is not a single claude/ branch to origin) is only allowed for branches starting with claude/."
    if any(REDIRECT.search(w) for w in words):
        return "ask", "A git alias, push URL or configuration override could redirect a push."
    return "ask", "A push that is not exactly 'git push [-u] [--force-with-lease] origin claude/<name>' needs a decision."


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
