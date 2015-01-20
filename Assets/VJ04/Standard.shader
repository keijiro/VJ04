Shader "VJ04/Standard"
{
    Properties
    {
        _Color      ("Albedo", Color)               = (1, 1, 1, 1)
        _SpecColor  ("Specular Color", Color)       = (1, 1, 1, 1)
        _Shininess  ("Shininess", Range(0.03, 1))   = 0.078125
        _Fresnel    ("Fresnel Coefficient", float)  = 5
        _Roughness  ("Roughness", float)            = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        CGPROGRAM

        #pragma surface surf BlinnPhong finalcolor:envmap
        #pragma target 3.0
        #pragma glsl

        // Global settings.
        samplerCUBE _VJ04_EnvTex;
        float4x4 _VJ04_EnvMatrix;
        float _VJ04_Exposure;

        float4 _Color;
        float _Shininess;
        float _Fresnel;
        float _Roughness;

        struct Input
        {
            float3 viewDir;
            float3 worldRefl;
        };

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
            float3 n = normalize(o.Normal);
            float3 v = normalize(IN.viewDir);
            float fr = pow(1.0f - dot(v, n), _Fresnel);

            // Look up the cubemap with the world reflection vector.
            float3 refl = mul(_VJ04_EnvMatrix, float4(IN.worldRefl, 0)).xyz;
            float3 c_refl = sample_rgbm(texCUBElod(_VJ04_EnvTex, float4(refl, _Roughness)));

            // Mix the envmap
            color.rgb += c_refl * _VJ04_Exposure * fr;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
            o.Alpha = _Color.a;
            o.Gloss = 1;
            o.Specular = _Shininess;
        }

        ENDCG
    } 
    FallBack "Specular"
}
