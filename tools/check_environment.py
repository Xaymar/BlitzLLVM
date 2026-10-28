#!/usr/bin/env python3
"""Checks that the environment variables of BlitzLLVM follow one scheme (see the wiki page Environment-Variables):

* the runtime reads them only through bb_env* (environment.c), with names that start with BLITZLLVM_;
* every BLITZLLVM_ name that the runtime or the compiler reads is listed on the wiki page;
* every old name in the table of environment.c has its new name there.

Usage: check_environment.py [repository root]
"""
import os, re, sys

root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), ".."))
problems = []

def read(path):
    with open(os.path.join(root, path), encoding="utf-8", errors="replace") as f:
        return f.read()

page = read("tools/wiki/pages/Environment-Variables.md")
documented = set(re.findall(r"`(BLITZLLVM_[A-Z0-9_]+)(?:=[^`]*)?`", page))

read_names = set()
for directory in ("code_runtime/source", "code_compiler/source", "code_tidy/source", "code_format/source"):
    for name in sorted(os.listdir(os.path.join(root, directory))):
        if not name.endswith((".c", ".cpp", ".h", ".hpp", ".inc")):
            continue
        path = directory + "/" + name
        text = read(path)
        for call in re.finditer(r"\b(bb_env(?:_bool|_int|_double)?|getenv|SDL_getenv|std::getenv)\(\s*\"([A-Za-z0-9_]+)\"", text):
            function, variable = call.groups()
            if function.startswith("bb_env"):
                if not variable.startswith("BLITZLLVM_"):
                    problems.append("%s: %s reads %s, which does not start with BLITZLLVM_" % (path, function, variable))
                read_names.add(variable)
            elif variable.startswith("BLITZ_") or variable.startswith("BLITZLLVM_"):
                if path != "code_runtime/source/environment.c" and not variable.startswith("BLITZLLVM_") or directory == "code_runtime/source":
                    problems.append("%s: reads %s with %s; use bb_env* so the old names and the switch rules apply" % (path, variable, function))
                if variable.startswith("BLITZLLVM_"):
                    read_names.add(variable)

for variable in sorted(read_names - documented):
    problems.append("%s is read but not on the wiki page Environment-Variables" % variable)

table = read("code_runtime/source/environment.c")
for new, old in re.findall(r'\{"(BLITZLLVM_[A-Z0-9_]+)", "(BLITZ_[A-Z0-9_]+)"', table):
    if new not in documented:
        problems.append("%s (the new name of %s) is not on the wiki page" % (new, old))
    if "`" + old + "`" not in page:
        problems.append("%s is not in the table of old names on the wiki page" % old)

for problem in problems:
    print("environment: " + problem)
sys.exit(1 if problems else 0)
