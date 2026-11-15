cbuffer Constants : register(b0)
{
    float4 pc_metrics : packoffset(c0);
    float4 pc_subsample : packoffset(c1);
    row_major float4x4 pc_reproject : packoffset(c2);
    float4 pc_resolve : packoffset(c6);
    float4 pc_depthmap : packoffset(c7);
};

Texture2D<float4> tex0 : register(t0);
SamplerState _tex0_sampler : register(s0);
Texture2D<float4> tex1 : register(t1);
SamplerState _tex1_sampler : register(s1);
Texture2D<float4> tex2 : register(t2);
SamplerState _tex2_sampler : register(s2);

static float4 o_color;
static float2 v_texcoord;
static float4 v_offset[3];
static float2 v_pixcoord;

struct SPIRV_Cross_Input
{
    float2 v_texcoord : TEXCOORD0;
    float2 v_pixcoord : TEXCOORD1;
    float4 v_offset[3] : TEXCOORD2;
};

struct SPIRV_Cross_Output
{
    float4 o_color : SV_Target0;
};

float2 SMAAColorEdgeDetectionPS(float2 texcoord, float4 offset[3], Texture2D<float4> colorTex, SamplerState _colorTex_sampler)
{
    float2 threshold = 0.0500000007450580596923828125f.xx;
    float3 C = colorTex.Sample(_colorTex_sampler, texcoord).xyz;
    float3 Cleft = colorTex.Sample(_colorTex_sampler, offset[0].xy).xyz;
    float3 t = abs(C - Cleft);
    float4 delta;
    delta.x = max(max(t.x, t.y), t.z);
    float3 Ctop = colorTex.Sample(_colorTex_sampler, offset[0].zw).xyz;
    t = abs(C - Ctop);
    delta.y = max(max(t.x, t.y), t.z);
    float2 edges = step(threshold, delta.xy);
    if (dot(edges, 1.0f.xx) == 0.0f)
    {
        discard;
    }
    float3 Cright = colorTex.Sample(_colorTex_sampler, offset[1].xy).xyz;
    t = abs(C - Cright);
    delta.z = max(max(t.x, t.y), t.z);
    float3 Cbottom = colorTex.Sample(_colorTex_sampler, offset[1].zw).xyz;
    t = abs(C - Cbottom);
    delta.w = max(max(t.x, t.y), t.z);
    float2 maxDelta = max(delta.xy, delta.zw);
    float3 Cleftleft = colorTex.Sample(_colorTex_sampler, offset[2].xy).xyz;
    t = abs(Cleft - Cleftleft);
    delta.z = max(max(t.x, t.y), t.z);
    float3 Ctoptop = colorTex.Sample(_colorTex_sampler, offset[2].zw).xyz;
    t = abs(Ctop - Ctoptop);
    delta.w = max(max(t.x, t.y), t.z);
    maxDelta = max(maxDelta, delta.zw);
    float finalDelta = max(maxDelta.x, maxDelta.y);
    edges *= step(finalDelta.xx, delta.xy * 2.0f);
    return edges;
}

void frag_main()
{
    float2 param = v_texcoord;
    float4 param_1[3] = v_offset;
    float2 _218 = SMAAColorEdgeDetectionPS(param, param_1, tex0, _tex0_sampler);
    o_color = float4(_218, 0.0f, 0.0f);
    if ((o_color.x + o_color.y) == 0.0f)
    {
        discard;
    }
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    v_texcoord = stage_input.v_texcoord;
    v_offset = stage_input.v_offset;
    v_pixcoord = stage_input.v_pixcoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_color = o_color;
    return stage_output;
}
