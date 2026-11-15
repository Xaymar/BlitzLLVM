cbuffer Constants : register(b0)
{
    float4 pc_metrics : packoffset(c0);
    float4 pc_subsample : packoffset(c1);
    row_major float4x4 pc_reproject : packoffset(c2);
    float4 pc_resolve : packoffset(c6);
    float4 pc_depthmap : packoffset(c7);
};

Texture2D<float4> tex0 : register(t0);
SamplerState _tex0_sampler : register(s0);
Texture2D<float4> tex1 : register(t1);
SamplerState _tex1_sampler : register(s1);
Texture2D<float4> tex2 : register(t2);
SamplerState _tex2_sampler : register(s2);

static float4 o_color;
static float2 v_texcoord;
static float2 v_pixcoord;
static float4 v_offset[3];

struct SPIRV_Cross_Input
{
    float2 v_texcoord : TEXCOORD0;
    float2 v_pixcoord : TEXCOORD1;
    float4 v_offset[3] : TEXCOORD2;
};

struct SPIRV_Cross_Output
{
    float4 o_color : SV_Target0;
};

float2 SMAASearchDiag1(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, float2 texcoord, float2 dir, inout float2 e)
{
    float4 coord = float4(texcoord, -1.0f, 1.0f);
    float3 t = float3(pc_metrics.xy, 1.0f);
    for (;;)
    {
        bool _207 = coord.z < 15.0f;
        bool _214;
        if (_207)
        {
            _214 = coord.w > 0.89999997615814208984375f;
        }
        else
        {
            _214 = _207;
        }
        if (_214)
        {
            float4 _220 = coord;
            float3 _222 = mad(t, float3(dir, 1.0f), _220.xyz);
            coord.x = _222.x;
            coord.y = _222.y;
            coord.z = _222.z;
            e = edgesTex.SampleLevel(_edgesTex_sampler, coord.xy, 0.0f).xy;
            coord.w = dot(e, 0.5f.xx);
            continue;
        }
        else
        {
            break;
        }
    }
    return coord.zw;
}

float4 SMAADecodeDiagBilinearAccess(inout float4 e)
{
    float4 _158 = e;
    float4 _160 = e;
    float2 _166 = _158.xz * abs((_160.xz * 5.0f) - 3.75f.xx);
    e.x = _166.x;
    e.z = _166.y;
    return round(e);
}

void SMAAMovc(bool2 cond, inout float2 variable, float2 value)
{
    if (cond.x)
    {
        variable.x = value.x;
    }
    if (cond.y)
    {
        variable.y = value.y;
    }
}

float2 SMAAAreaDiag(Texture2D<float4> areaTex, SamplerState _areaTex_sampler, float2 dist, float2 e, float offset)
{
    float2 texcoord = mad(20.0f.xx, e, dist);
    texcoord = mad(float2(0.0062500000931322574615478515625f, 0.001785714295692741870880126953125f), texcoord, float2(0.00312500004656612873077392578125f, 0.0008928571478463709354400634765625f));
    texcoord.x += 0.5f;
    texcoord.y += (0.14285714924335479736328125f * offset);
    return areaTex.SampleLevel(_areaTex_sampler, texcoord, 0.0f).xy;
}

float2 SMAADecodeDiagBilinearAccess(inout float2 e)
{
    e.x *= abs((5.0f * e.x) - 3.75f);
    return round(e);
}

float2 SMAASearchDiag2(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, float2 texcoord, float2 dir, inout float2 e)
{
    float4 coord = float4(texcoord, -1.0f, 1.0f);
    coord.x += (0.25f * pc_metrics.x);
    float3 t = float3(pc_metrics.xy, 1.0f);
    for (;;)
    {
        bool _272 = coord.z < 15.0f;
        bool _278;
        if (_272)
        {
            _278 = coord.w > 0.89999997615814208984375f;
        }
        else
        {
            _278 = _272;
        }
        if (_278)
        {
            float4 _284 = coord;
            float3 _286 = mad(t, float3(dir, 1.0f), _284.xyz);
            coord.x = _286.x;
            coord.y = _286.y;
            coord.z = _286.z;
            e = edgesTex.SampleLevel(_edgesTex_sampler, coord.xy, 0.0f).xy;
            float2 param = e;
            float2 _300 = SMAADecodeDiagBilinearAccess(param);
            e = _300;
            coord.w = dot(e, 0.5f.xx);
            continue;
        }
        else
        {
            break;
        }
    }
    return coord.zw;
}

