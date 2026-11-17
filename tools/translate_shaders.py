#!/usr/bin/env python3
# Translates the SPIR-V of the runtime (code_runtime/source/shaders.inc and smaa.inc) to GLSL 4.30 and HLSL shader model 5.0 with SPIRV-Cross,
# and checks that every module validates (spirv-val), translates, and that the GLSL compiles and the HLSL parses (glslangValidator). This is
# the check that the OpenGL and Direct3D 11 backends can be fed from the one set of shaders: see /docs and the RHI work. Needs spirv-cross,
# spirv-val and glslangValidator on PATH (Ubuntu: spirv-cross spirv-tools glslang-tools).
#
# The HLSL is made for bytecode that is compiled ahead of time (see d3d11_hlsl): registers are numbered for each kind over all sets, and
# specialization constants are members of a constant buffer. It is not compiled with the compiler of Direct3D here, which only Windows has.
#
# The GLSL is made for the OpenGL backend (see opengl_glsl): what a shader reads is named after its set and binding, as OpenGL has no sets
# and the backend gives out the texture units and buffer bindings when it links a program.
#
#   python3 tools/translate_shaders.py [--out DIR] [--d3d11 DIR] [--opengl FILE] [--keep-going]
#
# With --opengl code_runtime/source/shaders_opengl.inc the GLSL that the repository keeps is made again (one file, which the OpenGL
# backend includes). CI checks that it matches the SPIR-V. Run it after every change of the shaders.
# With --d3d11 code_runtime/source/d3d11 the HLSL that the repository keeps is made again. The Windows build compiles those files to
# bytecode (code_runtime/CMakeLists.txt), and CI checks that they match the SPIR-V. Run it after every change of the shaders.
# With --out the translated sources are written there (<name>.glsl, <name>.hlsl), and <name>.d3d11.json with the registers and constants of
# the HLSL. Exit status is 1 if a module that is not on the list of known gaps fails any step.
import argparse
import json
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


STD140 = {"float": (4, 4), "int": (4, 4), "uint": (4, 4), "vec2": (8, 8), "vec3": (12, 16), "vec4": (16, 16), "ivec4": (16, 16), "uvec4": (16, 16), "mat4": (64, 16)}  # Size and alignment.


def pad_uniform_blocks(glsl):
    """
    The uniform blocks whose members have explicit offsets (the scene block of the 3D shaders declares its members out of order, and a
    block of push constants may start after the part of another stage) are written without them, as offsets need OpenGL 4.4: the members
    are put in the order of their offsets, and floats that nothing reads fill the gaps. The names are by member number and so stay the
    same, and the std140 layout that results is checked against the offsets, so nothing changes for the shader.
    """
    def rewrite(block):
        members = []
        for line in block.group(2).rstrip("\n").split("\n"):
            m = re.fullmatch(r"    layout\(offset = (\d+)\) (\w+) (\w+)(?:\[(\d+)\])?;", line)
            if m is None:
                raise ValueError("a member of a uniform block is not handled: " + line.strip())
            members.append((int(m.group(1)), m.group(2), m.group(3), int(m.group(4)) if m.group(4) else 0))
        members.sort()
        lines, at, pads = [], 0, 0
        for offset, kind, name, count in members:
            if kind not in STD140:
                raise ValueError("a member of a uniform block has a type that is not handled: " + kind)
            size, align = STD140[kind]
            if count:
                size = align = (size + 15) // 16 * 16
            while (at + align - 1) // align * align < offset:
                at = (at + 3) // 4 * 4
                lines.append("    float bb_pad%d;" % pads)
                pads += 1
                at += 4
            at = (at + align - 1) // align * align
            if at != offset:
                raise ValueError("the member %s of a uniform block cannot be put at offset %d" % (name, offset))
            lines.append("    %s %s%s;" % (kind, name, "[%d]" % count if count else ""))
            at += size * (count if count else 1)
        return block.group(1) + "\n".join(lines) + "\n" + block.group(3)

    glsl = re.sub(r"(layout\([^)\n]*std140\) uniform \w+\n\{\n)((?:    layout\(offset = \d+\)[^\n]*\n)+)(\} \w+;)", rewrite, glsl)
    if "layout(offset" in glsl:
        raise ValueError("an explicit offset is used in a way that is not handled")
    return glsl.replace("#extension GL_ARB_enhanced_layouts : require\n", "")


