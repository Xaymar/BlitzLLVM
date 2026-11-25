struct _17
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
#define _790 bb_constant_0
#define _791 bb_constant_1

cbuffer _14_15 : register(b0)
{
    row_major float4x4 _15_m0 : packoffset(c0);
    float4 _15_m1 : packoffset(c4);
    float4 _15_m2[128] : packoffset(c11);
    float4 _15_m3[128] : packoffset(c139);
    float4 _15_m4 : packoffset(c5);
    float4 _15_m5 : packoffset(c6);
    float4 _15_m6 : packoffset(c7);
    float4 _15_m7[128] : packoffset(c267);
    float4 _15_m8 : packoffset(c8);
    float4 _15_m9 : packoffset(c9);
    float4 _15_m10 : packoffset(c10);
    float4 _15_m11 : packoffset(c395);
    float4 _15_m12 : packoffset(c396);
};

ByteAddressBuffer _20 : register(t0);

static float4 gl_Position;
static int gl_InstanceIndex;
static float4 _24;
static float4 _26;
static float3 _27;
static int2 _30;
static float2 _32;
static float4 _34;
static float2 _36;
static float2 _37;
static float4 _39;
static float4 _40;
static float4 _41;
static float4 _42;
static float3 _43;
static float3 _45;
static float3 _46;
static float4 _47;
static float4 _48;
static float _49;
static float4 _51;
static float4 _52;

struct SPIRV_Cross_Input
{
    float3 _27 : TEXCOORD0;
    int2 _30 : TEXCOORD1;
    float2 _32 : TEXCOORD2;
    float4 _34 : TEXCOORD3;
    float2 _36 : TEXCOORD4;
    uint gl_InstanceIndex : BBINSTANCE;
};

