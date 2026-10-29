// SMAA passes for Vulkan GLSL, compiled to SPIR-V by tools/generate_smaa.py with glslangValidator.
// One of PASS_EDGES, PASS_WEIGHTS, PASS_BLEND or PASS_RESOLVE and one of STAGE_VERT or STAGE_FRAG is defined.
#version 450
#extension GL_GOOGLE_include_directive : require

layout(push_constant) uniform Constants {
	vec4 metrics;   // 1 / width, 1 / height, width, height of the picture.
	vec4 subsample; // subsampleIndices of the weights pass.
	mat4 reproject; // Resolve: from (x, y, depth, 1) in the clip space of this frame to that of the last one.
	vec4 resolve;   // Resolve: weight of the last frame, offset of the last frame's picture in pixels (zw).
} pc;

#define SMAA_RT_METRICS pc.metrics
#define SMAA_GLSL_4
#define SMAA_PRESET_ULTRA
#ifdef STAGE_VERT
#define SMAA_INCLUDE_PS 0
#else
#define SMAA_INCLUDE_VS 0
#endif
#include "SMAA.hlsl"
// The header passes a bias where an offset belongs.
#undef SMAASampleOffset
#define SMAASampleOffset(tex, coord, offset) texture(tex, coord + offset * SMAA_RT_METRICS.xy)

#ifdef STAGE_VERT
layout(location = 0) out vec2 v_texcoord;
layout(location = 1) out vec2 v_pixcoord;
layout(location = 2) out vec4 v_offset[3];

void main()
{
	vec2 corner = vec2(float((gl_VertexIndex << 1) & 2), float(gl_VertexIndex & 2));
	gl_Position = vec4(corner * 2.0 - 1.0, 0.0, 1.0);
	v_texcoord  = corner;
	v_pixcoord  = vec2(0.0);
	v_offset[0] = v_offset[1] = v_offset[2] = vec4(0.0);
#if defined(PASS_EDGES)
	SMAAEdgeDetectionVS(corner, v_offset);
#elif defined(PASS_WEIGHTS)
	SMAABlendingWeightCalculationVS(corner, v_pixcoord, v_offset);
#elif defined(PASS_BLEND)
	SMAANeighborhoodBlendingVS(corner, v_offset[0]);
#endif
}
#else
layout(set = 0, binding = 0) uniform sampler2D tex0;
layout(set = 0, binding = 1) uniform sampler2D tex1;
layout(set = 0, binding = 2) uniform sampler2D tex2;
layout(location = 0) in vec2 v_texcoord;
layout(location = 1) in vec2 v_pixcoord;
layout(location = 2) in vec4 v_offset[3];
layout(location = 0) out vec4 o_color;

#if defined(PASS_RESOLVE)
float luma(vec3 c)
{
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}
#endif

void main()
{
#if defined(PASS_EDGES)
	// tex0: the picture.
	o_color = vec4(SMAAColorEdgeDetectionPS(v_texcoord, v_offset, tex0), 0.0, 0.0);
	if (o_color.r + o_color.g == 0.0) {
		discard;
	}
#elif defined(PASS_WEIGHTS)
	// tex0: edges, tex1: area, tex2: search.
	o_color = SMAABlendingWeightCalculationPS(v_texcoord, v_pixcoord, v_offset, tex0, tex1, tex2, pc.subsample);
#elif defined(PASS_BLEND)
	// tex0: the picture, tex1: blend weights.
	o_color = SMAANeighborhoodBlendingPS(v_texcoord, v_offset[0], tex0, tex1);
#elif defined(PASS_RESOLVE)
	// tex0: this frame, tex1: the last frame, tex2: depth. SMAA T2x with the motion of the camera as velocity: where
	// everything was last frame follows from the depth and the matrices of both frames.
	vec4 current = textureLod(tex0, v_texcoord, 0.0);
	vec2 size    = pc.metrics.zw;
	vec2 ndc     = (v_texcoord * size - 0.5) / size * 2.0 - 1.0;
	float depth  = textureLod(tex2, v_texcoord, 0.0).r;
	vec4 moved   = pc.reproject * vec4(ndc, depth, 1.0);
	vec2 previous_ndc = moved.xy / moved.w;
	vec2 uv      = ((previous_ndc * 0.5 + 0.5) * size + 0.5) / size;
	float weight = pc.resolve.x;
	if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0))) || (moved.w <= 0.0)) {
		weight = 0.0;
	}
	vec4 history = textureLod(tex1, uv, 0.0);
	// What the neighborhood of the pixel does not contain can not be this pixel, which keeps things that moved from smearing.
	vec3 low = current.rgb, high = current.rgb;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec3 c = textureLod(tex0, v_texcoord + vec2(x, y) * pc.metrics.xy, 0.0).rgb;
			low = min(low, c);
			high = max(high, c);
		}
	}
	history.rgb = clamp(history.rgb, low, high);
	o_color = vec4(mix(current.rgb, history.rgb, weight), current.a);
#endif
}
#endif
