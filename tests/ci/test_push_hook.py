#!/usr/bin/env python3
"""Tests for .claude/hooks/check-git-push.py: python3 tests/ci/test_push_hook.py (also a ctest test, ci-push-hook)."""
import importlib.util
import os
import unittest

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
spec = importlib.util.spec_from_file_location("check_git_push", os.path.join(ROOT, ".claude", "hooks", "check-git-push.py"))
hook = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hook)


def verdict(command):
    result = hook.decide(command)
    return result[0] if result else None


class PushHook(unittest.TestCase):
    def check(self, expected, commands):
        for command in commands:
            with self.subTest(command=command):
                self.assertEqual(verdict(command), expected)

    def test_allowed(self):
        self.check("allow", [
            "git push origin claude/x",
            "git push -u origin claude/audit-push-hook",
            "git push --set-upstream origin claude/a/b.c_d",
            "git push --force-with-lease origin claude/x",
            "git push -u --force-with-lease origin claude/x",
            "git push --force-with-lease --force-if-includes origin claude/x",
            "git push --force-with-lease=claude/x origin HEAD:refs/heads/claude/x",
            "git push --force-with-lease=claude/project-thread-o2kfe2:11707ed74a88b725237ebf9654907a3b8bcc4e81 origin HEAD:refs/heads/claude/project-thread-o2kfe2",
            "git push -u --force-with-lease=refs/heads/claude/x:abcdef0 origin HEAD:claude/x",
            "git push origin HEAD:claude/x",
            "git push origin HEAD:refs/heads/claude/x",
            "git push origin +claude/x",
            "git push origin +HEAD:refs/heads/claude/x",
            "git push origin claude/x:claude/x",
            "git push -f origin claude/x",
            "git push --force origin HEAD:claude/x",
        ])

    def test_not_a_push(self):
        self.check(None, ["git status", "git pull origin root", "ls", "echo hello", "git log --oneline -3", "git commit -m 'Fix the pusher'",
                          "git fetch origin root"])

    def test_force_and_delete_denied(self):
        self.check("deny", [
            "git push --force origin root",
            "git push --force origin root",
            "git push -f origin main",
            "git push --force-with-lease origin root",
            "git push --force-with-lease=root origin claude/x",
            "git push --force-with-lease=claude/x:abcdef0 origin HEAD:root",
            "git push --force-with-lease=claude/x origin HEAD:refs/heads/root",
            "git push --force-with-lease=claude/x origin HEAD:refs/heads/claude/x HEAD:refs/heads/root",
            "git push -f origin +HEAD:refs/heads/claude/../root",
            "git push origin +root",
            "git push origin +refs/heads/root",
            "git push origin +HEAD:root",
            "git push origin :claude/x",
            "git push origin :root",
            "git push --delete origin claude/x",
            "git push -d origin claude/x",
            "git push --mirror origin",
            "git push --all origin",
            "git push --prune origin",
            "git push --force-with-lease origin claude/x claude/y +root",
        ])

    def test_prefixed_forms_never_allowed(self):
        self.check("deny", [
            "git -C /tmp/other push --force origin root",
            "git -c core.sshCommand=x push --force origin claude/x",
            "command git push -f origin root",
            "sudo git push --force origin root",
            "env FOO=1 git push --force origin root",
            "FOO=1 git push --force origin root",
            "/usr/bin/git push --force origin root",
            'bash -c "git push --force origin root"',
            "git --git-dir=/x push --force origin root",
            "git push --receive-pack=evil origin claude/x",
            "git push --exec=evil origin claude/x",
        ])
        self.check("ask", [
            "git -C /tmp/other push origin claude/x",
            "git -c user.name=x push origin claude/x",
            "command git push origin claude/x",
            "sudo git push origin claude/x",
            "env FOO=1 git push origin claude/x",
            "FOO=1 git push origin claude/x",
            "/usr/bin/git push origin claude/x",
            'bash -c "git push origin claude/x"',
            "git --git-dir=/x push origin claude/x",
        ])

    def test_other_pushes_ask(self):
        self.check("ask", [
            "git push",
            "git push origin root",
            "git push origin claude/x claude/y",
            "git push origin claude/x:root",
            "git push origin HEAD:root",
            "git push origin HEAD:refs/heads/main",
            "git push upstream claude/x",
            "git push --force-with-lease origin claude/x ",
            "git push --force-with-lease origin claude/x claude/y",
            "git push  origin claude/x",
            "git push --no-verify origin claude/x",
            "git push origin claude/x; git push origin root",
            "git push origin claude/x && git push origin root",
            "git push origin claude/x\ngit push origin root",
            "git push origin claude/x | cat",
            "git push origin $(echo root)",
        ])

    def test_branch_names(self):
        self.check("ask", [
            "git push origin claude/",
            "git push origin claude/x/",
            "git push origin claude//x",
            "git push origin claude/../root",
            "git push origin claude/x..y",
            "git push origin claude/x.lock",
            "git push origin claude/x.lock/y",
            "git push origin claude/x.",
            "git push origin claude/.hidden",
            "git push origin claude/x~1",
            "git push origin claude/x^",
            "git push origin claude/x*",
            "git push origin claude/x@{1}",
            "git push origin claude/a b",
            "git push origin claude/x\\y",
            "git push origin Claude/x",
            "git push origin HEAD:claude/x.lock",
            "git push origin HEAD:refs/heads/claude/../root",
        ])

    def test_aliases_and_configuration(self):
        self.check("deny", ["git -c alias.p=push p --force origin root"])
        self.check("ask", [
            "git -c alias.p=push p origin root",
            "git config alias.p push",
            "git config alias.st status",
            "git -c remote.origin.pushurl=https://example.com/x.git push origin claude/x",
            "git -c url.https://example.com/.pushInsteadOf=https://github.com/ push origin claude/x",
            "GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=remote.origin.pushurl git push origin claude/x",
        ])


if __name__ == "__main__":
    unittest.main()
