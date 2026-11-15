Texture2D<float4> _8 : register(t0);
SamplerState __8_sampler : register(s0);

static float4 gl_FragCoord;
static float4 _10;

struct SPIRV_Cross_Input
{
    float4 gl_FragCoord : SV_Position;
};

struct SPIRV_Cross_Output
{
    float4 _10 : SV_Target0;
};

void frag_main()
{
    _10 = _8.Load(int3(int2(int(gl_FragCoord.x), int(gl_FragCoord.y)), 0));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_FragCoord = stage_input.gl_FragCoord;
    gl_FragCoord.w = 1.0 / gl_FragCoord.w;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output._10 = _10;
    return stage_output;
}