float2 SMAACalculateDiagWeights(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, Texture2D<float4> areaTex, SamplerState _areaTex_sampler, float2 texcoord, float2 e, float4 subsampleIndices)
{
    float2 weights = 0.0f.xx;
    float4 d;
    float2 end;
    if (e.x > 0.0f)
    {
        float2 param = texcoord;
        float2 param_1 = float2(-1.0f, 1.0f);
        float2 param_2;
        float2 _353 = SMAASearchDiag1(edgesTex, _edgesTex_sampler, param, param_1, param_2);
        end = param_2;
        d.x = _353.x;
        d.z = _353.y;
        d.x += float(end.y > 0.89999997615814208984375f);
    }
    else
    {
        d.x = 0.0f;
        d.z = 0.0f;
    }
    float2 param_3 = texcoord;
    float2 param_4 = float2(1.0f, -1.0f);
    float2 param_5;
    float2 _377 = SMAASearchDiag1(edgesTex, _edgesTex_sampler, param_3, param_4, param_5);
    end = param_5;
    d.y = _377.x;
    d.w = _377.y;
    if ((d.x + d.y) > 2.0f)
    {
        float4 coords = mad(float4((-d.x) + 0.25f, d.x, d.y, (-d.y) - 0.25f), pc_metrics.xyxy, texcoord.xyxy);
        float2 _420 = edgesTex.SampleLevel(_edgesTex_sampler, coords.xy, 0.0f, int2(-1, 0)).xy;
        float4 c;
        c.x = _420.x;
        c.y = _420.y;
        float2 _431 = edgesTex.SampleLevel(_edgesTex_sampler, coords.zw, 0.0f, int2(1, 0)).xy;
        c.z = _431.x;
        c.w = _431.y;
        float4 param_6 = c;
        float4 _438 = SMAADecodeDiagBilinearAccess(param_6);
        c = float4(_438.y, _438.x, _438.w, _438.z);
        float2 cc = mad(2.0f.xx, c.xz, c.yw);
        float2 _451 = step(0.89999997615814208984375f.xx, d.zw);
        bool2 param_7 = bool2(_451.x != 0.0f.xx.x, _451.y != 0.0f.xx.y);
        float2 param_8 = cc;
        float2 param_9 = 0.0f.xx;
        SMAAMovc(param_7, param_8, param_9);
        cc = param_8;
        float2 param_10 = d.xy;
        float2 param_11 = cc;
        float param_12 = subsampleIndices.z;
        weights += SMAAAreaDiag(areaTex, _areaTex_sampler, param_10, param_11, param_12);
    }
    float2 param_13 = texcoord;
    float2 param_14 = (-1.0f).xx;
    float2 param_15;
    float2 _475 = SMAASearchDiag2(edgesTex, _edgesTex_sampler, param_13, param_14, param_15);
    end = param_15;
    d.x = _475.x;
    d.z = _475.y;
    if (edgesTex.SampleLevel(_edgesTex_sampler, texcoord, 0.0f, int2(1, 0)).x > 0.0f)
    {
        float2 param_16 = texcoord;
        float2 param_17 = 1.0f.xx;
        float2 param_18;
        float2 _493 = SMAASearchDiag2(edgesTex, _edgesTex_sampler, param_16, param_17, param_18);
        end = param_18;
        d.y = _493.x;
        d.w = _493.y;
        d.y += float(end.y > 0.89999997615814208984375f);
    }
    else
    {
        d.y = 0.0f;
        d.w = 0.0f;
    }
    if ((d.x + d.y) > 2.0f)
    {
        float4 coords_1 = mad(float4(-d.x, -d.x, d.y, d.y), pc_metrics.xyxy, texcoord.xyxy);
        float4 c_1;
        c_1.x = edgesTex.SampleLevel(_edgesTex_sampler, coords_1.xy, 0.0f, int2(-1, 0)).y;
        c_1.y = edgesTex.SampleLevel(_edgesTex_sampler, coords_1.xy, 0.0f, int2(0, -1)).x;
        float2 _556 = edgesTex.SampleLevel(_edgesTex_sampler, coords_1.zw, 0.0f, int2(1, 0)).yx;
        c_1.z = _556.x;
        c_1.w = _556.y;
        float2 cc_1 = mad(2.0f.xx, c_1.xz, c_1.yw);
        float2 _570 = step(0.89999997615814208984375f.xx, d.zw);
        bool2 param_19 = bool2(_570.x != 0.0f.xx.x, _570.y != 0.0f.xx.y);
        float2 param_20 = cc_1;
        float2 param_21 = 0.0f.xx;
        SMAAMovc(param_19, param_20, param_21);
        cc_1 = param_20;
        float2 param_22 = d.xy;
        float2 param_23 = cc_1;
        float param_24 = subsampleIndices.w;
        weights += SMAAAreaDiag(areaTex, _areaTex_sampler, param_22, param_23, param_24).yx;
    }
    return weights;
}