struct SPIRV_Cross_Output
{
    float2 _37 : TEXCOORD0;
    float4 _40 : TEXCOORD1;
    float4 _41 : TEXCOORD2;
    nointerpolation float4 _42 : TEXCOORD3;
    float3 _43 : TEXCOORD4;
    nointerpolation float3 _45 : TEXCOORD5;
    nointerpolation float4 _24 : TEXCOORD6;
    float4 _39 : TEXCOORD7;
    nointerpolation float4 _26 : TEXCOORD8;
    float3 _46 : TEXCOORD9;
    nointerpolation float4 _47 : TEXCOORD10;
    nointerpolation float4 _48 : TEXCOORD11;
    nointerpolation float _49 : TEXCOORD12;
    nointerpolation float4 _51 : TEXCOORD13;
    float4 _52 : TEXCOORD14;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    _24 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 96));
    float _70 = float(_30.x) * 3.0518509447574615478515625e-05f;
    float _72 = float(_30.y) * 3.0518509447574615478515625e-05f;
    float _76 = (1.0f - abs(_70)) - abs(_72);
    float _78 = max(-_76, 0.0f);
    float3 _90 = float3(_70 - (sign(_70) * _78), _72 - (sign(_72) * _78), _76) * ((_30.x == (-32768)) ? 0.0f : 1.0f);
    float4 _118 = float4(_27, 1.0f);
    float3 _122 = float3(dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 0)), _118), dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 16)), _118), dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 32)), _118));
    float3 _129 = float3(dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 0)).xyz, _90), dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 16)).xyz, _90), dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 32)).xyz, _90));
    float3 _134 = _129 * (1.0f / max(length(_129), 9.9999999747524270787835121154785e-07f));
    float4 _142 = mul(float4(_122, 1.0f), _15_m0);
    gl_Position = _142;
    _26 = float4(asfloat(_20.Load4(gl_InstanceIndex * 192 + 160)).xy, asfloat(_20.Load4(gl_InstanceIndex * 192 + 160)).z + (asfloat(_20.Load4(gl_InstanceIndex * 192 + 160)).w * mul(float4(asfloat(_20.Load4(gl_InstanceIndex * 192 + 0)).w, asfloat(_20.Load4(gl_InstanceIndex * 192 + 16)).w, asfloat(_20.Load4(gl_InstanceIndex * 192 + 32)).w, 1.0f), _15_m0).w), asfloat(_20.Load4(gl_InstanceIndex * 192 + 160)).w);
    float3 _781;
    float3 _782;
    if ((!(asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).w > 0.5f)) || (asfloat(_20.Load4(gl_InstanceIndex * 192 + 96)).z > 0.5f))
    {
        float3 _184 = _15_m6.xyz - _122;
        float3 _189 = _184 * (1.0f / max(length(_184), 9.9999997473787516355514526367188e-05f));
        float _194 = max(asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).w * 128.0f, 0.001000000047497451305389404296875f);
        float _198 = floor(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).x * 0.00390625f);
        int _202 = int(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).x - (_198 * 256.0f));
        int _203 = int(_198);
        float _206 = floor(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).y * 0.00390625f);
        int _209 = int(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).y - (_206 * 256.0f));
        int _210 = int(_206);
        float _213 = floor(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).z * 0.00390625f);
        int _216 = int(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).z - (_213 * 256.0f));
        int _217 = int(_213);
        float _220 = floor(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).w * 0.00390625f);
        int _223 = int(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).w - (_220 * 256.0f));
        int _224 = int(_220);
        float3 _292;
        float3 _293;
        if (_202 < 127)
        {
            float3 _238 = _15_m2[_202].xyz - _122;
            float _239 = length(_238);
            float _245 = clamp(_15_m2[_202].w * 1000.0f, 0.0f, 1.0f);
            float3 _249 = (_15_m2[_202].xyz * (1.0f - _245)) + ((_238 * (1.0f / max(_239, 9.9999997473787516355514526367188e-05f))) * _245);
            float _251 = max(dot(_134, _249), 0.0f);
            float _275 = (1.0f + (((max(_15_m2[_202].w, 9.9999997473787516355514526367188e-05f) / max(_239, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _245)) * (1.0f + ((clamp(((0.0f - dot(_249, _15_m7[_202].xyz)) - _15_m7[_202].w) / max(_15_m3[_202].w - _15_m7[_202].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_202].w)));
            float3 _279 = _249 + _189;
            _292 = _15_m3[_202].xyz * (_251 * _275);
            _293 = 1.0f.xxx * ((pow(max(dot(_134, _279 * (1.0f / max(length(_279), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _194) * step(9.9999999747524270787835121154785e-07f, _251)) * _275);
        }
        else
        {
            _292 = 0.0f.xxx;
            _293 = 0.0f.xxx;
        }
        float3 _360;
        float3 _361;
        if (_203 < 127)
        {
            float3 _308 = _15_m2[_203].xyz - _122;
            float _309 = length(_308);
            float _314 = clamp(_15_m2[_203].w * 1000.0f, 0.0f, 1.0f);
            float3 _318 = (_15_m2[_203].xyz * (1.0f - _314)) + ((_308 * (1.0f / max(_309, 9.9999997473787516355514526367188e-05f))) * _314);
            float _320 = max(dot(_134, _318), 0.0f);
            float _343 = (1.0f + (((max(_15_m2[_203].w, 9.9999997473787516355514526367188e-05f) / max(_309, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _314)) * (1.0f + ((clamp(((0.0f - dot(_318, _15_m7[_203].xyz)) - _15_m7[_203].w) / max(_15_m3[_203].w - _15_m7[_203].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_203].w)));
            float3 _347 = _318 + _189;
            _360 = _15_m3[_203].xyz * (_320 * _343);
            _361 = 1.0f.xxx * ((pow(max(dot(_134, _347 * (1.0f / max(length(_347), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _194) * step(9.9999999747524270787835121154785e-07f, _320)) * _343);
        }
        else
        {
            _360 = 0.0f.xxx;
            _361 = 0.0f.xxx;
        }
        float3 _428;
        float3 _429;
        if (_209 < 127)
        {
            float3 _376 = _15_m2[_209].xyz - _122;
            float _377 = length(_376);
            float _382 = clamp(_15_m2[_209].w * 1000.0f, 0.0f, 1.0f);
            float3 _386 = (_15_m2[_209].xyz * (1.0f - _382)) + ((_376 * (1.0f / max(_377, 9.9999997473787516355514526367188e-05f))) * _382);
            float _388 = max(dot(_134, _386), 0.0f);
            float _411 = (1.0f + (((max(_15_m2[_209].w, 9.9999997473787516355514526367188e-05f) / max(_377, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _382)) * (1.0f + ((clamp(((0.0f - dot(_386, _15_m7[_209].xyz)) - _15_m7[_209].w) / max(_15_m3[_209].w - _15_m7[_209].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_209].w)));
            float3 _415 = _386 + _189;
            _428 = _15_m3[_209].xyz * (_388 * _411);
            _429 = 1.0f.xxx * ((pow(max(dot(_134, _415 * (1.0f / max(length(_415), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _194) * step(9.9999999747524270787835121154785e-07f, _388)) * _411);
        }
        else
        {
            _428 = 0.0f.xxx;
            _429 = 0.0f.xxx;
        }
        float3 _496;
        float3 _497;
        if (_210 < 127)
        {
            float3 _444 = _15_m2[_210].xyz - _122;
            float _445 = length(_444);
            float _450 = clamp(_15_m2[_210].w * 1000.0f, 0.0f, 1.0f);
            float3 _454 = (_15_m2[_210].xyz * (1.0f - _450)) + ((_444 * (1.0f / max(_445, 9.9999997473787516355514526367188e-05f))) * _450);
            float _456 = max(dot(_134, _454), 0.0f);
            float _479 = (1.0f + (((max(_15_m2[_210].w, 9.9999997473787516355514526367188e-05f) / max(_445, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _450)) * (1.0f + ((clamp(((0.0f - dot(_454, _15_m7[_210].xyz)) - _15_m7[_210].w) / max(_15_m3[_210].w - _15_m7[_210].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_210].w)));
            float3 _483 = _454 + _189;
            _496 = _15_m3[_210].xyz * (_456 * _479);
            _497 = 1.0f.xxx * ((pow(max(dot(_134, _483 * (1.0f / max(length(_483), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _194) * step(9.9999999747524270787835121154785e-07f, _456)) * _479);
        }
        else
        {
            _496 = 0.0f.xxx;
            _497 = 0.0f.xxx;
        }
        float3 _564;
        float3 _565;
        if (_216 < 127)
        {
            float3 _512 = _15_m2[_216].xyz - _122;
            float _513 = length(_512);
            float _518 = clamp(_15_m2[_216].w * 1000.0f, 0.0f, 1.0f);
            float3 _522 = (_15_m2[_216].xyz * (1.0f - _518)) + ((_512 * (1.0f / max(_513, 9.9999997473787516355514526367188e-05f))) * _518);
            float _524 = max(dot(_134, _522), 0.0f);
            float _547 = (1.0f + (((max(_15_m2[_216].w, 9.9999997473787516355514526367188e-05f) / max(_513, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _518)) * (1.0f + ((clamp(((0.0f - dot(_522, _15_m7[_216].xyz)) - _15_m7[_216].w) / max(_15_m3[_216].w - _15_m7[_216].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_216].w)));
            float3 _551 = _522 + _189;
            _564 = _15_m3[_216].xyz * (_524 * _547);
            _565 = 1.0f.xxx * ((pow(max(dot(_134, _551 * (1.0f / max(length(_551), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _194) * step(9.9999999747524270787835121154785e-07f, _524)) * _547);
        }
        else
        {
            _564 = 0.0f.xxx;
            _565 = 0.0f.xxx;
        }
        float3 _632;
        float3 _633;
        if (_217 < 127)
        {
            float3 _580 = _15_m2[_217].xyz - _122;
            float _581 = length(_580);
            float _586 = clamp(_15_m2[_217].w * 1000.0f, 0.0f, 1.0f);
            float3 _590 = (_15_m2[_217].xyz * (1.0f - _586)) + ((_580 * (1.0f / max(_581, 9.9999997473787516355514526367188e-05f))) * _586);
            float _592 = max(dot(_134, _590), 0.0f);
            float _615 = (1.0f + (((max(_15_m2[_217].w, 9.9999997473787516355514526367188e-05f) / max(_581, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _586)) * (1.0f + ((clamp(((0.0f - dot(_590, _15_m7[_217].xyz)) - _15_m7[_217].w) / max(_15_m3[_217].w - _15_m7[_217].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_217].w)));
            float3 _619 = _590 + _189;
            _632 = _15_m3[_217].xyz * (_592 * _615);
            _633 = 1.0f.xxx * ((pow(max(dot(_134, _619 * (1.0f / max(length(_619), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _194) * step(9.9999999747524270787835121154785e-07f, _592)) * _615);
        }
        else
        {
            _632 = 0.0f.xxx;
            _633 = 0.0f.xxx;
        }
        float3 _700;
        float3 _701;
        if (_223 < 127)
        {
            float3 _648 = _15_m2[_223].xyz - _122;
            float _649 = length(_648);
            float _654 = clamp(_15_m2[_223].w * 1000.0f, 0.0f, 1.0f);
            float3 _658 = (_15_m2[_223].xyz * (1.0f - _654)) + ((_648 * (1.0f / max(_649, 9.9999997473787516355514526367188e-05f))) * _654);
            float _660 = max(dot(_134, _658), 0.0f);
            float _683 = (1.0f + (((max(_15_m2[_223].w, 9.9999997473787516355514526367188e-05f) / max(_649, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _654)) * (1.0f + ((clamp(((0.0f - dot(_658, _15_m7[_223].xyz)) - _15_m7[_223].w) / max(_15_m3[_223].w - _15_m7[_223].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_223].w)));
            float3 _687 = _658 + _189;
            _700 = _15_m3[_223].xyz * (_660 * _683);
            _701 = 1.0f.xxx * ((pow(max(dot(_134, _687 * (1.0f / max(length(_687), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _194) * step(9.9999999747524270787835121154785e-07f, _660)) * _683);
        }
        else
        {
            _700 = 0.0f.xxx;
            _701 = 0.0f.xxx;
        }
        float3 _768;
        float3 _769;
        if (_224 < 127)
        {
            float3 _716 = _15_m2[_224].xyz - _122;
            float _717 = length(_716);
            float _722 = clamp(_15_m2[_224].w * 1000.0f, 0.0f, 1.0f);
            float3 _726 = (_15_m2[_224].xyz * (1.0f - _722)) + ((_716 * (1.0f / max(_717, 9.9999997473787516355514526367188e-05f))) * _722);
            float _728 = max(dot(_134, _726), 0.0f);
            float _751 = (1.0f + (((max(_15_m2[_224].w, 9.9999997473787516355514526367188e-05f) / max(_717, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _722)) * (1.0f + ((clamp(((0.0f - dot(_726, _15_m7[_224].xyz)) - _15_m7[_224].w) / max(_15_m3[_224].w - _15_m7[_224].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_224].w)));
            float3 _755 = _726 + _189;
            _768 = _15_m3[_224].xyz * (_728 * _751);
            _769 = 1.0f.xxx * ((pow(max(dot(_134, _755 * (1.0f / max(length(_755), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _194) * step(9.9999999747524270787835121154785e-07f, _728)) * _751);
        }
        else
        {
            _768 = 0.0f.xxx;
            _769 = 0.0f.xxx;
        }
        float3 _770 = (((((((_15_m1.xyz + _292) + _360) + _428) + _496) + _564) + _632) + _700) + _768;
        _781 = _770 + ((1.0f.xxx - _770) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).x);
        _782 = ((((((((0.0f.xxx + _293) + _361) + _429) + _497) + _565) + _633) + _701) + _769) * (clamp(asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).w, 0.0f, 1.0f) * (1.0f - asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).x));
    }
    else
    {
        _781 = 1.0f.xxx;
        _782 = 0.0f.xxx;
    }
    float _801 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 48)).w * (1.0f + ((_34.w - 1.0f) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).z));
    float4 _809 = float4(clamp((asfloat(_20.Load4(gl_InstanceIndex * 192 + 48)).xyz + ((_34.xyz - asfloat(_20.Load4(gl_InstanceIndex * 192 + 48)).xyz) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).y)) * _781, _790.xxx, _791.xxx), _801 + ((_34.w - _801) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).y));
    _40 = _809;
    _42 = _809;
    _43 = _782;
    _45 = _782;
    _46 = _134;
    _47 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 64));
    _48 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 144));
    _49 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).w;
    float2 _819 = _32 + ((_36 - _32) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).x);
    float _822 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).z + 1.0f;
    float _823 = _819.x;
    float _824 = _819.y;
    float2 _833 = (float2((_822 * _823) + (asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).y * _824), (_822 * _824) - (asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).y * _823)) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 80)).xy) + float2(asfloat(_20.Load4(gl_InstanceIndex * 192 + 80)).zw);
    float3 _846 = float3(dot(_134, _15_m8.xyz), dot(_134, _15_m9.xyz), dot(_134, _15_m10.xyz));
    float3 _864 = _122 - _15_m6.xyz;
    float3 _868 = _864 * (1.0f / max(length(_864), 9.9999997473787516355514526367188e-05f));
    float3 _873 = _868 - (_134 * (2.0f * dot(_134, _868)));
    float3 _878 = _873 + ((_134 - _873) * step(1.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).y));
    float3 _883 = _878 + ((_864 - _878) * step(2.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).y));
    _37 = _833 + ((float2((0.5f * _846.x) + 0.5f, 0.5f - (0.5f * _846.y)) - _833) * (step(0.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).x) * (1.0f - step(1.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).x))));
    _39 = float4(_883 + ((float3(dot(_883, _15_m8.xyz), dot(_883, _15_m9.xyz), dot(_883, _15_m10.xyz)) - _883) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).z), asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).w * step(1.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).x));
    _52 = float4(_32.x, _32.y, _36.x, _36.y);
    _51 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 176));
    _41 = float4(_142.w, _122);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_InstanceIndex = int(stage_input.gl_InstanceIndex);
    _27 = stage_input._27;
    _30 = stage_input._30;
    _32 = stage_input._32;
    _34 = stage_input._34;
    _36 = stage_input._36;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = float4(gl_Position.x, -gl_Position.y, gl_Position.z, gl_Position.w);
    stage_output._24 = _24;
    stage_output._26 = _26;
    stage_output._37 = _37;
    stage_output._39 = _39;
    stage_output._40 = _40;
    stage_output._41 = _41;
    stage_output._42 = _42;
    stage_output._43 = _43;
    stage_output._45 = _45;
    stage_output._46 = _46;
    stage_output._47 = _47;
    stage_output._48 = _48;
    stage_output._49 = _49;
    stage_output._51 = _51;
    stage_output._52 = _52;
    return stage_output;
}
