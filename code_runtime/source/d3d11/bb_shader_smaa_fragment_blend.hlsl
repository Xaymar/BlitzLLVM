cbuffer Constants : register(b0)
{
    float4 pc_metrics : packoffset(c0);
    float4 pc_subsample : packoffset(c1);
    row_major float4x4 pc_reproject : packoffset(c2);
    float4 pc_resolve : packoffset(c6);
    float4 pc_depthmap : packoffset(c7);
};

Texture2D<float4> tex2 : register(t2);
SamplerState _tex2_sampler : register(s2);
Texture2D<float4> tex0 : register(t0);
SamplerState _tex0_sampler : register(s0);
Texture2D<float4> tex1 : register(t1);
SamplerState _tex1_sampler : register(s1);

static float4 gl_FragCoord;
static float2 v_texcoord;
static float4 o_color;
static float4 v_offset[3];
static float2 v_pixcoord;

struct SPIRV_Cross_Input
{
    float2 v_texcoord : TEXCOORD0;
    float2 v_pixcoord : TEXCOORD1;
    float4 v_offset[3] : TEXCOORD2;
    float4 gl_FragCoord : SV_Position;
};

struct SPIRV_Cross_Output
{
    float4 o_color : SV_Target0;
};

float mod(float x, float y)
{
    return x - y * floor(x / y);
}

float2 mod(float2 x, float2 y)
{
    return x - y * floor(x / y);
}

float3 mod(float3 x, float3 y)
{
    return x - y * floor(x / y);
}

float4 mod(float4 x, float4 y)
{
    return x - y * floor(x / y);
}

bool drawn_near(Texture2D<float4> depth, SamplerState _depth_sampler, float2 uv)
{
    float2 at = pc_depthmap.xy + (uv * pc_depthmap.zw);
    float2 _step = pc_depthmap.zw * pc_metrics.xy;
    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            if (depth.SampleLevel(_depth_sampler, at + (float2(float(x), float(y)) * _step), 0.0f).x > 0.0f)
            {
                return true;
            }
        }
    }
    return false;
}

void SMAAMovc(bool2 cond, inout float2 variable, float2 value)
{
    if (cond.x)
    {
        variable.x = value.x;
    }
    if (cond.y)
    {
        variable.y = value.y;
    }
}

void SMAAMovc(bool4 cond, inout float4 variable, float4 value)
{
    bool2 param = cond.xy;
    float2 param_1 = variable.xy;
    float2 param_2 = value.xy;
    SMAAMovc(param, param_1, param_2);
    variable.x = param_1.x;
    variable.y = param_1.y;
    bool2 param_3 = cond.zw;
    float2 param_4 = variable.zw;
    float2 param_5 = value.zw;
    SMAAMovc(param_3, param_4, param_5);
    variable.z = param_4.x;
    variable.w = param_4.y;
}

float4 SMAANeighborhoodBlendingPS(float2 texcoord, float4 offset, Texture2D<float4> colorTex, SamplerState _colorTex_sampler, Texture2D<float4> blendTex, SamplerState _blendTex_sampler)
{
    float4 a;
    a.x = blendTex.Sample(_blendTex_sampler, offset.xy).w;
    a.y = blendTex.Sample(_blendTex_sampler, offset.zw).y;
    float2 _118 = blendTex.Sample(_blendTex_sampler, texcoord).xz;
    a.w = _118.x;
    a.z = _118.y;
    if (dot(a, 1.0f.xxxx) < 9.9999997473787516355514526367188e-06f)
    {
        float4 color = colorTex.SampleLevel(_colorTex_sampler, texcoord, 0.0f);
        return color;
    }
    else
    {
        bool h = max(a.x, a.z) > max(a.y, a.w);
        float4 blendingOffset = float4(0.0f, a.y, 0.0f, a.w);
        float2 blendingWeight = a.yw;
        bool4 param = h.xxxx;
        float4 param_1 = blendingOffset;
        float4 param_2 = float4(a.x, 0.0f, a.z, 0.0f);
        SMAAMovc(param, param_1, param_2);
        blendingOffset = param_1;
        bool2 param_3 = h.xx;
        float2 param_4 = blendingWeight;
        float2 param_5 = a.xz;
        SMAAMovc(param_3, param_4, param_5);
        blendingWeight = param_4;
        blendingWeight /= dot(blendingWeight, 1.0f.xx).xx;
        float4 blendingCoord = mad(blendingOffset, float4(pc_metrics.xy, -pc_metrics.xy), texcoord.xyxy);
        float4 color_1 = colorTex.SampleLevel(_colorTex_sampler, blendingCoord.xy, 0.0f) * blendingWeight.x;
        color_1 += (colorTex.SampleLevel(_colorTex_sampler, blendingCoord.zw, 0.0f) * blendingWeight.y);
        return color_1;
    }
}

