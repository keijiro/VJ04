//
// Surface shader for Spray particles.
//
// Looks up the position and the rotation from the textures.
// TEXCOORD0 is used for lookup.
//
Shader "Hidden/Kvant/Spray/Surface"
{
    Properties
    {
        _PositionTex    ("-", 2D)       = ""{}
        _RotationTex    ("-", 2D)       = ""{}
        _Color          ("-", Color)    = (1, 1, 1, 1)
        _ScaleParams    ("-", Vector)   = (1, 1, 0, 0)
        _BufferOffset   ("-", Vector)   = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Spray" }
        
        CGPROGRAM

        #pragma surface surf Lambert vertex:vert finalcolor:envmap
        #pragma target 3.0
        #pragma glsl

        // Global settings.
        samplerCUBE _VJ04_EnvTex;
        float4x4 _VJ04_EnvMatrix;
        float _VJ04_Exposure;
        float _VJ04_Fresnel;
        float _VJ04_Roughness;

        sampler2D _PositionTex;
        sampler2D _RotationTex;
        float4 _Color;
        float2 _ScaleParams;
        float4 _BufferOffset;

        struct Input
        {
            float3 viewDir;
            float3 worldNormal;
            float3 worldRefl;
        };

        // Quaternion multiplication.
        // http://mathworld.wolfram.com/Quaternion.html
        float4 qmul(float4 q1, float4 q2)
        {
            return float4(
                q2.xyz * q1.w + q1.xyz * q2.w + cross(q1.xyz, q2.xyz),
                q1.w * q2.w - dot(q1.xyz, q2.xyz)
            );
        }

        // Rotate a vector with a rotation quaternion.
        // http://mathworld.wolfram.com/Quaternion.html
        float3 rotate_vector(float3 v, float4 r)
        {
            float4 r_c = r * float4(-1, -1, -1, 1);
            return qmul(r, qmul(float4(v, 0), r_c)).xyz;
        }

        void vert(inout appdata_full v)
        {
            float2 uv = v.texcoord + _BufferOffset;

            float4 p = tex2Dlod(_PositionTex, float4(uv, 0, 0));
            float4 r = tex2Dlod(_RotationTex, float4(uv, 0, 0));

            // Get the scale factor from life (p.w) and scale (r.w).
            float s = lerp(_ScaleParams.x, _ScaleParams.y, r.w);
            s *= min(1.0, 5.0 - abs(5.0 - p.w * 10));

            // Recover the scalar component of the unit quaternion.
            r.w = sqrt(1.0 - dot(r.xyz, r.xyz));

            // Apply the rotation and the scaling.
            v.vertex.xyz = rotate_vector(v.vertex.xyz, r) * s + p.xyz;
            v.normal = rotate_vector(v.normal, r);
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
            float3 refl = mul(_VJ04_EnvMatrix, float4(IN.worldRefl, 0)).xyz;
            float3 c_refl = sample_rgbm(texCUBElod(_VJ04_EnvTex, float4(refl, _VJ04_Roughness)));

            // Mix the envmap
            color.rgb += c_refl * _VJ04_Exposure * fr * _Color.a;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
            o.Alpha = 1;
        }

        ENDCG
    } 
}
