cbuffer _11_12 : register(b0)
{
    float _12_m0 : packoffset(c0);
    float _12_m1 : packoffset(c0.y);
    float _12_m2 : packoffset(c0.z);
    float _12_m3 : packoffset(c0.w);
};

Texture2D<float4> _14 : register(t0);
SamplerState __14_sampler : register(s0);

static float4 gl_FragCoord;
static float2 _16;
static float4 _20;

struct SPIRV_Cross_Input
{
    float2 _16 : TEXCOORD0;
    float4 gl_FragCoord : SV_Position;
};

struct SPIRV_Cross_Output
{
    float4 _20 : SV_Target0;
};

void frag_main()
{
    float3 _30 = max(_14.Sample(__14_sampler, _16).xyz, 0.0f.xxx);
    float3 _32 = _30 * 0.077399380505084991455078125f;
    float3 _57 = min((_32 + ((pow((_30 + 0.054999999701976776123046875f.xxx) * 0.94786727428436279296875f, 2.400000095367431640625f.xxx) - _32) * step(0.040449999272823333740234375f.xxx, _30))) * _12_m0, _12_m1.xxx);
    float3 _67 = clamp(_57 * 0.008000000379979610443115234375f, 0.0f.xxx, 1.0f.xxx);
    float3 _70 = pow(_67, 0.1593017578125f.xxx);
    float3 _111 = pow(clamp(pow((0.8359375f.xxx + (_70 * 18.8515625f)) / (1.0f.xxx + (_70 * 18.6875f)), 78.84375f.xxx) + ((1.0f.xxx * ((frac(frac(((floor(gl_FragCoord.x) + _12_m3) * 0.067110560834407806396484375f) + ((floor(gl_FragCoord.y) + _12_m3) * 0.005837149918079376220703125f)) * 52.98291778564453125f) - 0.5f) * _12_m2)) * step(1.0000000116860974230803549289703e-07f.xxx, _67)), 0.0f.xxx, 1.0f.xxx), 0.0126833133399486541748046875f.xxx);
    _20 = float4(_57 + (((pow(max(_111 - 0.8359375f.xxx, 0.0f.xxx) / (18.8515625f.xxx - (_111 * 18.6875f)), 6.277394771575927734375f.xxx) * 125.0f) - _57) * step(9.999999717180685365747194737196e-10f, _12_m2)), 1.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_FragCoord = stage_input.gl_FragCoord;
    gl_FragCoord.w = 1.0 / gl_FragCoord.w;
    _16 = stage_input._16;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output._20 = _20;
    return stage_output;
}