def opengl_glsl(text, stage, places):
    """
    Makes the GLSL of SPIRV-Cross (translated from a module of flatten_bindings, with the push constants as a uniform block) fit the
    OpenGL backend. OpenGL has no sets and a program has one list of texture units and buffer bindings for all its stages, so the
    bindings are taken out and everything gets a name that says what it is, which the backend reads when it has linked a program:
    - bb_t<set>_<binding>_<stage> a sampler, bb_u<set>_<binding>_<stage> a uniform block, bb_b<set>_<binding>_<stage> a storage block,
    - bb_push_<stage> the block of the push constants.
    The stage (v, f or c) is in the name because the blocks of two stages need not declare the same members.
    The specialization constants stay #defines that are only set if nothing set them before: the backend puts its own after #version.
    """
    text = pad_uniform_blocks(text)
    where = {number: (group, binding) for number, group, binding in places}
    letter = stage[0]

    def sampler(m):
        return "uniform %s bb_t%d_%d_%s;" % (m.group(2), *where[int(m.group(1))], letter)

    renames = {}
    for m in re.finditer(r"^layout\(binding = (\d+)\) uniform (\w+) (\w+);$", text, flags=re.M):
        renames[m.group(3)] = "bb_t%d_%d_%s" % (*where[int(m.group(1))], letter)
    text = re.sub(r"^layout\(binding = (\d+)\) uniform (\w+) (\w+);$", sampler, text, flags=re.M)
    for old, new in renames.items():
        text = re.sub(r"\b%s\b" % re.escape(old), new, text)
    text = re.sub(r"^layout\(binding = (\d+), std140\) uniform \w+$", lambda m: "layout(std140) uniform bb_u%d_%d_%s" % (*where[int(m.group(1))], letter), text, flags=re.M)
    text = re.sub(r"^layout\(binding = (\d+), std430\) ((?:readonly |writeonly )?)buffer \w+$", lambda m: "layout(std430) %sbuffer bb_b%d_%d_%s" % (m.group(2), *where[int(m.group(1))], letter), text, flags=re.M)
    text, pushes = re.subn(r"^layout\(std140\) uniform (?!bb_u)\w+$", "layout(std140) uniform bb_push_%s" % letter, text, flags=re.M)
    if pushes > 1:
        raise ValueError("%d uniform blocks without a binding, expected at most the push constants" % pushes)
    if "binding =" in text:
        raise ValueError("a binding is used in a way that is not handled")
    return text


