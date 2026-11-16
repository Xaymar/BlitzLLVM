cbuffer Constants : register(b0)
{
    float4 pc_metrics : packoffset(c0);
    float4 pc_subsample : packoffset(c1);
    row_major float4x4 pc_reproject : packoffset(c2);
    float4 pc_resolve : packoffset(c6);
    float4 pc_depthmap : packoffset(c7);
};


static float4 gl_Position;
static int gl_VertexIndex;
static float2 v_texcoord;
static float2 v_pixcoord;
static float4 v_offset[3];

struct SPIRV_Cross_Input
{
    uint gl_VertexIndex : SV_VertexID;
};

struct SPIRV_Cross_Output
{
    float2 v_texcoord : TEXCOORD0;
    float2 v_pixcoord : TEXCOORD1;
    float4 v_offset[3] : TEXCOORD2;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    float2 corner = float2(float((gl_VertexIndex << 1) & 2), float(gl_VertexIndex & 2));
    gl_Position = float4((corner * 2.0f) - 1.0f.xx, 0.0f, 1.0f);
    v_texcoord = corner;
    v_pixcoord = 0.0f.xx;
    v_offset[2] = 0.0f.xxxx;
    v_offset[1] = 0.0f.xxxx;
    v_offset[0] = 0.0f.xxxx;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_VertexIndex = int(stage_input.gl_VertexIndex);
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = float4(gl_Position.x, -gl_Position.y, gl_Position.z, gl_Position.w);
    stage_output.v_texcoord = v_texcoord;
    stage_output.v_pixcoord = v_pixcoord;
    stage_output.v_offset = v_offset;
    return stage_output;
}
