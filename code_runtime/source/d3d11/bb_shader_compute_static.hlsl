struct _14
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

struct _15
{
    float4 _m0;
    int4 _m1;
    float4 _m2;
};

struct _16
{
    int _m0;
    int _m1;
    int _m2;
    int _m3;
    int _m4;
};

RWByteAddressBuffer _19 : register(u0);
ByteAddressBuffer _23 : register(t0);
ByteAddressBuffer _27 : register(t1);
RWByteAddressBuffer _31 : register(u1);
cbuffer _35_36 : register(b0)
{
    float4 _36_m0[6] : packoffset(c0);
    float4 _36_m1 : packoffset(c6);
    int4 _36_m2 : packoffset(c7);
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
    int _55 = (int3(gl_WorkGroupID).x * 64) + int3(gl_LocalInvocationID).x;
    int _57 = _36_m2.x + _55;
    float4 _60 = asfloat(_23.Load4(_55 * 192 + 0));
    float4 _67 = float4(_60.xyz, _60.w - _36_m1.x);
    _19.Store4(_57 * 192 + 0, asuint(_67));
    float4 _70 = asfloat(_23.Load4(_55 * 192 + 16));
    float4 _77 = float4(_70.xyz, _70.w - _36_m1.y);
    _19.Store4(_57 * 192 + 16, asuint(_77));
    float4 _80 = asfloat(_23.Load4(_55 * 192 + 32));
    float4 _87 = float4(_80.xyz, _80.w - _36_m1.z);
    _19.Store4(_57 * 192 + 32, asuint(_87));
    _19.Store4(_57 * 192 + 48, asuint(asfloat(_23.Load4(_55 * 192 + 48))));
    _19.Store4(_57 * 192 + 64, asuint(asfloat(_23.Load4(_55 * 192 + 64))));
    _19.Store4(_57 * 192 + 80, asuint(asfloat(_23.Load4(_55 * 192 + 80))));
    _19.Store4(_57 * 192 + 96, asuint(asfloat(_23.Load4(_55 * 192 + 96))));
    _19.Store4(_57 * 192 + 112, asuint(asfloat(_23.Load4(_55 * 192 + 112))));
    _19.Store4(_57 * 192 + 128, asuint(asfloat(_23.Load4(_55 * 192 + 128))));
    _19.Store4(_57 * 192 + 144, asuint(asfloat(_23.Load4(_55 * 192 + 144))));
    _19.Store4(_57 * 192 + 160, asuint(asfloat(_23.Load4(_55 * 192 + 160))));
    _19.Store4(_57 * 192 + 176, asuint(asfloat(_23.Load4(_55 * 192 + 176))));
    float4 _125 = asfloat(_27.Load4(_55 * 48 + 0));
    int4 _128 = int4(_27.Load4(_55 * 48 + 16));
    float4 _130 = asfloat(_27.Load4(_55 * 48 + 32));
    float4 _135 = float4(_125.xyz, 1.0f);
    float3 _139 = float3(dot(_67, _135), dot(_77, _135), dot(_87, _135));
    int _206 = _36_m2.y + _55;
    int _207 = int(((min(min(min(min(min(dot(_36_m0[0].xyz, _139) + _36_m0[0].w, dot(_36_m0[1].xyz, _139) + _36_m0[1].w), dot(_36_m0[2].xyz, _139) + _36_m0[2].w), dot(_36_m0[3].xyz, _139) + _36_m0[3].w), dot(_36_m0[4].xyz, _139) + _36_m0[4].w), dot(_36_m0[5].xyz, _139) + _36_m0[5].w) + ((((_125.w * _130.x) * 1.00100004673004150390625f) + 0.00999999977648258209228515625f) + (9.9999997473787516355514526367188e-06f * ((abs(_139.x) + abs(_139.y)) + abs(_139.z))))) >= 0.0f) && (_128.y > 0));
    _31.Store(_206 * 20 + 0, uint(_128.y));
    _31.Store(_206 * 20 + 4, uint(_207));
    _31.Store(_206 * 20 + 8, uint(_128.x));
    _31.Store(_206 * 20 + 12, uint(0));
    _31.Store(_206 * 20 + 16, uint(_57));
}

[numthreads(64, 1, 1)]
void main(SPIRV_Cross_Input stage_input)
{
    gl_WorkGroupID = stage_input.gl_WorkGroupID;
    gl_LocalInvocationID = stage_input.gl_LocalInvocationID;
    comp_main();
}
