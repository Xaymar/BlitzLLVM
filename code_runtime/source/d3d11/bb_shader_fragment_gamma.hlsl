cbuffer _14_20 : register(b0)
{
    float4 _20_m0[256] : packoffset(c0);
};

cbuffer _15_16 : register(b1)
{
    float _16_m0 : packoffset(c0);
    float _16_m1 : packoffset(c0.y);
    float _16_m2 : packoffset(c0.z);
    float _16_m3 : packoffset(c0.w);
    float _16_m4 : packoffset(c1);
};

Texture2D<float4> _18 : register(t0);
SamplerState __18_sampler : register(s0);

static float4 gl_FragCoord;
static float2 _22;
static float4 _24;

struct SPIRV_Cross_Input
{
    float2 _22 : TEXCOORD0;
    float4 gl_FragCoord : SV_Position;
};

struct SPIRV_Cross_Output
{
    float4 _24 : SV_Target0;
};

void frag_main()
{
    float3 _39 = clamp(_18.Sample(__18_sampler, _22).xyz * 255.0f.xxx, 0.0f.xxx, 255.0f.xxx);
    float3 _40 = floor(_39);
    float _41 = _40.x;
    int _47 = int(_41);
    float _59 = _40.y;
    int _64 = int(_59);
    float _75 = _40.z;
    int _80 = int(_75);
    float _133 = floor(gl_FragCoord.x) + _16_m1;
    float _134 = floor(gl_FragCoord.y) - _16_m2;
    float _143 = floor(_133 * 1.0f);
    float _149 = floor(_134 * 1.0f);
    float _154 = (_143 - (2.0f * floor(_143 * 0.5f))) * 2.0f;
    float _159 = step(1.0f, _16_m4) * exp2(2.0f * ((_16_m4 - 1.0f) + 1.0f));
    float _170 = floor(_133 * 0.5f);
    float _176 = floor(_134 * 0.5f);
    float _181 = (_170 - (2.0f * floor(_170 * 0.5f))) * 2.0f;
    float _186 = step(2.0f, _16_m4) * exp2(2.0f * ((_16_m4 - 2.0f) + 1.0f));
    float _198 = floor(_133 * 0.25f);
    float _204 = floor(_134 * 0.25f);
    float _209 = (_198 - (2.0f * floor(_198 * 0.5f))) * 2.0f;
    float _214 = step(3.0f, _16_m4) * exp2(2.0f * ((_16_m4 - 3.0f) + 1.0f));
    float _227 = floor(_133 * 0.125f);
    float _233 = floor(_134 * 0.125f);
    float _238 = (_227 - (2.0f * floor(_227 * 0.5f))) * 2.0f;
    float _243 = step(4.0f, _16_m4) * exp2(2.0f * ((_16_m4 - 4.0f) + 1.0f));
    float _256 = floor(_133 * 0.0625f);
    float _262 = floor(_134 * 0.0625f);
    float _267 = (_256 - (2.0f * floor(_256 * 0.5f))) * 2.0f;
    float _272 = step(5.0f, _16_m4) * exp2(2.0f * ((_16_m4 - 5.0f) + 1.0f));
    float _285 = floor(_133 * 0.03125f);
    float _291 = floor(_134 * 0.03125f);
    float _296 = (_285 - (2.0f * floor(_285 * 0.5f))) * 2.0f;
    float _301 = step(6.0f, _16_m4) * exp2(2.0f * ((_16_m4 - 6.0f) + 1.0f));
    float _304 = (((((0.0f + (((_154 + (((3.0f - _154) - _154) * (_149 - (2.0f * floor(_149 * 0.5f))))) / 3.0f) * _159)) + (((_181 + (((3.0f - _181) - _181) * (_176 - (2.0f * floor(_176 * 0.5f))))) / 3.0f) * _186)) + (((_209 + (((3.0f - _209) - _209) * (_204 - (2.0f * floor(_204 * 0.5f))))) / 3.0f) * _214)) + (((_238 + (((3.0f - _238) - _238) * (_233 - (2.0f * floor(_233 * 0.5f))))) / 3.0f) * _243)) + (((_267 + (((3.0f - _267) - _267) * (_262 - (2.0f * floor(_262 * 0.5f))))) / 3.0f) * _272)) + (((_296 + (((3.0f - _296) - _296) * (_291 - (2.0f * floor(_291 * 0.5f))))) / 3.0f) * _301);
    float _314 = floor(_133 * 0.015625f);
    float _320 = floor(_134 * 0.015625f);
    float _325 = (_314 - (2.0f * floor(_314 * 0.5f))) * 2.0f;
    float _330 = step(7.0f, _16_m4) * exp2(2.0f * ((_16_m4 - 7.0f) + 1.0f));
    float _343 = floor(_133 * 0.0078125f);
    float _349 = floor(_134 * 0.0078125f);
    float _354 = (_343 - (2.0f * floor(_343 * 0.5f))) * 2.0f;
    float _359 = step(8.0f, _16_m4) * exp2(2.0f * ((_16_m4 - 8.0f) + 1.0f));
    float _368 = exp2(2.0f * _16_m4);
    float _370 = max(_368 - 1.0f, 1.0f);
    float _374 = floor(((((_304 + (((_325 + (((3.0f - _325) - _325) * (_320 - (2.0f * floor(_320 * 0.5f))))) / 3.0f) * _330)) + (((_354 + (((3.0f - _354) - _354) * (_349 - (2.0f * floor(_349 * 0.5f))))) / 3.0f) * _359)) / max((((((((0.0f + _159) + _186) + _214) + _243) + _272) + _301) + _330) + _359, 9.9999999747524270787835121154785e-07f)) * _370) + 0.5f) + _16_m3;
    float3 _386 = float3(_20_m0[_47].x + ((_20_m0[int(min(_41 + 1.0f, 255.0f))].x - _20_m0[_47].x) * (_39.x - _41)), _20_m0[_64].y + ((_20_m0[int(min(_59 + 1.0f, 255.0f))].y - _20_m0[_64].y) * (_39.y - _59)), _20_m0[_80].z + ((_20_m0[int(min(_75 + 1.0f, 255.0f))].z - _20_m0[_80].z) * (_39.z - _75)));
    float3 _387 = _386 * 255.0f.xxx;
    _24 = float4(_386 + ((1.0f.xxx * (((_16_m4 > 0.0f) ? ((((_374 - (_368 * floor(_374 / _368))) / _370) - 0.5f) * 0.0039215688593685626983642578125f) : ((frac(frac(((floor(gl_FragCoord.x) + _16_m0) * 0.067110560834407806396484375f) + ((floor(gl_FragCoord.y) + _16_m0) * 0.005837149918079376220703125f)) * 52.98291778564453125f) - 0.5f) * 0.0039215688593685626983642578125f)) * _20_m0[0].w)) * step(0.015625f.xxx, abs(_387 - floor(_387 + 0.5f.xxx)))), 1.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_FragCoord = stage_input.gl_FragCoord;
    gl_FragCoord.w = 1.0 / gl_FragCoord.w;
    _22 = stage_input._22;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output._24 = _24;
    return stage_output;
}
