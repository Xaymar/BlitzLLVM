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
Texture2D<float4> tex2 : register(t2);
SamplerState _tex2_sampler : register(s2);
Texture2D<float4> tex1 : register(t1);
SamplerState _tex1_sampler : register(s1);

static float4 gl_FragCoord;
static float2 v_texcoord;
static float4 o_color;
static float2 v_pixcoord;
static float4 v_offset[3];

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
    float _182;
    if (pc_subsample.w > 0.0f)
    {
        float2 param = xy;
        _182 = bayer_offset(param);
    }
    else
    {
        _182 = (frac(52.98291778564453125f * frac(dot(xy + (pc_resolve.z - 1.0f).xx, float2(0.067110560834407806396484375f, 0.005837149918079376220703125f)))) - 0.5f) / 255.0f;
    }
    float offset = _182;
    float3 steps = color.xyz * 255.0f;
    return float4(color.xyz + (step(0.015625f.xxx, abs(steps - floor(steps + 0.5f.xxx))) * offset), color.w);
}

void frag_main()
{
    float4 current = tex0.SampleLevel(_tex0_sampler, v_texcoord, 0.0f);
    bool _306 = pc_resolve.x == 0.0f;
    bool _321;
    if (!_306)
    {
        bool _312 = pc_resolve.y > 0.5f;
        bool _320;
        if (_312)
        {
            float2 param = v_texcoord;
            _320 = !drawn_near(tex2, _tex2_sampler, param);
        }
        else
        {
            _320 = _312;
        }
        _321 = _320;
    }
    else
    {
        _321 = _306;
    }
    if (_321)
    {
        float4 param_1 = current;
        o_color = dithered(param_1);
        return;
    }
    float2 size = pc_metrics.zw;
    float2 ndc = ((((v_texcoord * size) - 0.5f.xx) / size) * 2.0f) - 1.0f.xx;
    float depth = tex2.SampleLevel(_tex2_sampler, pc_depthmap.xy + (v_texcoord * pc_depthmap.zw), 0.0f).x;
    float4 moved = mul(float4(ndc, depth, 1.0f), pc_reproject);
    float2 previous_ndc = moved.xy / moved.w.xx;
    float2 uv = ((((previous_ndc * 0.5f) + 0.5f.xx) * size) + 0.5f.xx) / size;
    float weight = pc_resolve.x;
    bool _394 = any(bool2(uv.x < 0.0f.xx.x, uv.y < 0.0f.xx.y));
    bool _402;
    if (!_394)
    {
        _402 = any(bool2(uv.x > 1.0f.xx.x, uv.y > 1.0f.xx.y));
    }
    else
    {
        _402 = _394;
    }
    bool _409;
    if (!_402)
    {
        _409 = moved.w <= 0.0f;
    }
    else
    {
        _409 = _402;
    }
    if (_409)
    {
        weight = 0.0f;
    }
    float4 history = tex1.SampleLevel(_tex1_sampler, uv, 0.0f);
    float3 low = current.xyz;
    float3 high = current.xyz;
    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float3 c = tex0.SampleLevel(_tex0_sampler, v_texcoord + (float2(float(x), float(y)) * pc_metrics.xy), 0.0f).xyz;
            low = min(low, c);
            high = max(high, c);
        }
    }
    float4 _464 = history;
    float3 _468 = clamp(_464.xyz, low, high);
    history.x = _468.x;
    history.y = _468.y;
    history.z = _468.z;
    float4 param_2 = float4(lerp(current.xyz, history.xyz, weight.xxx), current.w);
    o_color = dithered(param_2);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_FragCoord = stage_input.gl_FragCoord;
    gl_FragCoord.w = 1.0 / gl_FragCoord.w;
    v_texcoord = stage_input.v_texcoord;
    v_pixcoord = stage_input.v_pixcoord;
    v_offset = stage_input.v_offset;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_color = o_color;
    return stage_output;
}
