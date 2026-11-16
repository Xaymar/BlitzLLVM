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
#define _764 bb_constant_0
#define _765 bb_constant_1

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
static float3 _29;
static float2 _30;
static float4 _32;
static float2 _34;
static float2 _35;
static float4 _37;
static float4 _38;
static float4 _39;
static float4 _40;
static float3 _41;
static float3 _43;
static float3 _44;
static float4 _45;
static float4 _46;
static float _47;
static float4 _49;
static float4 _50;

struct SPIRV_Cross_Input
{
    float3 _27 : TEXCOORD0;
    float3 _29 : TEXCOORD1;
    float2 _30 : TEXCOORD2;
    float4 _32 : TEXCOORD3;
    float2 _34 : TEXCOORD4;
    uint gl_InstanceIndex : BBINSTANCE;
};

struct SPIRV_Cross_Output
{
    float2 _35 : TEXCOORD0;
    float4 _38 : TEXCOORD1;
    float4 _39 : TEXCOORD2;
    nointerpolation float4 _40 : TEXCOORD3;
    float3 _41 : TEXCOORD4;
    nointerpolation float3 _43 : TEXCOORD5;
    nointerpolation float4 _24 : TEXCOORD6;
    float4 _37 : TEXCOORD7;
    nointerpolation float4 _26 : TEXCOORD8;
    float3 _44 : TEXCOORD9;
    nointerpolation float4 _45 : TEXCOORD10;
    nointerpolation float4 _46 : TEXCOORD11;
    nointerpolation float _47 : TEXCOORD12;
    nointerpolation float4 _49 : TEXCOORD13;
    float4 _50 : TEXCOORD14;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    _24 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 96));
    float4 _91 = float4(_27, 1.0f);
    float3 _95 = float3(dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 0)), _91), dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 16)), _91), dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 32)), _91));
    float3 _102 = float3(dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 0)).xyz, _29), dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 16)).xyz, _29), dot(asfloat(_20.Load4(gl_InstanceIndex * 192 + 32)).xyz, _29));
    float3 _107 = _102 * (1.0f / max(length(_102), 9.9999999747524270787835121154785e-07f));
    float4 _115 = mul(float4(_95, 1.0f), _15_m0);
    gl_Position = _115;
    _26 = float4(asfloat(_20.Load4(gl_InstanceIndex * 192 + 160)).xy, asfloat(_20.Load4(gl_InstanceIndex * 192 + 160)).z + (asfloat(_20.Load4(gl_InstanceIndex * 192 + 160)).w * mul(float4(asfloat(_20.Load4(gl_InstanceIndex * 192 + 0)).w, asfloat(_20.Load4(gl_InstanceIndex * 192 + 16)).w, asfloat(_20.Load4(gl_InstanceIndex * 192 + 32)).w, 1.0f), _15_m0).w), asfloat(_20.Load4(gl_InstanceIndex * 192 + 160)).w);
    float3 _755;
    float3 _756;
    if ((!(asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).w > 0.5f)) || (asfloat(_20.Load4(gl_InstanceIndex * 192 + 96)).z > 0.5f))
    {
        float3 _158 = _15_m6.xyz - _95;
        float3 _163 = _158 * (1.0f / max(length(_158), 9.9999997473787516355514526367188e-05f));
        float _168 = max(asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).w * 128.0f, 0.001000000047497451305389404296875f);
        float _172 = floor(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).x * 0.00390625f);
        int _176 = int(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).x - (_172 * 256.0f));
        int _177 = int(_172);
        float _180 = floor(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).y * 0.00390625f);
        int _183 = int(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).y - (_180 * 256.0f));
        int _184 = int(_180);
        float _187 = floor(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).z * 0.00390625f);
        int _190 = int(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).z - (_187 * 256.0f));
        int _191 = int(_187);
        float _194 = floor(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).w * 0.00390625f);
        int _197 = int(asfloat(_20.Load4(gl_InstanceIndex * 192 + 144)).w - (_194 * 256.0f));
        int _198 = int(_194);
        float3 _266;
        float3 _267;
        if (_176 < 127)
        {
            float3 _212 = _15_m2[_176].xyz - _95;
            float _213 = length(_212);
            float _219 = clamp(_15_m2[_176].w * 1000.0f, 0.0f, 1.0f);
            float3 _223 = (_15_m2[_176].xyz * (1.0f - _219)) + ((_212 * (1.0f / max(_213, 9.9999997473787516355514526367188e-05f))) * _219);
            float _225 = max(dot(_107, _223), 0.0f);
            float _249 = (1.0f + (((max(_15_m2[_176].w, 9.9999997473787516355514526367188e-05f) / max(_213, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _219)) * (1.0f + ((clamp(((0.0f - dot(_223, _15_m7[_176].xyz)) - _15_m7[_176].w) / max(_15_m3[_176].w - _15_m7[_176].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_176].w)));
            float3 _253 = _223 + _163;
            _266 = _15_m3[_176].xyz * (_225 * _249);
            _267 = 1.0f.xxx * ((pow(max(dot(_107, _253 * (1.0f / max(length(_253), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _168) * step(9.9999999747524270787835121154785e-07f, _225)) * _249);
        }
        else
        {
            _266 = 0.0f.xxx;
            _267 = 0.0f.xxx;
        }
        float3 _334;
        float3 _335;
        if (_177 < 127)
        {
            float3 _282 = _15_m2[_177].xyz - _95;
            float _283 = length(_282);
            float _288 = clamp(_15_m2[_177].w * 1000.0f, 0.0f, 1.0f);
            float3 _292 = (_15_m2[_177].xyz * (1.0f - _288)) + ((_282 * (1.0f / max(_283, 9.9999997473787516355514526367188e-05f))) * _288);
            float _294 = max(dot(_107, _292), 0.0f);
            float _317 = (1.0f + (((max(_15_m2[_177].w, 9.9999997473787516355514526367188e-05f) / max(_283, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _288)) * (1.0f + ((clamp(((0.0f - dot(_292, _15_m7[_177].xyz)) - _15_m7[_177].w) / max(_15_m3[_177].w - _15_m7[_177].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_177].w)));
            float3 _321 = _292 + _163;
            _334 = _15_m3[_177].xyz * (_294 * _317);
            _335 = 1.0f.xxx * ((pow(max(dot(_107, _321 * (1.0f / max(length(_321), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _168) * step(9.9999999747524270787835121154785e-07f, _294)) * _317);
        }
        else
        {
            _334 = 0.0f.xxx;
            _335 = 0.0f.xxx;
        }
        float3 _402;
        float3 _403;
        if (_183 < 127)
        {
            float3 _350 = _15_m2[_183].xyz - _95;
            float _351 = length(_350);
            float _356 = clamp(_15_m2[_183].w * 1000.0f, 0.0f, 1.0f);
            float3 _360 = (_15_m2[_183].xyz * (1.0f - _356)) + ((_350 * (1.0f / max(_351, 9.9999997473787516355514526367188e-05f))) * _356);
            float _362 = max(dot(_107, _360), 0.0f);
            float _385 = (1.0f + (((max(_15_m2[_183].w, 9.9999997473787516355514526367188e-05f) / max(_351, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _356)) * (1.0f + ((clamp(((0.0f - dot(_360, _15_m7[_183].xyz)) - _15_m7[_183].w) / max(_15_m3[_183].w - _15_m7[_183].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_183].w)));
            float3 _389 = _360 + _163;
            _402 = _15_m3[_183].xyz * (_362 * _385);
            _403 = 1.0f.xxx * ((pow(max(dot(_107, _389 * (1.0f / max(length(_389), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _168) * step(9.9999999747524270787835121154785e-07f, _362)) * _385);
        }
        else
        {
            _402 = 0.0f.xxx;
            _403 = 0.0f.xxx;
        }
        float3 _470;
        float3 _471;
        if (_184 < 127)
        {
            float3 _418 = _15_m2[_184].xyz - _95;
            float _419 = length(_418);
            float _424 = clamp(_15_m2[_184].w * 1000.0f, 0.0f, 1.0f);
            float3 _428 = (_15_m2[_184].xyz * (1.0f - _424)) + ((_418 * (1.0f / max(_419, 9.9999997473787516355514526367188e-05f))) * _424);
            float _430 = max(dot(_107, _428), 0.0f);
            float _453 = (1.0f + (((max(_15_m2[_184].w, 9.9999997473787516355514526367188e-05f) / max(_419, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _424)) * (1.0f + ((clamp(((0.0f - dot(_428, _15_m7[_184].xyz)) - _15_m7[_184].w) / max(_15_m3[_184].w - _15_m7[_184].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_184].w)));
            float3 _457 = _428 + _163;
            _470 = _15_m3[_184].xyz * (_430 * _453);
            _471 = 1.0f.xxx * ((pow(max(dot(_107, _457 * (1.0f / max(length(_457), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _168) * step(9.9999999747524270787835121154785e-07f, _430)) * _453);
        }
        else
        {
            _470 = 0.0f.xxx;
            _471 = 0.0f.xxx;
        }
        float3 _538;
        float3 _539;
        if (_190 < 127)
        {
            float3 _486 = _15_m2[_190].xyz - _95;
            float _487 = length(_486);
            float _492 = clamp(_15_m2[_190].w * 1000.0f, 0.0f, 1.0f);
            float3 _496 = (_15_m2[_190].xyz * (1.0f - _492)) + ((_486 * (1.0f / max(_487, 9.9999997473787516355514526367188e-05f))) * _492);
            float _498 = max(dot(_107, _496), 0.0f);
            float _521 = (1.0f + (((max(_15_m2[_190].w, 9.9999997473787516355514526367188e-05f) / max(_487, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _492)) * (1.0f + ((clamp(((0.0f - dot(_496, _15_m7[_190].xyz)) - _15_m7[_190].w) / max(_15_m3[_190].w - _15_m7[_190].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_190].w)));
            float3 _525 = _496 + _163;
            _538 = _15_m3[_190].xyz * (_498 * _521);
            _539 = 1.0f.xxx * ((pow(max(dot(_107, _525 * (1.0f / max(length(_525), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _168) * step(9.9999999747524270787835121154785e-07f, _498)) * _521);
        }
        else
        {
            _538 = 0.0f.xxx;
            _539 = 0.0f.xxx;
        }
        float3 _606;
        float3 _607;
        if (_191 < 127)
        {
            float3 _554 = _15_m2[_191].xyz - _95;
            float _555 = length(_554);
            float _560 = clamp(_15_m2[_191].w * 1000.0f, 0.0f, 1.0f);
            float3 _564 = (_15_m2[_191].xyz * (1.0f - _560)) + ((_554 * (1.0f / max(_555, 9.9999997473787516355514526367188e-05f))) * _560);
            float _566 = max(dot(_107, _564), 0.0f);
            float _589 = (1.0f + (((max(_15_m2[_191].w, 9.9999997473787516355514526367188e-05f) / max(_555, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _560)) * (1.0f + ((clamp(((0.0f - dot(_564, _15_m7[_191].xyz)) - _15_m7[_191].w) / max(_15_m3[_191].w - _15_m7[_191].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_191].w)));
            float3 _593 = _564 + _163;
            _606 = _15_m3[_191].xyz * (_566 * _589);
            _607 = 1.0f.xxx * ((pow(max(dot(_107, _593 * (1.0f / max(length(_593), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _168) * step(9.9999999747524270787835121154785e-07f, _566)) * _589);
        }
        else
        {
            _606 = 0.0f.xxx;
            _607 = 0.0f.xxx;
        }
        float3 _674;
        float3 _675;
        if (_197 < 127)
        {
            float3 _622 = _15_m2[_197].xyz - _95;
            float _623 = length(_622);
            float _628 = clamp(_15_m2[_197].w * 1000.0f, 0.0f, 1.0f);
            float3 _632 = (_15_m2[_197].xyz * (1.0f - _628)) + ((_622 * (1.0f / max(_623, 9.9999997473787516355514526367188e-05f))) * _628);
            float _634 = max(dot(_107, _632), 0.0f);
            float _657 = (1.0f + (((max(_15_m2[_197].w, 9.9999997473787516355514526367188e-05f) / max(_623, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _628)) * (1.0f + ((clamp(((0.0f - dot(_632, _15_m7[_197].xyz)) - _15_m7[_197].w) / max(_15_m3[_197].w - _15_m7[_197].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_197].w)));
            float3 _661 = _632 + _163;
            _674 = _15_m3[_197].xyz * (_634 * _657);
            _675 = 1.0f.xxx * ((pow(max(dot(_107, _661 * (1.0f / max(length(_661), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _168) * step(9.9999999747524270787835121154785e-07f, _634)) * _657);
        }
        else
        {
            _674 = 0.0f.xxx;
            _675 = 0.0f.xxx;
        }
        float3 _742;
        float3 _743;
        if (_198 < 127)
        {
            float3 _690 = _15_m2[_198].xyz - _95;
            float _691 = length(_690);
            float _696 = clamp(_15_m2[_198].w * 1000.0f, 0.0f, 1.0f);
            float3 _700 = (_15_m2[_198].xyz * (1.0f - _696)) + ((_690 * (1.0f / max(_691, 9.9999997473787516355514526367188e-05f))) * _696);
            float _702 = max(dot(_107, _700), 0.0f);
            float _725 = (1.0f + (((max(_15_m2[_198].w, 9.9999997473787516355514526367188e-05f) / max(_691, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _696)) * (1.0f + ((clamp(((0.0f - dot(_700, _15_m7[_198].xyz)) - _15_m7[_198].w) / max(_15_m3[_198].w - _15_m7[_198].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _15_m7[_198].w)));
            float3 _729 = _700 + _163;
            _742 = _15_m3[_198].xyz * (_702 * _725);
            _743 = 1.0f.xxx * ((pow(max(dot(_107, _729 * (1.0f / max(length(_729), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _168) * step(9.9999999747524270787835121154785e-07f, _702)) * _725);
        }
        else
        {
            _742 = 0.0f.xxx;
            _743 = 0.0f.xxx;
        }
        float3 _744 = (((((((_15_m1.xyz + _266) + _334) + _402) + _470) + _538) + _606) + _674) + _742;
        _755 = _744 + ((1.0f.xxx - _744) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).x);
        _756 = ((((((((0.0f.xxx + _267) + _335) + _403) + _471) + _539) + _607) + _675) + _743) * (clamp(asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).w, 0.0f, 1.0f) * (1.0f - asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).x));
    }
    else
    {
        _755 = 1.0f.xxx;
        _756 = 0.0f.xxx;
    }
    float _775 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 48)).w * (1.0f + ((_32.w - 1.0f) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).z));
    float4 _783 = float4(clamp((asfloat(_20.Load4(gl_InstanceIndex * 192 + 48)).xyz + ((_32.xyz - asfloat(_20.Load4(gl_InstanceIndex * 192 + 48)).xyz) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).y)) * _755, _764.xxx, _765.xxx), _775 + ((_32.w - _775) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 64)).y));
    _38 = _783;
    _40 = _783;
    _41 = _756;
    _43 = _756;
    _44 = _107;
    _45 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 64));
    _46 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 144));
    _47 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).w;
    float2 _793 = _30 + ((_34 - _30) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).x);
    float _796 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).z + 1.0f;
    float _797 = _793.x;
    float _798 = _793.y;
    float2 _807 = (float2((_796 * _797) + (asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).y * _798), (_796 * _798) - (asfloat(_20.Load4(gl_InstanceIndex * 192 + 112)).y * _797)) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 80)).xy) + float2(asfloat(_20.Load4(gl_InstanceIndex * 192 + 80)).zw);
    float3 _820 = float3(dot(_107, _15_m8.xyz), dot(_107, _15_m9.xyz), dot(_107, _15_m10.xyz));
    float3 _838 = _95 - _15_m6.xyz;
    float3 _842 = _838 * (1.0f / max(length(_838), 9.9999997473787516355514526367188e-05f));
    float3 _847 = _842 - (_107 * (2.0f * dot(_107, _842)));
    float3 _852 = _847 + ((_107 - _847) * step(1.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).y));
    float3 _857 = _852 + ((_838 - _852) * step(2.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).y));
    _35 = _807 + ((float2((0.5f * _820.x) + 0.5f, 0.5f - (0.5f * _820.y)) - _807) * (step(0.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).x) * (1.0f - step(1.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).x))));
    _37 = float4(_857 + ((float3(dot(_857, _15_m8.xyz), dot(_857, _15_m9.xyz), dot(_857, _15_m10.xyz)) - _857) * asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).z), asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).w * step(1.5f, asfloat(_20.Load4(gl_InstanceIndex * 192 + 128)).x));
    _50 = float4(_30.x, _30.y, _34.x, _34.y);
    _49 = asfloat(_20.Load4(gl_InstanceIndex * 192 + 176));
    _39 = float4(_115.w, _95);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_InstanceIndex = int(stage_input.gl_InstanceIndex);
    _27 = stage_input._27;
    _29 = stage_input._29;
    _30 = stage_input._30;
    _32 = stage_input._32;
    _34 = stage_input._34;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = float4(gl_Position.x, -gl_Position.y, gl_Position.z, gl_Position.w);
    stage_output._24 = _24;
    stage_output._26 = _26;
    stage_output._35 = _35;
    stage_output._37 = _37;
    stage_output._38 = _38;
    stage_output._39 = _39;
    stage_output._40 = _40;
    stage_output._41 = _41;
    stage_output._43 = _43;
    stage_output._44 = _44;
    stage_output._45 = _45;
    stage_output._46 = _46;
    stage_output._47 = _47;
    stage_output._49 = _49;
    stage_output._50 = _50;
    return stage_output;
}