float SMAASearchLength(Texture2D<float4> searchTex, SamplerState _searchTex_sampler, float2 e, float offset)
{
    float2 scale = float2(33.0f, -33.0f);
    float2 bias = float2(66.0f, 33.0f) * float2(offset, 1.0f);
    scale += float2(-1.0f, 1.0f);
    bias += float2(0.5f, -0.5f);
    scale *= float2(0.015625f, 0.0625f);
    bias *= float2(0.015625f, 0.0625f);
    return searchTex.SampleLevel(_searchTex_sampler, mad(scale, e, bias), 0.0f).x;
}

float SMAASearchXLeft(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, Texture2D<float4> searchTex, SamplerState _searchTex_sampler, inout float2 texcoord, float end)
{
    float2 e = float2(0.0f, 1.0f);
    for (;;)
    {
        bool _635 = texcoord.x > end;
        bool _642;
        if (_635)
        {
            _642 = e.y > 0.828100025653839111328125f;
        }
        else
        {
            _642 = _635;
        }
        bool _648;
        if (_642)
        {
            _648 = e.x == 0.0f;
        }
        else
        {
            _648 = _642;
        }
        if (_648)
        {
            e = edgesTex.SampleLevel(_edgesTex_sampler, texcoord, 0.0f).xy;
            texcoord = mad(float2(-2.0f, -0.0f), pc_metrics.xy, texcoord);
            continue;
        }
        else
        {
            break;
        }
    }
    float2 param = e;
    float param_1 = 0.0f;
    float offset = mad(-2.007874011993408203125f, SMAASearchLength(searchTex, _searchTex_sampler, param, param_1), 3.25f);
    return mad(pc_metrics.x, offset, texcoord.x);
}

float SMAASearchXRight(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, Texture2D<float4> searchTex, SamplerState _searchTex_sampler, inout float2 texcoord, float end)
{
    float2 e = float2(0.0f, 1.0f);
    for (;;)
    {
        bool _686 = texcoord.x < end;
        bool _692;
        if (_686)
        {
            _692 = e.y > 0.828100025653839111328125f;
        }
        else
        {
            _692 = _686;
        }
        bool _698;
        if (_692)
        {
            _698 = e.x == 0.0f;
        }
        else
        {
            _698 = _692;
        }
        if (_698)
        {
            e = edgesTex.SampleLevel(_edgesTex_sampler, texcoord, 0.0f).xy;
            texcoord = mad(float2(2.0f, 0.0f), pc_metrics.xy, texcoord);
            continue;
        }
        else
        {
            break;
        }
    }
    float2 param = e;
    float param_1 = 0.5f;
    float offset = mad(-2.007874011993408203125f, SMAASearchLength(searchTex, _searchTex_sampler, param, param_1), 3.25f);
    return mad(-pc_metrics.x, offset, texcoord.x);
}

float2 SMAAArea(Texture2D<float4> areaTex, SamplerState _areaTex_sampler, float2 dist, float e1, float e2, float offset)
{
    float2 texcoord = mad(16.0f.xx, round(float2(e1, e2) * 4.0f), dist);
    texcoord = mad(float2(0.0062500000931322574615478515625f, 0.001785714295692741870880126953125f), texcoord, float2(0.00312500004656612873077392578125f, 0.0008928571478463709354400634765625f));
    texcoord.y = mad(0.14285714924335479736328125f, offset, texcoord.y);
    return areaTex.SampleLevel(_areaTex_sampler, texcoord, 0.0f).xy;
}

void SMAADetectHorizontalCornerPattern(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, inout float2 weights, float4 texcoord, float2 d)
{
    float2 leftRight = step(d, d.yx);
    float2 rounding = leftRight * 0.75f;
    rounding /= (leftRight.x + leftRight.y).xx;
    float2 factor = 1.0f.xx;
    factor.x -= (rounding.x * edgesTex.SampleLevel(_edgesTex_sampler, texcoord.xy, 0.0f, int2(0, 1)).x);
    factor.x -= (rounding.y * edgesTex.SampleLevel(_edgesTex_sampler, texcoord.zw, 0.0f, int2(1, 1)).x);
    factor.y -= (rounding.x * edgesTex.SampleLevel(_edgesTex_sampler, texcoord.xy, 0.0f, int2(0, -2)).x);
    factor.y -= (rounding.y * edgesTex.SampleLevel(_edgesTex_sampler, texcoord.zw, 0.0f, int2(1, -2)).x);
    weights *= clamp(factor, 0.0f.xx, 1.0f.xx);
}

