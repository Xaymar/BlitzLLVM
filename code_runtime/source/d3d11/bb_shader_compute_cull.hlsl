struct _13
{
    float4 _m0;
    float4 _m1;
    float4 _m2;
    float4 _m3;
    float4 _m4;
    float4 _m5;
    float4 _m6;
    float4 _m7;
    float4 _m8;
    float4 _m9;
    float4 _m10;
    float4 _m11;
};

struct _18
{
    float4 _m0;
    int4 _m1;
    float4 _m2;
};

struct _19
{
    int4 _m0;
    float4 _m1;
};

struct _20
{
    int _m0;
    int _m1;
    int _m2;
    int _m3;
    int _m4;
};

ByteAddressBuffer _16 : register(t0);
ByteAddressBuffer _23 : register(t1);
ByteAddressBuffer _27 : register(t2);
RWByteAddressBuffer _31 : register(u0);
cbuffer _35_36 : register(b0)
{
    float4 _36_m0[6] : packoffset(c0);
    int4 _36_m1 : packoffset(c6);
};


static uint3 gl_WorkGroupID;
static uint3 gl_LocalInvocationID;
struct SPIRV_Cross_Input
{
    uint3 gl_WorkGroupID : SV_GroupID;
    uint3 gl_LocalInvocationID : SV_GroupThreadID;
};

void comp_main()
{
    int _49 = _36_m1.x + int3(gl_WorkGroupID).x;
    int4 _54 = int4(_27.Load4(_49 * 32 + 0));
    float4 _57 = asfloat(_27.Load4(_49 * 32 + 16));
    bool _64 = int3(gl_LocalInvocationID).x < _54.z;
    int _66 = _54.y + (_64 ? int3(gl_LocalInvocationID).x : 0);
    float4 _68 = asfloat(_23.Load4(_66 * 48 + 0));
    int4 _70 = int4(_23.Load4(_66 * 48 + 16));
    float4 _73 = asfloat(_23.Load4(_66 * 48 + 32));
    float4 _78 = float4(_68.xyz, 1.0f);
    float4 _80 = asfloat(_16.Load4(_54.x * 192 + 0));
    float4 _83 = asfloat(_16.Load4(_54.x * 192 + 16));
    float4 _86 = asfloat(_16.Load4(_54.x * 192 + 32));
    float3 _88 = float3(dot(_80, _78), dot(_83, _78), dot(_86, _78));
    float _105 = (((_68.w * _57.x) * 1.00100004673004150390625f) + 0.00999999977648258209228515625f) + (9.9999997473787516355514526367188e-06f * ((abs(_88.x) + abs(_88.y)) + abs(_88.z)));
    float4 _157 = float4(_73.xyz, 0.0f);
    float4 _159 = asfloat(_16.Load4(_54.x * 192 + 0));
    float4 _162 = asfloat(_16.Load4(_54.x * 192 + 16));
    float4 _165 = asfloat(_16.Load4(_54.x * 192 + 32));
    float3 _167 = float3(dot(_159, _157), dot(_162, _157), dot(_165, _157));
    int _182 = _64 ? (_54.w + int3(gl_LocalInvocationID).x) : 0;
    _31.Store(_182 * 20 + 0, uint(_70.y));
    _31.Store(_182 * 20 + 4, uint(int(((min(min(min(min(min(dot(_36_m0[0].xyz, _88) + _36_m0[0].w, dot(_36_m0[1].xyz, _88) + _36_m0[1].w), dot(_36_m0[2].xyz, _88) + _36_m0[2].w), dot(_36_m0[3].xyz, _88) + _36_m0[3].w), dot(_36_m0[4].xyz, _88) + _36_m0[4].w), dot(_36_m0[5].xyz, _88) + _36_m0[5].w) + _105) >= 0.0f) && (!((0.5f < _57.y) && (dot(_88, _167) >= (((_73.w * length(_88)) + _105) * length(_167))))))));
    _31.Store(_182 * 20 + 8, uint(_70.x));
    _31.Store(_182 * 20 + 12, uint(0));
    _31.Store(_182 * 20 + 16, uint(_54.x));
}

[numthreads(64, 1, 1)]
void main(SPIRV_Cross_Input stage_input)
{
    gl_WorkGroupID = stage_input.gl_WorkGroupID;
    gl_LocalInvocationID = stage_input.gl_LocalInvocationID;
    comp_main();
}
