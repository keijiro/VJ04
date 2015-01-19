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
        Tags { "RenderType"="Tunnel" }
        Offset 1, 1
        
        CGPROGRAM

        #pragma multi_compile CONTOUR_OFF CONTOUR_ON

        #pragma surface surf Lambert vertex:vert addshadow finalcolor:envmap
        #pragma glsl

        // Global settings.
        samplerCUBE _VJ04_EnvTex;
        float _VJ04_Exposure;
        float _VJ04_Fresnel;
        float _VJ04_Roughness;

        sampler2D _PositionTex;
        float4 _PositionTex_TexelSize;

        sampler2D _NormalTex;
        float4 _NormalTex_TexelSize;

        float4 _Color;
        float2 _ContourParams;

        struct Input
        {
            float3 worldPos;
            float3 viewDir;
            float3 worldNormal;
            float3 worldRefl;
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

        // Decode an RGBM sample (Marmoset Skyshop's equation).
        float3 sample_rgbm(float4 c)
        {
            float gray = unity_ColorSpaceGrey.r;
            float4 IGL =
                float4(19.35486, -87.468483312, -171.964060128, c.a) *
                float4(gray, gray, gray, c.a) + 
                float4(-3.6774, 43.73410608, 85.98176352, 0.0);
            return c.rgb * dot(IGL.xyz, float3(c.a, IGL.w, c.a * IGL.w));
        }

        void envmap(Input IN, SurfaceOutput o, inout fixed4 color)
        {
            // Calculate the Fresnel reflection factor.
            float3 n = normalize(IN.worldNormal);
            float3 v = normalize(IN.viewDir);
            float fr = pow(1.0f - dot(v, n), _VJ04_Fresnel);

            // Look up the cubemap with the world reflection vector.
            float4 refl = float4(IN.worldRefl, _VJ04_Roughness);
            float3 c_refl = sample_rgbm(texCUBElod(_VJ04_EnvTex, refl));

            // Mix the envmap
            color.rgb += c_refl * _VJ04_Exposure * fr * _Color.a;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
        #ifdef CONTOUR_ON
            // Contour color line.
            float l = length(IN.worldPos.xz);
            float a = fmod(l + _Time.y * 0.50, 7.0) > 6.95;
            float b = fmod(l + _Time.y * 0.58, 8.0) > 7.95;
            a *= fmod(IN.worldPos.y + _Time.y * 15, 40) > 20;
            b *= fmod(IN.worldPos.y + _Time.y * 19, 40) > 20;
            float3 c1 = float3(a, b, b);
            float3 c2 = float3(b, b, a);

            o.Albedo = _Color.rgb * (1.0 - _ContourParams.y);
            o.Emission = lerp(c1, c2, _ContourParams.x) * _ContourParams.y * 50;
        #else
            o.Albedo = _Color.rgb;
        #endif
        }

        ENDCG
    } 
}
