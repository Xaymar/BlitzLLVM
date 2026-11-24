struct _19
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

cbuffer bb_constants : register(b1)
{
    float bb_constant_0;
    float bb_constant_1;
};
#define _817 bb_constant_0
#define _818 bb_constant_1

cbuffer _16_17 : register(b0)
{
    row_major float4x4 _17_m0 : packoffset(c0);
    float4 _17_m1 : packoffset(c4);
    float4 _17_m2[128] : packoffset(c11);
    float4 _17_m3[128] : packoffset(c139);
    float4 _17_m4 : packoffset(c5);
    float4 _17_m5 : packoffset(c6);
    float4 _17_m6 : packoffset(c7);
    float4 _17_m7[128] : packoffset(c267);
    float4 _17_m8 : packoffset(c8);
    float4 _17_m9 : packoffset(c9);
    float4 _17_m10 : packoffset(c10);
    float4 _17_m11 : packoffset(c395);
    float4 _17_m12 : packoffset(c396);
    float4 _17_m13[6] : packoffset(c397);
};

ByteAddressBuffer _22 : register(t0);

static float4 gl_Position;
static float gl_ClipDistance[6];
static int gl_InstanceIndex;
static float4 _26;
static float4 _28;
static float3 _29;
static int2 _32;
static float2 _34;
static float4 _36;
static float2 _38;
static float2 _39;
static float4 _41;
static float4 _42;
static float4 _43;
static float4 _44;
static float3 _45;
static float3 _47;
static float3 _48;
static float4 _49;
static float4 _50;
static float _51;
static float4 _53;
static float4 _54;

struct SPIRV_Cross_Input
{
    float3 _29 : TEXCOORD0;
    int2 _32 : TEXCOORD1;
    float2 _34 : TEXCOORD2;
    float4 _36 : TEXCOORD3;
    float2 _38 : TEXCOORD4;
    uint gl_InstanceIndex : BBINSTANCE;
};

struct SPIRV_Cross_Output
{
    float2 _39 : TEXCOORD0;
    float4 _42 : TEXCOORD1;
    float4 _43 : TEXCOORD2;
    nointerpolation float4 _44 : TEXCOORD3;
    float3 _45 : TEXCOORD4;
    nointerpolation float3 _47 : TEXCOORD5;
    nointerpolation float4 _26 : TEXCOORD6;
    float4 _41 : TEXCOORD7;
    nointerpolation float4 _28 : TEXCOORD8;
    float3 _48 : TEXCOORD9;
    nointerpolation float4 _49 : TEXCOORD10;
    nointerpolation float4 _50 : TEXCOORD11;
    nointerpolation float _51 : TEXCOORD12;
    nointerpolation float4 _53 : TEXCOORD13;
    float4 _54 : TEXCOORD14;
    float4 gl_Position : SV_Position;
    float4 gl_ClipDistance0 : SV_ClipDistance0;
    float2 gl_ClipDistance1 : SV_ClipDistance1;
};