float SMAASearchYUp(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, Texture2D<float4> searchTex, SamplerState _searchTex_sampler, inout float2 texcoord, float end)
{
    float2 e = float2(1.0f, 0.0f);
    for (;;)
    {
        bool _734 = texcoord.y > end;
        bool _740;
        if (_734)
        {
            _740 = e.x > 0.828100025653839111328125f;
        }
        else
        {
            _740 = _734;
        }
        bool _746;
        if (_740)
        {
            _746 = e.y == 0.0f;
        }
        else
        {
            _746 = _740;
        }
        if (_746)
        {
            e = edgesTex.SampleLevel(_edgesTex_sampler, texcoord, 0.0f).xy;
            texcoord = mad(float2(-0.0f, -2.0f), pc_metrics.xy, texcoord);
            continue;
        }
        else
        {
            break;
        }
    }
    float2 param = e.yx;
    float param_1 = 0.0f;
    float offset = mad(-2.007874011993408203125f, SMAASearchLength(searchTex, _searchTex_sampler, param, param_1), 3.25f);
    return mad(pc_metrics.y, offset, texcoord.y);
}

float SMAASearchYDown(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, Texture2D<float4> searchTex, SamplerState _searchTex_sampler, inout float2 texcoord, float end)
{
    float2 e = float2(1.0f, 0.0f);
    for (;;)
    {
        bool _781 = texcoord.y < end;
        bool _787;
        if (_781)
        {
            _787 = e.x > 0.828100025653839111328125f;
        }
        else
        {
            _787 = _781;
        }
        bool _793;
        if (_787)
        {
            _793 = e.y == 0.0f;
        }
        else
        {
            _793 = _787;
        }
        if (_793)
        {
            e = edgesTex.SampleLevel(_edgesTex_sampler, texcoord, 0.0f).xy;
            texcoord = mad(float2(0.0f, 2.0f), pc_metrics.xy, texcoord);
            continue;
        }
        else
        {
            break;
        }
    }
    float2 param = e.yx;
    float param_1 = 0.5f;
    float offset = mad(-2.007874011993408203125f, SMAASearchLength(searchTex, _searchTex_sampler, param, param_1), 3.25f);
    return mad(-pc_metrics.y, offset, texcoord.y);
}

void SMAADetectVerticalCornerPattern(Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, inout float2 weights, float4 texcoord, float2 d)
{
    float2 leftRight = step(d, d.yx);
    float2 rounding = leftRight * 0.75f;
    rounding /= (leftRight.x + leftRight.y).xx;
    float2 factor = 1.0f.xx;
    factor.x -= (rounding.x * edgesTex.SampleLevel(_edgesTex_sampler, texcoord.xy, 0.0f, int2(1, 0)).y);
    factor.x -= (rounding.y * edgesTex.SampleLevel(_edgesTex_sampler, texcoord.zw, 0.0f, int2(1, 1)).y);
    factor.y -= (rounding.x * edgesTex.SampleLevel(_edgesTex_sampler, texcoord.xy, 0.0f, int2(-2, 0)).y);
    factor.y -= (rounding.y * edgesTex.SampleLevel(_edgesTex_sampler, texcoord.zw, 0.0f, int2(-2, 1)).y);
    weights *= clamp(factor, 0.0f.xx, 1.0f.xx);
}