float bayer_offset(float2 xy)
{
    float levels = pc_subsample.w;
    float x = xy.x + pc_subsample.x;
    float y = xy.y - pc_subsample.y;
    float val = 0.0f;
    float div = 0.0f;
    for (int level = 1; level <= 8; level++)
    {
        float counts = step(float(level), levels);
        float mul = exp2(2.0f * ((levels - float(level)) + 1.0f));
        float scale = exp2(float(1 - level));
        float bx = mod(floor(x * scale), 2.0f);
        float by = mod(floor(y * scale), 2.0f);
        float x2 = bx * 2.0f;
        val += (((lerp(x2, 3.0f - x2, by) / 3.0f) * counts) * mul);
        div += (counts * mul);
    }
    float thresh = val / max(div, 9.9999999747524270787835121154785e-07f);
    float colors = exp2(2.0f * levels);
    float last = max(colors - 1.0f, 1.0f);
    float rank = floor((thresh * last) + 0.5f) + pc_subsample.z;
    rank -= (colors * floor(rank / colors));
    return ((rank / last) - 0.5f) / 255.0f;
}

float4 dithered(float4 color)
{
    if (pc_resolve.z == 0.0f)
    {
        return color;
    }
    float2 xy = floor(gl_FragCoord.xy);
    float _374;
    if (pc_subsample.w > 0.0f)
    {
        float2 param = xy;
        _374 = bayer_offset(param);
    }
    else
    {
        _374 = (frac(52.98291778564453125f * frac(dot(xy + (pc_resolve.z - 1.0f).xx, float2(0.067110560834407806396484375f, 0.005837149918079376220703125f)))) - 0.5f) / 255.0f;
    }
    float offset = _374;
    float3 steps = color.xyz * 255.0f;
    return float4(color.xyz + (step(0.015625f.xxx, abs(steps - floor(steps + 0.5f.xxx))) * offset), color.w);
}

void frag_main()
{
    bool _489 = pc_resolve.y > 0.5f;
    bool _499;
    if (_489)
    {
        float2 param = v_texcoord;
        _499 = !drawn_near(tex2, _tex2_sampler, param);
    }
    else
    {
        _499 = _489;
    }
    if (_499)
    {
        o_color = tex0.SampleLevel(_tex0_sampler, v_texcoord, 0.0f);
    }
    else
    {
        float2 param_1 = v_texcoord;
        float4 param_2 = v_offset[0];
        float4 param_3 = SMAANeighborhoodBlendingPS(param_1, param_2, tex0, _tex0_sampler, tex1, _tex1_sampler);
        o_color = dithered(param_3);
    }
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_FragCoord = stage_input.gl_FragCoord;
    gl_FragCoord.w = 1.0 / gl_FragCoord.w;
    v_texcoord = stage_input.v_texcoord;
    v_offset = stage_input.v_offset;
    v_pixcoord = stage_input.v_pixcoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_color = o_color;
    return stage_output;
}