void vert_main()
{
    _26 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 96));
    float _72 = float(_32.x) * 3.0518509447574615478515625e-05f;
    float _74 = float(_32.y) * 3.0518509447574615478515625e-05f;
    float _78 = (1.0f - abs(_72)) - abs(_74);
    float _80 = max(-_78, 0.0f);
    float3 _92 = float3(_72 - (sign(_72) * _80), _74 - (sign(_74) * _80), _78) * ((_32.x == (-32768)) ? 0.0f : 1.0f);
    float4 _120 = float4(_29, 1.0f);
    float3 _124 = float3(dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 0)), _120), dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 16)), _120), dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 32)), _120));
    float3 _131 = float3(dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 0)).xyz, _92), dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 16)).xyz, _92), dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 32)).xyz, _92));
    float3 _136 = _131 * (1.0f / max(length(_131), 9.9999999747524270787835121154785e-07f));
    float4 _143 = float4(_124, 1.0f);
    float4 _144 = mul(_143, _17_m0);
    gl_Position = _144;
    gl_ClipDistance[0] = dot(_17_m13[0], _143);
    gl_ClipDistance[1] = dot(_17_m13[1], _143);
    gl_ClipDistance[2] = dot(_17_m13[2], _143);
    gl_ClipDistance[3] = dot(_17_m13[3], _143);
    gl_ClipDistance[4] = dot(_17_m13[4], _143);
    gl_ClipDistance[5] = dot(_17_m13[5], _143);
    _28 = float4(asfloat(_22.Load4(gl_InstanceIndex * 192 + 160)).xy, asfloat(_22.Load4(gl_InstanceIndex * 192 + 160)).z + (asfloat(_22.Load4(gl_InstanceIndex * 192 + 160)).w * mul(float4(asfloat(_22.Load4(gl_InstanceIndex * 192 + 0)).w, asfloat(_22.Load4(gl_InstanceIndex * 192 + 16)).w, asfloat(_22.Load4(gl_InstanceIndex * 192 + 32)).w, 1.0f), _17_m0).w), asfloat(_22.Load4(gl_InstanceIndex * 192 + 160)).w);
    float3 _808;
    float3 _809;
    if ((!(asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).w > 0.5f)) || (asfloat(_22.Load4(gl_InstanceIndex * 192 + 96)).z > 0.5f))
    {
        float3 _211 = _17_m6.xyz - _124;
        float3 _216 = _211 * (1.0f / max(length(_211), 9.9999997473787516355514526367188e-05f));
        float _221 = max(asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).w * 128.0f, 0.001000000047497451305389404296875f);
        float _225 = floor(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).x * 0.00390625f);
        int _229 = int(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).x - (_225 * 256.0f));
        int _230 = int(_225);
        float _233 = floor(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).y * 0.00390625f);
        int _236 = int(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).y - (_233 * 256.0f));
        int _237 = int(_233);
        float _240 = floor(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).z * 0.00390625f);
        int _243 = int(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).z - (_240 * 256.0f));
        int _244 = int(_240);
        float _247 = floor(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).w * 0.00390625f);
        int _250 = int(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).w - (_247 * 256.0f));
        int _251 = int(_247);
        float3 _319;
        float3 _320;
        if (_229 < 127)
        {
            float3 _265 = _17_m2[_229].xyz - _124;
            float _266 = length(_265);
            float _272 = clamp(_17_m2[_229].w * 1000.0f, 0.0f, 1.0f);
            float3 _276 = (_17_m2[_229].xyz * (1.0f - _272)) + ((_265 * (1.0f / max(_266, 9.9999997473787516355514526367188e-05f))) * _272);
            float _278 = max(dot(_136, _276), 0.0f);
            float _302 = (1.0f + (((max(_17_m2[_229].w, 9.9999997473787516355514526367188e-05f) / max(_266, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _272)) * (1.0f + ((clamp(((0.0f - dot(_276, _17_m7[_229].xyz)) - _17_m7[_229].w) / max(_17_m3[_229].w - _17_m7[_229].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_229].w)));
            float3 _306 = _276 + _216;
            _319 = _17_m3[_229].xyz * (_278 * _302);
            _320 = 1.0f.xxx * ((pow(max(dot(_136, _306 * (1.0f / max(length(_306), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _221) * step(9.9999999747524270787835121154785e-07f, _278)) * _302);
        }
        else
        {
            _319 = 0.0f.xxx;
            _320 = 0.0f.xxx;
        }
        float3 _387;
        float3 _388;
        if (_230 < 127)
        {
            float3 _335 = _17_m2[_230].xyz - _124;
            float _336 = length(_335);
            float _341 = clamp(_17_m2[_230].w * 1000.0f, 0.0f, 1.0f);
            float3 _345 = (_17_m2[_230].xyz * (1.0f - _341)) + ((_335 * (1.0f / max(_336, 9.9999997473787516355514526367188e-05f))) * _341);
            float _347 = max(dot(_136, _345), 0.0f);
            float _370 = (1.0f + (((max(_17_m2[_230].w, 9.9999997473787516355514526367188e-05f) / max(_336, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _341)) * (1.0f + ((clamp(((0.0f - dot(_345, _17_m7[_230].xyz)) - _17_m7[_230].w) / max(_17_m3[_230].w - _17_m7[_230].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_230].w)));
            float3 _374 = _345 + _216;
            _387 = _17_m3[_230].xyz * (_347 * _370);
            _388 = 1.0f.xxx * ((pow(max(dot(_136, _374 * (1.0f / max(length(_374), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _221) * step(9.9999999747524270787835121154785e-07f, _347)) * _370);
        }
        else
        {
            _387 = 0.0f.xxx;
            _388 = 0.0f.xxx;
        }
        float3 _455;
        float3 _456;
        if (_236 < 127)
        {
            float3 _403 = _17_m2[_236].xyz - _124;
            float _404 = length(_403);
            float _409 = clamp(_17_m2[_236].w * 1000.0f, 0.0f, 1.0f);
            float3 _413 = (_17_m2[_236].xyz * (1.0f - _409)) + ((_403 * (1.0f / max(_404, 9.9999997473787516355514526367188e-05f))) * _409);
            float _415 = max(dot(_136, _413), 0.0f);
            float _438 = (1.0f + (((max(_17_m2[_236].w, 9.9999997473787516355514526367188e-05f) / max(_404, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _409)) * (1.0f + ((clamp(((0.0f - dot(_413, _17_m7[_236].xyz)) - _17_m7[_236].w) / max(_17_m3[_236].w - _17_m7[_236].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_236].w)));
            float3 _442 = _413 + _216;
            _455 = _17_m3[_236].xyz * (_415 * _438);
            _456 = 1.0f.xxx * ((pow(max(dot(_136, _442 * (1.0f / max(length(_442), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _221) * step(9.9999999747524270787835121154785e-07f, _415)) * _438);
        }
        else
        {
            _455 = 0.0f.xxx;
            _456 = 0.0f.xxx;
        }
        float3 _523;
        float3 _524;
        if (_237 < 127)
        {
            float3 _471 = _17_m2[_237].xyz - _124;
            float _472 = length(_471);
            float _477 = clamp(_17_m2[_237].w * 1000.0f, 0.0f, 1.0f);
            float3 _481 = (_17_m2[_237].xyz * (1.0f - _477)) + ((_471 * (1.0f / max(_472, 9.9999997473787516355514526367188e-05f))) * _477);
            float _483 = max(dot(_136, _481), 0.0f);
            float _506 = (1.0f + (((max(_17_m2[_237].w, 9.9999997473787516355514526367188e-05f) / max(_472, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _477)) * (1.0f + ((clamp(((0.0f - dot(_481, _17_m7[_237].xyz)) - _17_m7[_237].w) / max(_17_m3[_237].w - _17_m7[_237].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_237].w)));
            float3 _510 = _481 + _216;
            _523 = _17_m3[_237].xyz * (_483 * _506);
            _524 = 1.0f.xxx * ((pow(max(dot(_136, _510 * (1.0f / max(length(_510), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _221) * step(9.9999999747524270787835121154785e-07f, _483)) * _506);
        }
        else
        {
            _523 = 0.0f.xxx;
            _524 = 0.0f.xxx;
        }
        float3 _591;
        float3 _592;
        if (_243 < 127)
        {
            float3 _539 = _17_m2[_243].xyz - _124;
            float _540 = length(_539);
            float _545 = clamp(_17_m2[_243].w * 1000.0f, 0.0f, 1.0f);
            float3 _549 = (_17_m2[_243].xyz * (1.0f - _545)) + ((_539 * (1.0f / max(_540, 9.9999997473787516355514526367188e-05f))) * _545);
            float _551 = max(dot(_136, _549), 0.0f);
            float _574 = (1.0f + (((max(_17_m2[_243].w, 9.9999997473787516355514526367188e-05f) / max(_540, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _545)) * (1.0f + ((clamp(((0.0f - dot(_549, _17_m7[_243].xyz)) - _17_m7[_243].w) / max(_17_m3[_243].w - _17_m7[_243].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_243].w)));
            float3 _578 = _549 + _216;
            _591 = _17_m3[_243].xyz * (_551 * _574);
            _592 = 1.0f.xxx * ((pow(max(dot(_136, _578 * (1.0f / max(length(_578), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _221) * step(9.9999999747524270787835121154785e-07f, _551)) * _574);
        }
        else
        {
            _591 = 0.0f.xxx;
            _592 = 0.0f.xxx;
        }
        float3 _659;
        float3 _660;
        if (_244 < 127)
        {
            float3 _607 = _17_m2[_244].xyz - _124;
            float _608 = length(_607);
            float _613 = clamp(_17_m2[_244].w * 1000.0f, 0.0f, 1.0f);
            float3 _617 = (_17_m2[_244].xyz * (1.0f - _613)) + ((_607 * (1.0f / max(_608, 9.9999997473787516355514526367188e-05f))) * _613);
            float _619 = max(dot(_136, _617), 0.0f);
            float _642 = (1.0f + (((max(_17_m2[_244].w, 9.9999997473787516355514526367188e-05f) / max(_608, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _613)) * (1.0f + ((clamp(((0.0f - dot(_617, _17_m7[_244].xyz)) - _17_m7[_244].w) / max(_17_m3[_244].w - _17_m7[_244].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_244].w)));
            float3 _646 = _617 + _216;
            _659 = _17_m3[_244].xyz * (_619 * _642);
            _660 = 1.0f.xxx * ((pow(max(dot(_136, _646 * (1.0f / max(length(_646), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _221) * step(9.9999999747524270787835121154785e-07f, _619)) * _642);
        }
        else
        {
            _659 = 0.0f.xxx;
            _660 = 0.0f.xxx;
        }
        float3 _727;
        float3 _728;
        if (_250 < 127)
        {
            float3 _675 = _17_m2[_250].xyz - _124;
            float _676 = length(_675);
            float _681 = clamp(_17_m2[_250].w * 1000.0f, 0.0f, 1.0f);
            float3 _685 = (_17_m2[_250].xyz * (1.0f - _681)) + ((_675 * (1.0f / max(_676, 9.9999997473787516355514526367188e-05f))) * _681);
            float _687 = max(dot(_136, _685), 0.0f);
            float _710 = (1.0f + (((max(_17_m2[_250].w, 9.9999997473787516355514526367188e-05f) / max(_676, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _681)) * (1.0f + ((clamp(((0.0f - dot(_685, _17_m7[_250].xyz)) - _17_m7[_250].w) / max(_17_m3[_250].w - _17_m7[_250].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_250].w)));
            float3 _714 = _685 + _216;
            _727 = _17_m3[_250].xyz * (_687 * _710);
            _728 = 1.0f.xxx * ((pow(max(dot(_136, _714 * (1.0f / max(length(_714), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _221) * step(9.9999999747524270787835121154785e-07f, _687)) * _710);
        }
        else
        {
            _727 = 0.0f.xxx;
            _728 = 0.0f.xxx;
        }
        float3 _795;
        float3 _796;
        if (_251 < 127)
        {
            float3 _743 = _17_m2[_251].xyz - _124;
            float _744 = length(_743);
            float _749 = clamp(_17_m2[_251].w * 1000.0f, 0.0f, 1.0f);
            float3 _753 = (_17_m2[_251].xyz * (1.0f - _749)) + ((_743 * (1.0f / max(_744, 9.9999997473787516355514526367188e-05f))) * _749);
            float _755 = max(dot(_136, _753), 0.0f);
            float _778 = (1.0f + (((max(_17_m2[_251].w, 9.9999997473787516355514526367188e-05f) / max(_744, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _749)) * (1.0f + ((clamp(((0.0f - dot(_753, _17_m7[_251].xyz)) - _17_m7[_251].w) / max(_17_m3[_251].w - _17_m7[_251].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_251].w)));
            float3 _782 = _753 + _216;
            _795 = _17_m3[_251].xyz * (_755 * _778);
            _796 = 1.0f.xxx * ((pow(max(dot(_136, _782 * (1.0f / max(length(_782), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _221) * step(9.9999999747524270787835121154785e-07f, _755)) * _778);
        }
        else
        {
            _795 = 0.0f.xxx;
            _796 = 0.0f.xxx;
        }
        float3 _797 = (((((((_17_m1.xyz + _319) + _387) + _455) + _523) + _591) + _659) + _727) + _795;
        _808 = _797 + ((1.0f.xxx - _797) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).x);
        _809 = ((((((((0.0f.xxx + _320) + _388) + _456) + _524) + _592) + _660) + _728) + _796) * (clamp(asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).w, 0.0f, 1.0f) * (1.0f - asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).x));
    }
    else
    {
        _808 = 1.0f.xxx;
        _809 = 0.0f.xxx;
    }
    float _828 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 48)).w * (1.0f + ((_36.w - 1.0f) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).z));
    float4 _836 = float4(clamp((asfloat(_22.Load4(gl_InstanceIndex * 192 + 48)).xyz + ((_36.xyz - asfloat(_22.Load4(gl_InstanceIndex * 192 + 48)).xyz) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).y)) * _808, _817.xxx, _818.xxx), _828 + ((_36.w - _828) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).y));
    _42 = _836;
    _44 = _836;
    _45 = _809;
    _47 = _809;
    _48 = _136;
    _49 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 64));
    _50 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 144));
    _51 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).w;
    float2 _846 = _34 + ((_38 - _34) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).x);
    float _849 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).z + 1.0f;
    float _850 = _846.x;
    float _851 = _846.y;
    float2 _860 = (float2((_849 * _850) + (asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).y * _851), (_849 * _851) - (asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).y * _850)) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 80)).xy) + float2(asfloat(_22.Load4(gl_InstanceIndex * 192 + 80)).zw);
    float3 _873 = float3(dot(_136, _17_m8.xyz), dot(_136, _17_m9.xyz), dot(_136, _17_m10.xyz));
    float3 _891 = _124 - _17_m6.xyz;
    float3 _895 = _891 * (1.0f / max(length(_891), 9.9999997473787516355514526367188e-05f));
    float3 _900 = _895 - (_136 * (2.0f * dot(_136, _895)));
    float3 _905 = _900 + ((_136 - _900) * step(1.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).y));
    float3 _910 = _905 + ((_891 - _905) * step(2.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).y));
    _39 = _860 + ((float2((0.5f * _873.x) + 0.5f, 0.5f - (0.5f * _873.y)) - _860) * (step(0.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).x) * (1.0f - step(1.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).x))));
    _41 = float4(_910 + ((float3(dot(_910, _17_m8.xyz), dot(_910, _17_m9.xyz), dot(_910, _17_m10.xyz)) - _910) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).z), asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).w * step(1.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).x));
    _54 = float4(_34.x, _34.y, _38.x, _38.y);
    _53 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 176));
    _43 = float4(_144.w, _124);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_InstanceIndex = int(stage_input.gl_InstanceIndex);
    _29 = stage_input._29;
    _32 = stage_input._32;
    _34 = stage_input._34;
    _36 = stage_input._36;
    _38 = stage_input._38;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = float4(gl_Position.x, -gl_Position.y, gl_Position.z, gl_Position.w);
    stage_output.gl_ClipDistance0.x = gl_ClipDistance[0];
    stage_output.gl_ClipDistance0.y = gl_ClipDistance[1];
    stage_output.gl_ClipDistance0.z = gl_ClipDistance[2];
    stage_output.gl_ClipDistance0.w = gl_ClipDistance[3];
    stage_output.gl_ClipDistance1.x = gl_ClipDistance[4];
    stage_output.gl_ClipDistance1.y = gl_ClipDistance[5];
    stage_output._26 = _26;
    stage_output._28 = _28;
    stage_output._39 = _39;
    stage_output._41 = _41;
    stage_output._42 = _42;
    stage_output._43 = _43;
    stage_output._44 = _44;
    stage_output._45 = _45;
    stage_output._47 = _47;
    stage_output._48 = _48;
    stage_output._49 = _49;
    stage_output._50 = _50;
    stage_output._51 = _51;
    stage_output._53 = _53;
    stage_output._54 = _54;
    return stage_output;
}
