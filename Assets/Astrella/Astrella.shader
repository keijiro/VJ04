Shader "VJ04/Astrella"
{
    Properties
    {
        _Color      ("Main Color", Color)           = (1, 1, 1, 1)
        _SpecColor  ("Specular Color", Color)       = (1, 1, 1, 1)
        _Shininess  ("Shininess", Range(0.03, 1))   = 0.078125
        _MainTex    ("Base (RGB) Gloss (A)", 2D)    = "white" {}
        _BumpMap    ("Normalmap", 2D)               = "bump" {}
        _Fresnel    ("Fresnel Coefficient", float)  = 5
        _Roughness  ("Roughness", float)            = 1
        _Effects    ("Effects", float)              = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        CGPROGRAM

        #pragma multi_compile FX_OFF FX_GHOST FX_SLICE
        #pragma surface surf BlinnPhong finalcolor:envmap
        #pragma target 3.0
        #pragma glsl

        // Global settings.
        samplerCUBE _VJ04_EnvTex;
        float _VJ04_Exposure;

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float4 _Color;
        float _Shininess;
        float _Fresnel;
        float _Roughness;
        float _Emission;
        float _Effects;

        struct Input
        {
            float3 worldPos;
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 viewDir;
            float3 worldRefl;
            INTERNAL_DATA
        };

        // PRNG function.
        float nrand(float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
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
            float3 n = normalize(o.Normal);
            float3 v = normalize(IN.viewDir);
            float fr = pow(1.0f - dot(v, n), _Fresnel);

            // Look up the cubemap with the world reflection vector.
            float4 refl = float4(WorldReflectionVector(IN, o.Normal), _Roughness);
            float3 c_refl = sample_rgbm(texCUBElod(_VJ04_EnvTex, refl));

            // Mix the envmap
            color.rgb += c_refl * _VJ04_Exposure * fr * o.Gloss;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            #ifdef FX_GHOST
            // Ghost effect.
            clip(nrand(IN.uv_MainTex) - _Effects);
            #elif FX_SLICE
            // Slice effect.
            clip(fmod(IN.uv_MainTex.y + _Time.y * 0.1, 0.02) - 0.02 * _Effects);
            #endif

            // Identical to the default bumped specular shader.
            float4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb * _Color.rgb;
            o.Gloss = tex.a;
            o.Alpha = tex.a * _Color.a;
            o.Specular = _Shininess;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Emission = _Emission;
        }

        ENDCG
    }
    FallBack "Specular"
}
