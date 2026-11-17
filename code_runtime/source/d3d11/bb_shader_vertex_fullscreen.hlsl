static float4 gl_Position;
static int gl_VertexIndex;
static float2 _14;

struct SPIRV_Cross_Input
{
    uint gl_VertexIndex : SV_VertexID;
};

struct SPIRV_Cross_Output
{
    float2 _14 : TEXCOORD0;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    float _21 = float(gl_VertexIndex);
    float2 _27 = float2((_21 * (2.0f - _21)) * 2.0f, _21 * (_21 - 1.0f));
    _14 = _27;
    gl_Position = float4((_27 * 2.0f.xx) - 1.0f.xx, 0.0f, 1.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_VertexIndex = int(stage_input.gl_VertexIndex);
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = float4(gl_Position.x, -gl_Position.y, gl_Position.z, gl_Position.w);
    stage_output._14 = _14;
    return stage_output;
}
