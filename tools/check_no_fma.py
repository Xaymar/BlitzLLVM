#!/usr/bin/env python3
"""Checks that the given libraries contain no fused multiply-add instructions.

The default fast-math mode "precise" promises float results that are the same on every CPU, and a fused multiply-add rounds once where
a multiply and an add round twice. The compiler is told not to fuse (-ffp-contract=off, /fp:precise), and this check disassembles the
built runtime to prove it, on the platforms where nobody can look at it by hand (Windows on ARM64).

Usage: check_no_fma.py [--arch ARCH] [--require] library...
  --arch     Which slice of a universal (Mach-O) library to look at, e.g. arm64.
  --require  Fail when there is no disassembler (otherwise that is a warning and the check passes).
"""
import glob, os, re, shutil, subprocess, sys

# AArch64: the scalar and the vector forms. x86: the VEX/EVEX forms (FMA3) and the old FMA4 ones.
FUSED = re.compile(r"\s(fn?m(add|sub)|fml[as]|vfn?m(add|sub)\w*|vfm(addsub|subadd)\w*)\b", re.I)

def disassembler():
    for name in ("llvm-objdump", "objdump"):
        found = shutil.which(name)
        if found:
            return found
    patterns = [os.path.join(os.environ.get("BLITZLLVM_MSYS2", ""), "*", "bin", "llvm-objdump*"),
                r"C:\Program Files\LLVM\bin\llvm-objdump.exe",
                r"C:\Program Files\Microsoft Visual Studio\*\*\VC\Tools\Llvm\*\bin\llvm-objdump.exe"]
    for pattern in patterns:
        for found in sorted(glob.glob(pattern)):
            if os.path.isfile(found):
                return found
    return None

def main(argv):
    arch, require, libraries = None, False, []
    args = iter(argv)
    for arg in args:
        if arg == "--arch":
            arch = next(args)
        elif arg == "--require":
            require = True
        else:
            libraries.append(arg)
    if not libraries:
        print(__doc__)
        return 2
    tool = disassembler()
    if tool is None:
        print(("error" if require else "warning") + ": no disassembler (llvm-objdump) found, the check did not run")
        return 1 if require else 0
    status = 0
    for library in libraries:
        command = [tool, "-d", "--no-show-raw-insn"]
        if arch:
            command.append("--arch=" + arch)
        command.append(library)
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, errors="replace")
        if result.returncode != 0:
            print("error: %s failed on %s: %s" % (os.path.basename(tool), library, result.stderr.strip()))
            status = 1
            continue
        function, total, hits = "?", 0, []
        for line in result.stdout.splitlines():
            label = re.match(r"^[0-9a-f]+ <(.*)>:$", line)
            if label:
                function = label.group(1)
            elif re.match(r"^\s+[0-9a-f]+:\s", line):
                total += 1
                if FUSED.search(line.split(":", 1)[1]):
                    hits.append((function, line.strip()))
        if total == 0:
            print("error: no instructions in %s, the disassembly did not work" % library)
            status = 1
        elif hits:
            print("error: %d fused multiply-add instruction(s) in %s:" % (len(hits), library))
            for function, line in hits[:50]:
                print("  %s: %s" % (function, line))
            status = 1
        else:
            print("ok: %s (%d instructions, none fused)" % (library, total))
    return status

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
