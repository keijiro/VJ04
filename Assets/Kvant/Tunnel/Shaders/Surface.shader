//
// Surface shader for Tunnel surface.
//
Shader "Hidden/Kvant/Tunnel/Surface"
{
    Properties
    {
        _PositionTex    ("-", 2D)       = ""{}
        _NormalTex      ("-", 2D)       = ""{}
        _Color          ("-", Color)    = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Offset 1, 1
        
        CGPROGRAM

        #pragma surface surf Lambert vertex:vert addshadow
        #pragma glsl

        sampler2D _PositionTex;
        float4 _PositionTex_TexelSize;

        sampler2D _NormalTex;
        float4 _NormalTex_TexelSize;

        float4 _Color;

        struct Input
        {
            float dummy;
        };

        void vert(inout appdata_full v)
        {
            float2 uv1 = v.texcoord;
            float2 uv2 = v.texcoord1;

            uv1 += _PositionTex_TexelSize.xy * 0.5;
            uv2 += _NormalTex_TexelSize.xy * 0.5;

            v.vertex.xyz += tex2D(_PositionTex, uv1).xyz;
            v.normal = tex2D(_NormalTex, uv2).xyz;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
            o.Alpha = 1;
        }

        ENDCG
    } 
}
