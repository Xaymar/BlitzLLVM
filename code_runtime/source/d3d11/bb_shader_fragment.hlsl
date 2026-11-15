cbuffer _12_13 : register(b0)
{
    float4 _13_m0 : packoffset(c1);
};

Texture2D<float4> _15 : register(t0);
SamplerState __15_sampler : register(s0);

static float2 _17;
static float4 _19;
static float4 _21;

struct SPIRV_Cross_Input
{
    float2 _17 : TEXCOORD0;
    float4 _19 : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 _21 : SV_Target0;
};

void frag_main()
{
    float4 _29 = _15.Sample(__15_sampler, _17);
    float3 _38 = abs(_29.xyz - _13_m0.xyz);
    _21 = _19 * float4(_29.xyz, _29.w * (1.0f - (step(max(max(_38.x, _38.y), _38.z), 0.00200000009499490261077880859375f) * _13_m0.w)));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    _17 = stage_input._17;
    _19 = stage_input._19;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output._21 = _21;
    return stage_output;
}
