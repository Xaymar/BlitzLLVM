cbuffer _11_12 : register(b0)
{
    float _12_m0 : packoffset(c0);
    float _12_m1 : packoffset(c0.y);
    float _12_m2 : packoffset(c0.z);
};

Texture2D<float4> _14 : register(t0);
SamplerState __14_sampler : register(s0);

static float2 _16;
static float4 _18;

struct SPIRV_Cross_Input
{
    float2 _16 : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 _18 : SV_Target0;
};

void frag_main()
{
    float3 _28 = max(_14.Sample(__14_sampler, _16).xyz, 0.0f.xxx);
    float3 _30 = _28 * 0.077399380505084991455078125f;
    float3 _44 = _30 + ((pow((_28 + 0.054999999701976776123046875f.xxx) * 0.94786727428436279296875f, 2.400000095367431640625f.xxx) - _30) * step(0.040449999272823333740234375f.xxx, _28));
    float _49 = dot(_44, float3(0.2125999927520751953125f, 0.715200006961822509765625f, 0.072200000286102294921875f));
    _18 = float4(min(_44 * ((1.0f + (_12_m1 * (_49 * _49))) * _12_m0), _12_m2.xxx), 1.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    _16 = stage_input._16;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output._18 = _18;
    return stage_output;
}
