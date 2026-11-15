cbuffer _13_19 : register(b0)
{
    float4 _19_m0[256] : packoffset(c0);
};

cbuffer _14_15 : register(b1)
{
    float _15_m0 : packoffset(c0);
    float _15_m1 : packoffset(c0.y);
    float _15_m2 : packoffset(c0.z);
    float _15_m3 : packoffset(c0.w);
    float _15_m4 : packoffset(c1);
};

Texture2D<float4> _17 : register(t0);
SamplerState __17_sampler : register(s0);
Texture2D<float4> _21 : register(t1);
SamplerState __21_sampler : register(s1);

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
    float4 _32 = _17.Sample(__17_sampler, _22);
    float3 _40 = floor((_32.xyz * 255.0f.xxx) + 0.5f.xxx);
    float _96 = floor(gl_FragCoord.x) + _15_m1;
    float _97 = floor(gl_FragCoord.y) - _15_m2;
    float _108 = floor(_96 * 1.0f);
    float _114 = floor(_97 * 1.0f);
    float _119 = (_108 - (2.0f * floor(_108 * 0.5f))) * 2.0f;
    float _124 = step(1.0f, _15_m4) * exp2(2.0f * ((_15_m4 - 1.0f) + 1.0f));
    float _135 = floor(_96 * 0.5f);
    float _141 = floor(_97 * 0.5f);
    float _146 = (_135 - (2.0f * floor(_135 * 0.5f))) * 2.0f;
    float _151 = step(2.0f, _15_m4) * exp2(2.0f * ((_15_m4 - 2.0f) + 1.0f));
    float _163 = floor(_96 * 0.25f);
    float _169 = floor(_97 * 0.25f);
    float _174 = (_163 - (2.0f * floor(_163 * 0.5f))) * 2.0f;
    float _179 = step(3.0f, _15_m4) * exp2(2.0f * ((_15_m4 - 3.0f) + 1.0f));
    float _192 = floor(_96 * 0.125f);
    float _198 = floor(_97 * 0.125f);
    float _203 = (_192 - (2.0f * floor(_192 * 0.5f))) * 2.0f;
    float _208 = step(4.0f, _15_m4) * exp2(2.0f * ((_15_m4 - 4.0f) + 1.0f));
    float _221 = floor(_96 * 0.0625f);
    float _227 = floor(_97 * 0.0625f);
    float _232 = (_221 - (2.0f * floor(_221 * 0.5f))) * 2.0f;
    float _237 = step(5.0f, _15_m4) * exp2(2.0f * ((_15_m4 - 5.0f) + 1.0f));
    float _250 = floor(_96 * 0.03125f);
    float _256 = floor(_97 * 0.03125f);
    float _261 = (_250 - (2.0f * floor(_250 * 0.5f))) * 2.0f;
    float _266 = step(6.0f, _15_m4) * exp2(2.0f * ((_15_m4 - 6.0f) + 1.0f));
    float _269 = (((((0.0f + (((_119 + (((3.0f - _119) - _119) * (_114 - (2.0f * floor(_114 * 0.5f))))) / 3.0f) * _124)) + (((_146 + (((3.0f - _146) - _146) * (_141 - (2.0f * floor(_141 * 0.5f))))) / 3.0f) * _151)) + (((_174 + (((3.0f - _174) - _174) * (_169 - (2.0f * floor(_169 * 0.5f))))) / 3.0f) * _179)) + (((_203 + (((3.0f - _203) - _203) * (_198 - (2.0f * floor(_198 * 0.5f))))) / 3.0f) * _208)) + (((_232 + (((3.0f - _232) - _232) * (_227 - (2.0f * floor(_227 * 0.5f))))) / 3.0f) * _237)) + (((_261 + (((3.0f - _261) - _261) * (_256 - (2.0f * floor(_256 * 0.5f))))) / 3.0f) * _266);
    float _279 = floor(_96 * 0.015625f);
    float _285 = floor(_97 * 0.015625f);
    float _290 = (_279 - (2.0f * floor(_279 * 0.5f))) * 2.0f;
    float _295 = step(7.0f, _15_m4) * exp2(2.0f * ((_15_m4 - 7.0f) + 1.0f));
    float _308 = floor(_96 * 0.0078125f);
    float _314 = floor(_97 * 0.0078125f);
    float _319 = (_308 - (2.0f * floor(_308 * 0.5f))) * 2.0f;
    float _324 = step(8.0f, _15_m4) * exp2(2.0f * ((_15_m4 - 8.0f) + 1.0f));
    float _333 = exp2(2.0f * _15_m4);
    float _335 = max(_333 - 1.0f, 1.0f);
    float _339 = floor(((((_269 + (((_290 + (((3.0f - _290) - _290) * (_285 - (2.0f * floor(_285 * 0.5f))))) / 3.0f) * _295)) + (((_319 + (((3.0f - _319) - _319) * (_314 - (2.0f * floor(_314 * 0.5f))))) / 3.0f) * _324)) / max((((((((0.0f + _124) + _151) + _179) + _208) + _237) + _266) + _295) + _324, 9.9999999747524270787835121154785e-07f)) * _335) + 0.5f) + _15_m3;
    float _349 = (_15_m4 > 0.0f) ? ((((_339 - (_333 * floor(_339 / _333))) / _335) - 0.5f) * 0.0039215688593685626983642578125f) : ((frac(frac(((floor(gl_FragCoord.x) + _15_m0) * 0.067110560834407806396484375f) + ((floor(gl_FragCoord.y) + _15_m0) * 0.005837149918079376220703125f)) * 52.98291778564453125f) - 0.5f) * 0.0039215688593685626983642578125f);
    float3 _365 = float3(_19_m0[int(_40.x)].x + (_349 * _19_m0[0].w), _19_m0[int(_40.y)].y + (_349 * _19_m0[1].w), _19_m0[int(_40.z)].z + (_349 * _19_m0[2].w));
    float3 _426;
    if (_21.SampleLevel(__21_sampler, float2(0.0003662109375f, 0.948529422283172607421875f), 0.0f).x > 0.5f)
    {
        float3 _382 = floor((clamp(_365, 0.0f.xxx, 1.0f.xxx) * 255.0f.xxx) + 0.5f.xxx);
        _426 = float3(_21.SampleLevel(__21_sampler, float2((_382.x + 0.5f) * 0.000244140625f, 0.963235318660736083984375f), 0.0f).x, _21.SampleLevel(__21_sampler, float2((_382.y + 0.5f) * 0.000244140625f, 0.97794115543365478515625f), 0.0f).x, _21.SampleLevel(__21_sampler, float2((_382.z + 0.5f) * 0.000244140625f, 0.99264705181121826171875f), 0.0f).x);
    }
    else
    {
        float3 _411 = floor((clamp(_365, 0.0f.xxx, 1.0f.xxx) * 63.0f.xxx) + 0.5f.xxx);
        _426 = _21.SampleLevel(__21_sampler, float2((((_411.z * 64.0f) + _411.x) + 0.5f) * 0.000244140625f, (_411.y + 0.5f) * 0.014705882407724857330322265625f), 0.0f).xyz;
    }
    _24 = float4(_426, 1.0f);
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
