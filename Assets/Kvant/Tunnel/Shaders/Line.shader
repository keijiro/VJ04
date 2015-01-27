//
// Surface shader for Tunnel wire frame.
//
Shader "Hidden/Kvant/Tunnel/Line"
{
    Properties
    {
        _PositionTex    ("-", 2D)       = ""{}
        _Color          ("-", Color)    = (1, 1, 1, 0.5)
        _ColorAmp       ("-", Float)    = 1
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    struct v2f
    {
        float4 position : SV_POSITION;
    };

    sampler2D _PositionTex;
    float4 _PositionTex_TexelSize;

    float4 _Color;
    float _ColorAmp;

    v2f vert(appdata_base v)
    {
        float2 uv = v.texcoord + _PositionTex_TexelSize / 2;

        float4 pos = v.vertex;
        pos.xyz += tex2Dlod(_PositionTex, float4(uv, 0, 0)).xyz;

        v2f o;
        o.position = mul(UNITY_MATRIX_MVP, pos);
        return o;
    }

    float4 frag(v2f i) : COLOR
    {
        return float4(_Color.rgb * _ColorAmp, _Color.a);
    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma target 3.0
            #pragma glsl
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    } 
}