def fnv1a(data):
    value = 0xCBF29CE484222325
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def flatten_bindings(binary):
    """
    SPIRV-Cross numbers the registers of HLSL by binding and ignores the set, so two sets of a shader would share registers. Every
    (set, binding) of the module gets a number of its own here, written over the Binding decorations. Returns the new module and
    the list of (number, set, binding).
    """
    words = list(struct.unpack("<%dI" % (len(binary) // 4), binary))
    sets, bindings = {}, {}
    at = 5
    while at < len(words):
        count, opcode = words[at] >> 16, words[at] & 0xFFFF
        if opcode == 71 and words[at + 2] == 34:  # OpDecorate, DescriptorSet
            sets[words[at + 1]] = words[at + 3]
        elif opcode == 71 and words[at + 2] == 33:  # OpDecorate, Binding
            bindings[words[at + 1]] = at + 3
        at += count
    places = sorted({(sets.get(target, 0), words[where]) for target, where in bindings.items()})
    number = {place: index for index, place in enumerate(places)}
    for target, where in bindings.items():
        words[where] = number[(sets.get(target, 0), words[where])]
    return struct.pack("<%dI" % len(words), *words), [(index, place[0], place[1]) for index, place in enumerate(places)]


D3D11_LIMITS = {"t": 128, "s": 16, "b": 14, "u": 8}  # Slots of shader resources, samplers, constant buffers and unordered access views.
CONSTANT = re.compile(r"#ifndef SPIRV_CROSS_CONSTANT_ID_(\d+)\n#define SPIRV_CROSS_CONSTANT_ID_\1 ([^\n]+)\n#endif\nstatic const (\w+) (\w+) = SPIRV_CROSS_CONSTANT_ID_\1;\n")


def d3d11_vertex_fixups(text):
    """
    What Vulkan and Direct3D 11 do differently in a vertex shader, which the SPIR-V (made for Vulkan) does the Vulkan way:
    - Clip space has Y pointing down on Vulkan and up on Direct3D. The vertex shaders write the negated Y (here, in the shader and nowhere else), so that
      the framebuffer positions, the winding of triangles and every picture are the same as on Vulkan, with the viewport and the winding of the pipeline unchanged.
    - gl_InstanceIndex includes the first instance of the draw on Vulkan, while SV_InstanceID of Direct3D starts at 0. The shaders that read it (entity
      indices of 3D) take it from a vertex buffer of their own instead (BBINSTANCE, a stream of 0, 1, 2, ... that advances once per instance, and starts
      at the first instance of the draw): the backend binds it as buffer 1 of the input layout.
    """
    text = text.replace("stage_output.gl_Position = gl_Position;", "stage_output.gl_Position = float4(gl_Position.x, -gl_Position.y, gl_Position.z, gl_Position.w);")
    text = text.replace("uint gl_InstanceIndex : SV_InstanceID;", "uint gl_InstanceIndex : BBINSTANCE;")
    return text


def d3d11_hlsl(text, places):
    """
    Makes the HLSL of SPIRV-Cross (translated from a module of flatten_bindings) fit Direct3D 11 with bytecode compiled ahead of time:
    - The registers are numbered from 0 for each kind (t, s, b, u), in the order of (set, binding).
    - The specialization constants, which SPIRV-Cross turns into #defines, become members of one constant buffer (bb_constants), as
      their values are only known when a pipeline is made. Each is 4 bytes, in the order of their ids.
    - The block of push constants gets a register after those (push_register).
    Returns the text and the description for the backend: the registers of every (set, binding), the constants and the push constants.
    """
    used = {}
    for kind, number in re.findall(r"register\(([tsbu])(\d+)\)", text):
        used.setdefault(kind, set()).add(int(number))
    compact = {kind: {number: index for index, number in enumerate(sorted(numbers))} for kind, numbers in used.items()}
    text = re.sub(r"register\(([tsbu])(\d+)\)", lambda m: "register(%s%d)" % (m.group(1), compact[m.group(1)][int(m.group(2))]), text)
    registers = []
    for number, group, binding in places:
        for kind in "tsbu":
            if number in compact.get(kind, {}):
                registers.append({"set": group, "binding": binding, "kind": kind, "register": compact[kind][number]})
    constants = sorted(((int(m.group(1)), m.group(3), m.group(4), m.group(2)) for m in CONSTANT.finditer(text)))
    described = []
    if constants:
        slot = len(compact.get("b", {}))
        compact.setdefault("b", {})[-1] = slot
        members, defines = [], []
        for index, (ident, kind, name, default) in enumerate(constants):
            if kind == "bool":
                members.append("    uint bb_constant_%d;" % ident)
                defines.append("#define %s (bb_constant_%d != 0u)" % (name, ident))
            elif kind in ("float", "int", "uint"):
                members.append("    %s bb_constant_%d;" % (kind, ident))
                defines.append("#define %s bb_constant_%d" % (name, ident))
            else:
                raise ValueError("a specialization constant of type %s is not handled" % kind)
            described.append({"id": ident, "type": kind, "offset": index * 4, "default": default})
        block = "cbuffer bb_constants : register(b%d)\n{\n%s\n};\n%s\n" % (slot, "\n".join(members), "\n".join(defines))
        first = CONSTANT.search(text).start()
        text = CONSTANT.sub("", text)
        text = text[:first] + block + text[first:]
        if "SPIRV_CROSS_CONSTANT_ID" in text:
            raise ValueError("a specialization constant is used in a way that is not handled")
    # The block of push constants has no binding, so SPIRV-Cross gives it no register and the compiler would pick one. It gets the next free one.
    push = None
    blocks = re.findall(r"^cbuffer (\w+)\n", text, flags=re.M)
    if len(blocks) > 1:
        raise ValueError("%d constant buffers without a binding, expected at most the push constants" % len(blocks))
    if blocks:
        push = len(compact.get("b", {}))
        compact.setdefault("b", {})[-2] = push
        text = re.sub(r"^cbuffer (\w+)\n", lambda m: "cbuffer %s : register(b%d)\n" % (m.group(1), push), text, flags=re.M)
    text = d3d11_vertex_fixups(text)
    for kind, limit in D3D11_LIMITS.items():
        if len(compact.get(kind, {})) > limit:
            raise ValueError("%d registers of kind %s, Direct3D 11 has %d" % (len(compact[kind]), kind, limit))
    return text, {"registers": registers, "constants": described, "constants_register": compact["b"][-1] if constants else None, "push_register": push}


def run(args, **kw):
    return subprocess.run(args, capture_output=True, text=True, **kw)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", help="write the translated sources here")
    parser.add_argument("--d3d11", help="write only the HLSL and its descriptions here, replacing what is there (code_runtime/source/d3d11)")
    parser.add_argument("--opengl", help="write the GLSL of every shader to this one file, replacing it (code_runtime/source/shaders_opengl.inc)")
    parser.add_argument("--keep-going", action="store_true", help="always exit 0")
    options = parser.parse_args()
    for tool in ("spirv-cross", "spirv-val", "glslangValidator"):
        if shutil.which(tool) is None:
            print("missing tool:", tool, file=sys.stderr)
            return 2
    if options.out:
        os.makedirs(options.out, exist_ok=True)
    if options.d3d11:
        os.makedirs(options.d3d11, exist_ok=True)
        for old in os.listdir(options.d3d11):
            if old.endswith((".hlsl", ".d3d11.json")):
                os.remove(os.path.join(options.d3d11, old))
    failed = 0
    opengl = []
    with tempfile.TemporaryDirectory() as tmp:
        for name, binary in modules():
            spv = os.path.join(tmp, name + ".spv")
            open(spv, "wb").write(binary)
            results = {}
            r = run(["spirv-val", "--target-env", "vulkan1.3", spv])
            results["valid"] = None if r.returncode == 0 else (r.stderr.strip().splitlines() or ["failed"])[0]
            flat, places = flatten_bindings(binary)
            flat_spv = os.path.join(tmp, name + ".flat.spv")
            open(flat_spv, "wb").write(flat)
            glsl_path = os.path.join(tmp, name + ".glsl")
            r = run(["spirv-cross", "--version", "430", "--no-es", "--glsl-emit-push-constant-as-ubo", flat_spv, "--output", glsl_path])
            if r.returncode != 0:
                results["glsl"] = (r.stderr.strip().splitlines() or ["failed"])[0]
            else:
                try:
                    text = opengl_glsl(open(glsl_path).read(), stage_of(name), places)
                    open(glsl_path, "w").write(text)
                    # The extensions that SPIRV-Cross only asks for if the driver has them (draw parameters) are switched on for the check (which compiles as 4.60, the validator knows the extensions only there): drivers without them get the first instance another way (see the RHI).
                    checked = os.path.join(tmp, name + ".check.glsl")
                    open(checked, "w").write(re.sub(r"#ifdef GL_ARB_\w+\n(#extension [^\n]*\n)#endif\n", r"\1", text).replace("#version 430", "#version 460", 1))
                    r = run(["glslangValidator", "-S", stage_of(name), checked])
                    results["glsl"] = None if r.returncode == 0 else next((l for l in r.stdout.splitlines() if "ERROR" in l), "failed")
                    if results["glsl"] is None:
                        opengl.append((name, len(binary) // 4, fnv1a(binary), stage_of(name), text))
                except ValueError as problem:
                    results["glsl"] = str(problem)
            hlsl_path = os.path.join(tmp, name + ".hlsl")
            map_path = os.path.join(tmp, name + ".d3d11.json")
            r = run(["spirv-cross", "--hlsl", "--shader-model", "50", flat_spv, "--output", hlsl_path])
            if r.returncode != 0:
                results["hlsl"] = (r.stderr.strip().splitlines() or ["failed"])[-1]
            else:
                try:
                    text, description = d3d11_hlsl(open(hlsl_path).read(), places)
                    open(hlsl_path, "w").write(text)
                    open(map_path, "w").write(json.dumps(description, indent=1) + "\n")
                    # Not the compiler of Direct3D (fxc), which only Windows has: this catches what is not HLSL at all.
                    r = run(["glslangValidator", "-D", "-V", "-e", "main", "-S", stage_of(name), "-o", os.path.join(tmp, name + ".check.spv"), hlsl_path])
                    results["hlsl"] = None if r.returncode == 0 else next((l for l in r.stdout.splitlines() if "ERROR" in l), "failed")
                except ValueError as problem:
                    results["hlsl"] = str(problem)
            if options.out:
                for ext, path in (("glsl", glsl_path), ("hlsl", hlsl_path), ("d3d11.json", map_path)):
                    if os.path.exists(path):
                        shutil.copy(path, os.path.join(options.out, name + "." + ext))
            if options.d3d11 and results.get("hlsl") is None:
                shutil.copy(hlsl_path, os.path.join(options.d3d11, name + ".hlsl"))
                shutil.copy(map_path, os.path.join(options.d3d11, name + ".d3d11.json"))
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
    if options.opengl:
        with open(options.opengl, "w") as out:
            out.write("// Generated by tools/translate_shaders.py --opengl from shaders.inc and smaa.inc, do not edit: the shaders as GLSL 4.30 for the OpenGL backend.\n")
            out.write("// Each entry: the name, the number of SPIR-V words and their FNV-1a hash (which the backend finds the entry by), the stage, and the source.\n")
            for name, words, digest, stage, text in opengl:
                if ')glsl"' in text:
                    raise SystemExit("the GLSL of %s cannot be written as a raw string" % name)
                out.write('BB_OPENGL_SHADER(%s, %d, 0x%016Xull, \'%s\', R"glsl(%s)glsl")\n' % (name, words, digest, stage[0], text))
    print("%d unexpected failure(s)" % failed)
    return 0 if (failed == 0 or options.keep_going) else 1


if __name__ == "__main__":
    sys.exit(main())
