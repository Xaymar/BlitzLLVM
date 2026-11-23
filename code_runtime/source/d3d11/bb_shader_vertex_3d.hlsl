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
#define _791 bb_constant_0
#define _792 bb_constant_1

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
static float3 _31;
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
    float3 _29 : TEXCOORD0;
    float3 _31 : TEXCOORD1;
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
    nointerpolation float4 _26 : TEXCOORD6;
    float4 _39 : TEXCOORD7;
    nointerpolation float4 _28 : TEXCOORD8;
    float3 _46 : TEXCOORD9;
    nointerpolation float4 _47 : TEXCOORD10;
    nointerpolation float4 _48 : TEXCOORD11;
    nointerpolation float _49 : TEXCOORD12;
    nointerpolation float4 _51 : TEXCOORD13;
    float4 _52 : TEXCOORD14;
    float4 gl_Position : SV_Position;
    float4 gl_ClipDistance0 : SV_ClipDistance0;
    float2 gl_ClipDistance1 : SV_ClipDistance1;
};

void vert_main()
{
    _26 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 96));
    float4 _93 = float4(_29, 1.0f);
    float3 _97 = float3(dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 0)), _93), dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 16)), _93), dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 32)), _93));
    float3 _104 = float3(dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 0)).xyz, _31), dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 16)).xyz, _31), dot(asfloat(_22.Load4(gl_InstanceIndex * 192 + 32)).xyz, _31));
    float3 _109 = _104 * (1.0f / max(length(_104), 9.9999999747524270787835121154785e-07f));
    float4 _116 = float4(_97, 1.0f);
    float4 _117 = mul(_116, _17_m0);
    gl_Position = _117;
    gl_ClipDistance[0] = dot(_17_m13[0], _116);
    gl_ClipDistance[1] = dot(_17_m13[1], _116);
    gl_ClipDistance[2] = dot(_17_m13[2], _116);
    gl_ClipDistance[3] = dot(_17_m13[3], _116);
    gl_ClipDistance[4] = dot(_17_m13[4], _116);
    gl_ClipDistance[5] = dot(_17_m13[5], _116);
    _28 = float4(asfloat(_22.Load4(gl_InstanceIndex * 192 + 160)).xy, asfloat(_22.Load4(gl_InstanceIndex * 192 + 160)).z + (asfloat(_22.Load4(gl_InstanceIndex * 192 + 160)).w * mul(float4(asfloat(_22.Load4(gl_InstanceIndex * 192 + 0)).w, asfloat(_22.Load4(gl_InstanceIndex * 192 + 16)).w, asfloat(_22.Load4(gl_InstanceIndex * 192 + 32)).w, 1.0f), _17_m0).w), asfloat(_22.Load4(gl_InstanceIndex * 192 + 160)).w);
    float3 _782;
    float3 _783;
    if ((!(asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).w > 0.5f)) || (asfloat(_22.Load4(gl_InstanceIndex * 192 + 96)).z > 0.5f))
    {
        float3 _185 = _17_m6.xyz - _97;
        float3 _190 = _185 * (1.0f / max(length(_185), 9.9999997473787516355514526367188e-05f));
        float _195 = max(asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).w * 128.0f, 0.001000000047497451305389404296875f);
        float _199 = floor(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).x * 0.00390625f);
        int _203 = int(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).x - (_199 * 256.0f));
        int _204 = int(_199);
        float _207 = floor(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).y * 0.00390625f);
        int _210 = int(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).y - (_207 * 256.0f));
        int _211 = int(_207);
        float _214 = floor(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).z * 0.00390625f);
        int _217 = int(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).z - (_214 * 256.0f));
        int _218 = int(_214);
        float _221 = floor(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).w * 0.00390625f);
        int _224 = int(asfloat(_22.Load4(gl_InstanceIndex * 192 + 144)).w - (_221 * 256.0f));
        int _225 = int(_221);
        float3 _293;
        float3 _294;
        if (_203 < 127)
        {
            float3 _239 = _17_m2[_203].xyz - _97;
            float _240 = length(_239);
            float _246 = clamp(_17_m2[_203].w * 1000.0f, 0.0f, 1.0f);
            float3 _250 = (_17_m2[_203].xyz * (1.0f - _246)) + ((_239 * (1.0f / max(_240, 9.9999997473787516355514526367188e-05f))) * _246);
            float _252 = max(dot(_109, _250), 0.0f);
            float _276 = (1.0f + (((max(_17_m2[_203].w, 9.9999997473787516355514526367188e-05f) / max(_240, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _246)) * (1.0f + ((clamp(((0.0f - dot(_250, _17_m7[_203].xyz)) - _17_m7[_203].w) / max(_17_m3[_203].w - _17_m7[_203].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_203].w)));
            float3 _280 = _250 + _190;
            _293 = _17_m3[_203].xyz * (_252 * _276);
            _294 = 1.0f.xxx * ((pow(max(dot(_109, _280 * (1.0f / max(length(_280), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _195) * step(9.9999999747524270787835121154785e-07f, _252)) * _276);
        }
        else
        {
            _293 = 0.0f.xxx;
            _294 = 0.0f.xxx;
        }
        float3 _361;
        float3 _362;
        if (_204 < 127)
        {
            float3 _309 = _17_m2[_204].xyz - _97;
            float _310 = length(_309);
            float _315 = clamp(_17_m2[_204].w * 1000.0f, 0.0f, 1.0f);
            float3 _319 = (_17_m2[_204].xyz * (1.0f - _315)) + ((_309 * (1.0f / max(_310, 9.9999997473787516355514526367188e-05f))) * _315);
            float _321 = max(dot(_109, _319), 0.0f);
            float _344 = (1.0f + (((max(_17_m2[_204].w, 9.9999997473787516355514526367188e-05f) / max(_310, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _315)) * (1.0f + ((clamp(((0.0f - dot(_319, _17_m7[_204].xyz)) - _17_m7[_204].w) / max(_17_m3[_204].w - _17_m7[_204].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_204].w)));
            float3 _348 = _319 + _190;
            _361 = _17_m3[_204].xyz * (_321 * _344);
            _362 = 1.0f.xxx * ((pow(max(dot(_109, _348 * (1.0f / max(length(_348), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _195) * step(9.9999999747524270787835121154785e-07f, _321)) * _344);
        }
        else
        {
            _361 = 0.0f.xxx;
            _362 = 0.0f.xxx;
        }
        float3 _429;
        float3 _430;
        if (_210 < 127)
        {
            float3 _377 = _17_m2[_210].xyz - _97;
            float _378 = length(_377);
            float _383 = clamp(_17_m2[_210].w * 1000.0f, 0.0f, 1.0f);
            float3 _387 = (_17_m2[_210].xyz * (1.0f - _383)) + ((_377 * (1.0f / max(_378, 9.9999997473787516355514526367188e-05f))) * _383);
            float _389 = max(dot(_109, _387), 0.0f);
            float _412 = (1.0f + (((max(_17_m2[_210].w, 9.9999997473787516355514526367188e-05f) / max(_378, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _383)) * (1.0f + ((clamp(((0.0f - dot(_387, _17_m7[_210].xyz)) - _17_m7[_210].w) / max(_17_m3[_210].w - _17_m7[_210].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_210].w)));
            float3 _416 = _387 + _190;
            _429 = _17_m3[_210].xyz * (_389 * _412);
            _430 = 1.0f.xxx * ((pow(max(dot(_109, _416 * (1.0f / max(length(_416), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _195) * step(9.9999999747524270787835121154785e-07f, _389)) * _412);
        }
        else
        {
            _429 = 0.0f.xxx;
            _430 = 0.0f.xxx;
        }
        float3 _497;
        float3 _498;
        if (_211 < 127)
        {
            float3 _445 = _17_m2[_211].xyz - _97;
            float _446 = length(_445);
            float _451 = clamp(_17_m2[_211].w * 1000.0f, 0.0f, 1.0f);
            float3 _455 = (_17_m2[_211].xyz * (1.0f - _451)) + ((_445 * (1.0f / max(_446, 9.9999997473787516355514526367188e-05f))) * _451);
            float _457 = max(dot(_109, _455), 0.0f);
            float _480 = (1.0f + (((max(_17_m2[_211].w, 9.9999997473787516355514526367188e-05f) / max(_446, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _451)) * (1.0f + ((clamp(((0.0f - dot(_455, _17_m7[_211].xyz)) - _17_m7[_211].w) / max(_17_m3[_211].w - _17_m7[_211].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_211].w)));
            float3 _484 = _455 + _190;
            _497 = _17_m3[_211].xyz * (_457 * _480);
            _498 = 1.0f.xxx * ((pow(max(dot(_109, _484 * (1.0f / max(length(_484), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _195) * step(9.9999999747524270787835121154785e-07f, _457)) * _480);
        }
        else
        {
            _497 = 0.0f.xxx;
            _498 = 0.0f.xxx;
        }
        float3 _565;
        float3 _566;
        if (_217 < 127)
        {
            float3 _513 = _17_m2[_217].xyz - _97;
            float _514 = length(_513);
            float _519 = clamp(_17_m2[_217].w * 1000.0f, 0.0f, 1.0f);
            float3 _523 = (_17_m2[_217].xyz * (1.0f - _519)) + ((_513 * (1.0f / max(_514, 9.9999997473787516355514526367188e-05f))) * _519);
            float _525 = max(dot(_109, _523), 0.0f);
            float _548 = (1.0f + (((max(_17_m2[_217].w, 9.9999997473787516355514526367188e-05f) / max(_514, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _519)) * (1.0f + ((clamp(((0.0f - dot(_523, _17_m7[_217].xyz)) - _17_m7[_217].w) / max(_17_m3[_217].w - _17_m7[_217].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_217].w)));
            float3 _552 = _523 + _190;
            _565 = _17_m3[_217].xyz * (_525 * _548);
            _566 = 1.0f.xxx * ((pow(max(dot(_109, _552 * (1.0f / max(length(_552), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _195) * step(9.9999999747524270787835121154785e-07f, _525)) * _548);
        }
        else
        {
            _565 = 0.0f.xxx;
            _566 = 0.0f.xxx;
        }
        float3 _633;
        float3 _634;
        if (_218 < 127)
        {
            float3 _581 = _17_m2[_218].xyz - _97;
            float _582 = length(_581);
            float _587 = clamp(_17_m2[_218].w * 1000.0f, 0.0f, 1.0f);
            float3 _591 = (_17_m2[_218].xyz * (1.0f - _587)) + ((_581 * (1.0f / max(_582, 9.9999997473787516355514526367188e-05f))) * _587);
            float _593 = max(dot(_109, _591), 0.0f);
            float _616 = (1.0f + (((max(_17_m2[_218].w, 9.9999997473787516355514526367188e-05f) / max(_582, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _587)) * (1.0f + ((clamp(((0.0f - dot(_591, _17_m7[_218].xyz)) - _17_m7[_218].w) / max(_17_m3[_218].w - _17_m7[_218].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_218].w)));
            float3 _620 = _591 + _190;
            _633 = _17_m3[_218].xyz * (_593 * _616);
            _634 = 1.0f.xxx * ((pow(max(dot(_109, _620 * (1.0f / max(length(_620), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _195) * step(9.9999999747524270787835121154785e-07f, _593)) * _616);
        }
        else
        {
            _633 = 0.0f.xxx;
            _634 = 0.0f.xxx;
        }
        float3 _701;
        float3 _702;
        if (_224 < 127)
        {
            float3 _649 = _17_m2[_224].xyz - _97;
            float _650 = length(_649);
            float _655 = clamp(_17_m2[_224].w * 1000.0f, 0.0f, 1.0f);
            float3 _659 = (_17_m2[_224].xyz * (1.0f - _655)) + ((_649 * (1.0f / max(_650, 9.9999997473787516355514526367188e-05f))) * _655);
            float _661 = max(dot(_109, _659), 0.0f);
            float _684 = (1.0f + (((max(_17_m2[_224].w, 9.9999997473787516355514526367188e-05f) / max(_650, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _655)) * (1.0f + ((clamp(((0.0f - dot(_659, _17_m7[_224].xyz)) - _17_m7[_224].w) / max(_17_m3[_224].w - _17_m7[_224].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_224].w)));
            float3 _688 = _659 + _190;
            _701 = _17_m3[_224].xyz * (_661 * _684);
            _702 = 1.0f.xxx * ((pow(max(dot(_109, _688 * (1.0f / max(length(_688), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _195) * step(9.9999999747524270787835121154785e-07f, _661)) * _684);
        }
        else
        {
            _701 = 0.0f.xxx;
            _702 = 0.0f.xxx;
        }
        float3 _769;
        float3 _770;
        if (_225 < 127)
        {
            float3 _717 = _17_m2[_225].xyz - _97;
            float _718 = length(_717);
            float _723 = clamp(_17_m2[_225].w * 1000.0f, 0.0f, 1.0f);
            float3 _727 = (_17_m2[_225].xyz * (1.0f - _723)) + ((_717 * (1.0f / max(_718, 9.9999997473787516355514526367188e-05f))) * _723);
            float _729 = max(dot(_109, _727), 0.0f);
            float _752 = (1.0f + (((max(_17_m2[_225].w, 9.9999997473787516355514526367188e-05f) / max(_718, 9.9999997473787516355514526367188e-05f)) - 1.0f) * _723)) * (1.0f + ((clamp(((0.0f - dot(_727, _17_m7[_225].xyz)) - _17_m7[_225].w) / max(_17_m3[_225].w - _17_m7[_225].w, 9.9999997473787516355514526367188e-05f), 0.0f, 1.0f) - 1.0f) * step(-1.5f, _17_m7[_225].w)));
            float3 _756 = _727 + _190;
            _769 = _17_m3[_225].xyz * (_729 * _752);
            _770 = 1.0f.xxx * ((pow(max(dot(_109, _756 * (1.0f / max(length(_756), 9.9999997473787516355514526367188e-05f))), 9.9999997473787516355514526367188e-05f), _195) * step(9.9999999747524270787835121154785e-07f, _729)) * _752);
        }
        else
        {
            _769 = 0.0f.xxx;
            _770 = 0.0f.xxx;
        }
        float3 _771 = (((((((_17_m1.xyz + _293) + _361) + _429) + _497) + _565) + _633) + _701) + _769;
        _782 = _771 + ((1.0f.xxx - _771) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).x);
        _783 = ((((((((0.0f.xxx + _294) + _362) + _430) + _498) + _566) + _634) + _702) + _770) * (clamp(asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).w, 0.0f, 1.0f) * (1.0f - asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).x));
    }
    else
    {
        _782 = 1.0f.xxx;
        _783 = 0.0f.xxx;
    }
    float _802 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 48)).w * (1.0f + ((_34.w - 1.0f) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).z));
    float4 _810 = float4(clamp((asfloat(_22.Load4(gl_InstanceIndex * 192 + 48)).xyz + ((_34.xyz - asfloat(_22.Load4(gl_InstanceIndex * 192 + 48)).xyz) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).y)) * _782, _791.xxx, _792.xxx), _802 + ((_34.w - _802) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 64)).y));
    _40 = _810;
    _42 = _810;
    _43 = _783;
    _45 = _783;
    _46 = _109;
    _47 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 64));
    _48 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 144));
    _49 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).w;
    float2 _820 = _32 + ((_36 - _32) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).x);
    float _823 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).z + 1.0f;
    float _824 = _820.x;
    float _825 = _820.y;
    float2 _834 = (float2((_823 * _824) + (asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).y * _825), (_823 * _825) - (asfloat(_22.Load4(gl_InstanceIndex * 192 + 112)).y * _824)) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 80)).xy) + float2(asfloat(_22.Load4(gl_InstanceIndex * 192 + 80)).zw);
    float3 _847 = float3(dot(_109, _17_m8.xyz), dot(_109, _17_m9.xyz), dot(_109, _17_m10.xyz));
    float3 _865 = _97 - _17_m6.xyz;
    float3 _869 = _865 * (1.0f / max(length(_865), 9.9999997473787516355514526367188e-05f));
    float3 _874 = _869 - (_109 * (2.0f * dot(_109, _869)));
    float3 _879 = _874 + ((_109 - _874) * step(1.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).y));
    float3 _884 = _879 + ((_865 - _879) * step(2.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).y));
    _37 = _834 + ((float2((0.5f * _847.x) + 0.5f, 0.5f - (0.5f * _847.y)) - _834) * (step(0.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).x) * (1.0f - step(1.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).x))));
    _39 = float4(_884 + ((float3(dot(_884, _17_m8.xyz), dot(_884, _17_m9.xyz), dot(_884, _17_m10.xyz)) - _884) * asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).z), asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).w * step(1.5f, asfloat(_22.Load4(gl_InstanceIndex * 192 + 128)).x));
    _52 = float4(_32.x, _32.y, _36.x, _36.y);
    _51 = asfloat(_22.Load4(gl_InstanceIndex * 192 + 176));
    _41 = float4(_117.w, _97);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_InstanceIndex = int(stage_input.gl_InstanceIndex);
    _29 = stage_input._29;
    _31 = stage_input._31;
    _32 = stage_input._32;
    _34 = stage_input._34;
    _36 = stage_input._36;
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
