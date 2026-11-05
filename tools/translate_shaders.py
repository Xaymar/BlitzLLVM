#!/usr/bin/env python3
# Translates the SPIR-V of the runtime (code_runtime/source/shaders.inc and smaa.inc) to GLSL 4.30 and HLSL shader model 5.0 with SPIRV-Cross,
# and checks that every module validates (spirv-val), translates, and that the GLSL compiles (glslangValidator). This is the check that the
# OpenGL and Direct3D 11 backends can be fed from the one set of shaders: see /docs and the RHI work. Needs spirv-cross, spirv-val and
# glslangValidator on PATH (Ubuntu: spirv-cross spirv-tools glslang-tools).
#
#   python3 tools/translate_shaders.py [--out DIR] [--keep-going]
#
# With --out the translated sources are written there (<name>.glsl, <name>.hlsl). Exit status is 1 if a module that is not on the list of
# known gaps fails any step.
import argparse
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCES = [os.path.join(ROOT, "code_runtime", "source", n) for n in ("shaders.inc", "smaa.inc")]

# Known gaps, by module and step. Each says why, so that a fix removes the entry.
KNOWN = {}


def modules():
    for path in SOURCES:
        text = open(path).read()
        parts = re.split(r"static const unsigned int (\w+)\[\] = \{", text)
        for i in range(1, len(parts), 2):
            words = [int(x, 16) for x in re.findall(r"0x[0-9a-fA-F]+", parts[i + 1].split("};")[0])]
            yield parts[i], struct.pack("<%dI" % len(words), *words)


def stage_of(name):
    if "compute" in name:
        return "comp"
    return "frag" if "fragment" in name else "vert"


def sort_scene_block(glsl):
    """
    The scene block of the 3D shaders declares its members out of order (the table of lights comes last in memory but not in the
    declaration). GLSL wants offsets to rise, so the declarations are put in the order of their offsets here. The names are by member
    number and so stay the same, and the offsets are what the layout means, so nothing changes for the shader.
    """
    block = re.search(r"(layout\(binding = \d+, std140\) uniform \w+\n\{\n)((?:    layout\(offset = \d+\)[^\n]*\n)+)(\} \w+;)", glsl)
    if block is None:
        return glsl
    lines = block.group(2).rstrip("\n").split("\n")
    lines.sort(key=lambda line: int(re.search(r"offset = (\d+)", line).group(1)))
    lines = [re.sub(r"layout\(offset = \d+\) ", "", line) for line in lines]
    glsl = glsl[: block.start(2)] + "\n".join(lines) + "\n" + glsl[block.end(2):]
    return glsl.replace("#extension GL_ARB_enhanced_layouts : require\n", "")


def run(args, **kw):
    return subprocess.run(args, capture_output=True, text=True, **kw)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", help="write the translated sources here")
    parser.add_argument("--keep-going", action="store_true", help="always exit 0")
    options = parser.parse_args()
    for tool in ("spirv-cross", "spirv-val", "glslangValidator"):
        if shutil.which(tool) is None:
            print("missing tool:", tool, file=sys.stderr)
            return 2
    if options.out:
        os.makedirs(options.out, exist_ok=True)
    failed = 0
    with tempfile.TemporaryDirectory() as tmp:
        for name, binary in modules():
            spv = os.path.join(tmp, name + ".spv")
            open(spv, "wb").write(binary)
            results = {}
            r = run(["spirv-val", "--target-env", "vulkan1.3", spv])
            results["valid"] = None if r.returncode == 0 else (r.stderr.strip().splitlines() or ["failed"])[0]
            glsl_path = os.path.join(tmp, name + ".glsl")
            r = run(["spirv-cross", "--version", "430", "--no-es", spv, "--output", glsl_path])
            if r.returncode != 0:
                results["glsl"] = (r.stderr.strip().splitlines() or ["failed"])[0]
            else:
                text = sort_scene_block(open(glsl_path).read())
                open(glsl_path, "w").write(text)
                # The extensions that SPIRV-Cross only asks for if the driver has them (draw parameters) are switched on for the check (which compiles as 4.60, the validator knows the extensions only there): drivers without them get the first instance another way (see the RHI).
                checked = os.path.join(tmp, name + ".check.glsl")
                open(checked, "w").write(re.sub(r"#ifdef GL_ARB_\w+\n(#extension [^\n]*\n)#endif\n", r"\1", text).replace("#version 430", "#version 460", 1))
                r = run(["glslangValidator", "-S", stage_of(name), checked])
                results["glsl"] = None if r.returncode == 0 else next((l for l in r.stdout.splitlines() if "ERROR" in l), "failed")
            hlsl_path = os.path.join(tmp, name + ".hlsl")
            r = run(["spirv-cross", "--hlsl", "--shader-model", "50", spv, "--output", hlsl_path])
            results["hlsl"] = None if r.returncode == 0 else (r.stderr.strip().splitlines() or ["failed"])[-1]
            if options.out:
                for ext, path in (("glsl", glsl_path), ("hlsl", hlsl_path)):
                    if os.path.exists(path):
                        shutil.copy(path, os.path.join(options.out, name + "." + ext))
            status = []
            for step in ("valid", "glsl", "hlsl"):
                problem = results[step]
                if problem is None:
                    status.append(step + ": ok")
                elif (name, step) in KNOWN:
                    status.append(step + ": known gap (%s)" % KNOWN[(name, step)])
                else:
                    status.append(step + ": FAILED " + problem)
                    failed += 1
            print("%-44s %s" % (name, " | ".join(status)))
    print("%d unexpected failure(s)" % failed)
    return 0 if (failed == 0 or options.keep_going) else 1


if __name__ == "__main__":
    sys.exit(main())