float4 SMAABlendingWeightCalculationPS(float2 texcoord, float2 pixcoord, float4 offset[3], Texture2D<float4> edgesTex, SamplerState _edgesTex_sampler, Texture2D<float4> areaTex, SamplerState _areaTex_sampler, Texture2D<float4> searchTex, SamplerState _searchTex_sampler, float4 subsampleIndices)
{
    float4 weights = 0.0f.xxxx;
    float2 e = edgesTex.Sample(_edgesTex_sampler, texcoord).xy;
    if (e.y > 0.0f)
    {
        float2 param = texcoord;
        float2 param_1 = e;
        float4 param_2 = subsampleIndices;
        float2 _1012 = SMAACalculateDiagWeights(edgesTex, _edgesTex_sampler, areaTex, _areaTex_sampler, param, param_1, param_2);
        weights.x = _1012.x;
        weights.y = _1012.y;
        if (weights.x == (-weights.y))
        {
            float2 param_3 = offset[0].xy;
            float param_4 = offset[2].x;
            float _1034 = SMAASearchXLeft(edgesTex, _edgesTex_sampler, searchTex, _searchTex_sampler, param_3, param_4);
            float3 coords;
            coords.x = _1034;
            coords.y = offset[1].y;
            float2 d;
            d.x = coords.x;
            float e1 = edgesTex.SampleLevel(_edgesTex_sampler, coords.xy, 0.0f).x;
            float2 param_5 = offset[0].zw;
            float param_6 = offset[2].y;
            float _1056 = SMAASearchXRight(edgesTex, _edgesTex_sampler, searchTex, _searchTex_sampler, param_5, param_6);
            coords.z = _1056;
            d.y = coords.z;
            d = abs(round(mad(pc_metrics.zz, d, -pixcoord.xx)));
            float2 sqrt_d = sqrt(d);
            float e2 = edgesTex.SampleLevel(_edgesTex_sampler, coords.zy, 0.0f, int2(1, 0)).x;
            float2 param_7 = sqrt_d;
            float param_8 = e1;
            float param_9 = e2;
            float param_10 = subsampleIndices.y;
            float2 _1089 = SMAAArea(areaTex, _areaTex_sampler, param_7, param_8, param_9, param_10);
            weights.x = _1089.x;
            weights.y = _1089.y;
            coords.y = texcoord.y;
            float2 param_11 = weights.xy;
            float4 param_12 = coords.xyzy;
            float2 param_13 = d;
            SMAADetectHorizontalCornerPattern(edgesTex, _edgesTex_sampler, param_11, param_12, param_13);
            weights.x = param_11.x;
            weights.y = param_11.y;
        }
        else
        {
            e.x = 0.0f;
        }
    }
    if (e.x > 0.0f)
    {
        float2 param_14 = offset[1].xy;
        float param_15 = offset[2].z;
        float _1126 = SMAASearchYUp(edgesTex, _edgesTex_sampler, searchTex, _searchTex_sampler, param_14, param_15);
        float3 coords_1;
        coords_1.y = _1126;
        coords_1.x = offset[0].x;
        float2 d_1;
        d_1.x = coords_1.y;
        float e1_1 = edgesTex.SampleLevel(_edgesTex_sampler, coords_1.xy, 0.0f).y;
        float2 param_16 = offset[1].zw;
        float param_17 = offset[2].w;
        float _1148 = SMAASearchYDown(edgesTex, _edgesTex_sampler, searchTex, _searchTex_sampler, param_16, param_17);
        coords_1.z = _1148;
        d_1.y = coords_1.z;
        d_1 = abs(round(mad(pc_metrics.ww, d_1, -pixcoord.yy)));
        float2 sqrt_d_1 = sqrt(d_1);
        float e2_1 = edgesTex.SampleLevel(_edgesTex_sampler, coords_1.xz, 0.0f, int2(0, 1)).y;
        float2 param_18 = sqrt_d_1;
        float param_19 = e1_1;
        float param_20 = e2_1;
        float param_21 = subsampleIndices.x;
        float2 _1181 = SMAAArea(areaTex, _areaTex_sampler, param_18, param_19, param_20, param_21);
        weights.z = _1181.x;
        weights.w = _1181.y;
        coords_1.x = texcoord.x;
        float2 param_22 = weights.zw;
        float4 param_23 = coords_1.xyxz;
        float2 param_24 = d_1;
        SMAADetectVerticalCornerPattern(edgesTex, _edgesTex_sampler, param_22, param_23, param_24);
        weights.z = param_22.x;
        weights.w = param_22.y;
    }
    return weights;
}

void frag_main()
{
    float2 param = v_texcoord;
    float2 param_1 = v_pixcoord;
    float4 param_2[3] = v_offset;
    float4 param_3 = pc_subsample;
    o_color = SMAABlendingWeightCalculationPS(param, param_1, param_2, tex0, _tex0_sampler, tex1, _tex1_sampler, tex2, _tex2_sampler, param_3);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    v_texcoord = stage_input.v_texcoord;
    v_pixcoord = stage_input.v_pixcoord;
    v_offset = stage_input.v_offset;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_color = o_color;
    return stage_output;
}
