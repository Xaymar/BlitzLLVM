cbuffer _8_31 : register(b0)
{
    float2 _31_m0 : packoffset(c0);
};


static float4 gl_Position;
static float2 _25;
static float2 _26;
static float4 _27;
static float2 _28;
static float4 _29;

struct SPIRV_Cross_Input
{
    float2 _25 : TEXCOORD0;
    float2 _26 : TEXCOORD1;
    float4 _27 : TEXCOORD2;
};

struct SPIRV_Cross_Output
{
    float2 _28 : TEXCOORD0;
    float4 _29 : TEXCOORD1;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    gl_Position = float4(((_25 * _31_m0) * 2.0f.xx) - 1.0f.xx, 0.0f, 1.0f);
    _28 = _26;
    _29 = _27;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    _25 = stage_input._25;
    _26 = stage_input._26;
    _27 = stage_input._27;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = float4(gl_Position.x, -gl_Position.y, gl_Position.z, gl_Position.w);
    stage_output._28 = _28;
    stage_output._29 = _29;
    return stage_output;
}
