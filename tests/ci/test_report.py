#!/usr/bin/env python3
"""Tests for .github/scripts/test-report.py: python3 tests/ci/test_report.py (also a ctest test, ci-test-report)."""
import importlib.util
import io
import json
import os
import sys
import tempfile
import unittest
from contextlib import redirect_stdout

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
spec = importlib.util.spec_from_file_location("test_report", os.path.join(ROOT, ".github", "scripts", "test-report.py"))
rep = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rep)

TESTS = ["lex-test", "suite-run-a", "suite-debug-run-a", "suite-run-b", "suite-debug-run-b"]
JUNIT = """<testsuite>
<testcase name="lex-test"/><testcase name="suite-run-a"/><testcase name="suite-debug-run-a"/>
<testcase name="suite-run-b"><failure message="x"/><system-out>FAIL: expected 3, got 4</system-out></testcase>
<testcase name="suite-debug-run-b"/></testsuite>"""


def render(state, junit=None, tests=TESTS):
    with tempfile.TemporaryDirectory() as d:
        argv = ["test-report.py", "--state", state, "--sha", "abcdef123", "--tests", os.path.join(d, "t.json")]
        with open(os.path.join(d, "t.json"), "w", encoding="utf-8") as f:
            json.dump({"tests": [{"name": n} for n in tests]}, f)
        if junit:
            with open(os.path.join(d, "j.xml"), "w", encoding="utf-8") as f:
                f.write(junit)
            argv += ["--junit", os.path.join(d, "j.xml")]
        out = io.StringIO()
        old = sys.argv
        sys.argv = argv
        try:
            with redirect_stdout(out):
                rep.main()
        finally:
            sys.argv = old
        return out.getvalue()


class ReportTest(unittest.TestCase):
    def test_pending_table_is_folded(self):
        text = render("pending")
        self.assertIn("<details><summary>Tests (5)</summary>", text)
        self.assertLess(text.index("5 tests"), text.index("<details>"))

    def test_failed_test_is_visible_with_output(self):
        text = render("done", JUNIT)
        visible = text.split("<details>")[0]
        self.assertIn("`suite-run-b`", visible)
        self.assertIn("FAIL: expected 3, got 4", visible)
        self.assertNotIn("`lex-test`", visible)

    def test_passed_tests_are_folded(self):
        text = render("done", JUNIT)
        folded = text.split("<details>")[1]
        self.assertIn("`lex-test`", folded)
        self.assertIn("`suite-run-a`", folded)

    def test_all_passed_has_no_visible_table(self):
        text = render("done", JUNIT.replace("<failure message=\"x\"/>", ""))
        self.assertNotIn("| `", text.split("<details>")[0])
        self.assertIn("Tests passed", text)


if __name__ == "__main__":
    unittest.main()
