#!/usr/bin/env python3
"""Tests for .github/scripts/test-select.py: python3 tests/ci/test_select.py (also a ctest test, ci-test-select)."""
import glob
import importlib.util
import os
import unittest

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
spec = importlib.util.spec_from_file_location("test_select", os.path.join(ROOT, ".github", "scripts", "test-select.py"))
sel = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sel)

CFG = sel.load_config()


def suite_names():
    """The ctest names of the suite, named the way code_compiler/CMakeLists.txt does it."""
    names = ["suite-coverage", "lex-test", "tools-library"]
    for path in glob.glob(os.path.join(ROOT, "tests", "suite", "**", "*.bb"), recursive=True):
        rel = os.path.relpath(path, os.path.join(ROOT, "tests", "suite")).replace(os.sep, "/")
        if rel == "check.bb":
            continue
        base = rel[:-3].replace("/", "-")
        for prefix in ("suite", "suite-debug"):
            names.append(f"{prefix}-compile-{base}")
            if not rel.startswith("reject/"):
                names.append(f"{prefix}-run-{base}")
    return names


def run(*files, force=None):
    selection = sel.select(CFG, list(files), force)
    selected, skipped = sel.split_tests(CFG, selection, suite_names() + ["audio-output", "audio-output-debug", "cli-run", "format-check_diff", "tidy-fix", "gui-autosuspend-on", "close-prompt_pixels", "profile-on_pixels"])
    return selection, set(selected), skipped


class Selection(unittest.TestCase):
    def test_config_is_consistent(self):
        for rule in CFG["rules"]:
            sel.expand(CFG, rule["areas"])
        for aliased in CFG["aliases"].values():
            self.assertTrue(set(aliased) <= set(CFG["areas"]))

    def test_documentation_only_runs_nothing(self):
        selection, selected, _ = run("docs/wiki/Home.md", "README.adoc", "tools/wiki/pages/Foo.md", ".github/workflows/wiki.yml")
        self.assertEqual(selection["mode"], "none")
        self.assertEqual(selected, set())

    def test_unknown_file_runs_everything(self):
        selection, _, skipped = run("docs/wiki/Home.md", "some/new/place/file.txt")
        self.assertEqual(selection["mode"], "all")
        self.assertEqual(skipped, {})

    def test_shared_files_run_everything(self):
        for f in ("code_compiler/source/parser.cpp", "code_runtime/source/runtime.c", "code_runtime/source/graphics_internal.hpp", "CMakeLists.txt",
                  "cmake/foo.cmake", "third_party/SDL", ".github/workflows/test.yml", "tests/test_selection.json", ".github/scripts/test-select.py",
                  "code_runtime/CMakeLists.txt", "code_compiler/CMakeLists.txt"):
            self.assertEqual(run(f)[0]["mode"], "all", f)

    def test_empty_change_and_force_run_everything(self):
        self.assertEqual(run()[0]["mode"], "all")
        selection, selected, skipped = run("docs/wiki/Home.md", force="label")
        self.assertEqual((selection["mode"], skipped), ("all", {}))
        self.assertEqual(len(selected), len(suite_names()) + 8)

    def test_audio_change_skips_graphics_and_3d(self):
        selection, selected, skipped = run("code_runtime/source/sound.c")
        self.assertEqual(selection["areas"], ["audio"])
        self.assertIn("audio-output", selected)
        self.assertIn("suite-run-audio", selected)
        self.assertIn("suite-coverage", selected)  # no area: always runs
        self.assertTrue("suite-run-blitz3d_world" in skipped)
        self.assertTrue("cli-run" in skipped)
        self.assertFalse("suite-run-audio" in skipped)

    def test_3d_change_keeps_fixtures_together(self):
        _, selected, skipped = run("code_runtime/source/scene_meshes.cpp")
        for n in selected:
            if n.startswith("suite-compile-"):
                self.assertTrue(n.replace("-compile-", "-run-") in selected or "reject" in n or "pending" in n, n)
        self.assertIn("suite-compile-blitz3d_meshes", selected)
        self.assertIn("suite-run-blitz3d_meshes", selected)
        self.assertIn("suite-debug-run-blitz3d_meshes", selected)
        self.assertNotIn("suite-run-network", selected)

    def test_every_compile_and_run_pair_is_selected_together(self):
        for f in ("code_runtime/source/movie.cpp", "code_runtime/source/gui_widgets.cpp", "code_runtime/source/network.c", "tests/suite/images/pixels.webp"):
            _, selected, _ = run(f)
            for n in selected:
                if "-compile-" in n and not n.endswith(("coverage",)) and n.replace("-compile-", "-run-") in suite_names():
                    self.assertIn(n.replace("-compile-", "-run-"), selected, (f, n))

    def test_tools_change_only_runs_tool_tests(self):
        _, selected, skipped = run("code_format/source/main.cpp")
        self.assertIn("format-check_diff", selected)
        self.assertIn("tidy-fix", selected)  # the tools are one area: they share code_tools
        self.assertTrue("cli-run" in skipped)
        self.assertTrue("suite-run-blitz3d_world" in skipped)

    def test_changed_test_program_runs_only_itself(self):
        selection, selected, _ = run("tests/suite/blitz3d_world.bb")
        self.assertEqual(selection["suites"], ["blitz3d_world"])
        self.assertIn("suite-run-blitz3d_world", selected)
        self.assertIn("suite-debug-compile-blitz3d_world", selected)
        self.assertNotIn("suite-run-blitz3d_meshes", selected)

    def test_changed_failing_program_is_found_by_its_path(self):
        _, selected, _ = run("tests/suite/fail/runtimeerror.bb")
        self.assertIn("suite-run-fail-runtimeerror", selected)
        self.assertNotIn("suite-run-fail-bank_empty", selected)

    def test_areas_combine(self):
        selection, selected, _ = run("code_runtime/source/sound.c", "code_runtime/source/network.c")
        self.assertEqual(selection["areas"], ["audio", "network"])
        self.assertIn("suite-run-network", selected)
        self.assertIn("audio-output", selected)

    def test_a_shared_file_wins_over_small_ones(self):
        self.assertEqual(run("code_runtime/source/sound.c", "code_runtime/source/system.cpp")[0]["mode"], "all")

    def test_movie_tests_are_not_in_the_graphics_area(self):
        self.assertEqual(sel.area_of(CFG, "suite-run-graphics_movies_pixels"), "movies")
        self.assertEqual(sel.area_of(CFG, "suite-run-graphics_pixels"), "graphics")
        _, selected, _ = run("code_runtime/source/movie.cpp")
        self.assertNotIn("suite-run-graphics_pixels", selected)

    def test_every_suite_program_has_an_area(self):
        orphans = [n for n in suite_names() if n.startswith("suite-run-") and sel.area_of(CFG, n) is None]
        self.assertEqual(orphans, [], "These suite programs are in no area, so they run on every change; add them to tests/test_selection.json: " + ", ".join(orphans))


if __name__ == "__main__":
    unittest.main()
