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


def render(state, junit=None, tests=TESTS, others=()):
    """others: more platforms, as (name, tests, junit)."""
    with tempfile.TemporaryDirectory() as d:
        argv = ["test-report.py", "--state", state, "--sha", "abcdef123"]
        for number, (name, names, xml) in enumerate([("Linux", tests, junit)] + list(others)):
            with open(os.path.join(d, f"t{number}.json"), "w", encoding="utf-8") as f:
                json.dump({"tests": [{"name": n} for n in names]}, f)
            files = os.path.join(d, f"t{number}.json") + ","
            if xml:
                with open(os.path.join(d, f"j{number}.xml"), "w", encoding="utf-8") as f:
                    f.write(xml)
                files += os.path.join(d, f"j{number}.xml")
            argv += ["--platform", f"{name}={files}"]
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
        self.assertIn("<details><summary>Tests (3)</summary>", text)
        self.assertLess(text.index("5 test runs"), text.index("<details>"))

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

    def test_platforms_have_their_own_columns(self):
        windows = '<testsuite><testcase name="lex-test"/><testcase name="suite-run-a"><failure message="x"/><system-out>boom</system-out></testcase></testsuite>'
        text = render("done", JUNIT, others=[("Windows", ["lex-test", "suite-run-a"], windows)])
        self.assertIn("| Test | Linux Debug | Linux Release | Windows Debug | Windows Release |", text)
        visible = text.split("<details>")[0]
        self.assertIn("`suite-run-a`", visible)
        self.assertIn("(Windows)", visible)
        self.assertIn("`suite-run-b`", visible)

    def test_platform_without_results_is_named(self):
        text = render("done", JUNIT, others=[("macOS", [], None)])
        self.assertIn("No results from macOS", text)


if __name__ == "__main__":
    unittest.main()
