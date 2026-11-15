Texture2D<float4> _9 : register(t0);
SamplerState __9_sampler : register(s0);
Texture2D<float4> _11 : register(t1);
SamplerState __11_sampler : register(s1);
Texture2D<float4> _12 : register(t2);
SamplerState __12_sampler : register(s2);
Texture2D<float4> _13 : register(t3);
SamplerState __13_sampler : register(s3);

static float4 gl_FragCoord;
static float4 _14;

struct SPIRV_Cross_Input
{
    float4 gl_FragCoord : SV_Position;
};

struct SPIRV_Cross_Output
{
    float4 _14 : SV_Target0;
};

void frag_main()
{
    int2 _27 = int2(int(gl_FragCoord.x), int(gl_FragCoord.y));
    float4 _31 = _9.Load(int3(_27, 0));
    _14 = float4(_31.xyz * (1.0f / max(_31.w, 9.9999999747524270787835121154785e-07f)), 1.0f - exp(0.0f - _11.Load(int3(_27, 0)).x));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_FragCoord = stage_input.gl_FragCoord;
    gl_FragCoord.w = 1.0 / gl_FragCoord.w;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output._14 = _14;
    return stage_output;
}
