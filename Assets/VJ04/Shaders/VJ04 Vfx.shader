Shader "Hidden/VJ04 Vfx"
{
    Properties
    {
        _MainTex        ("-", 2D)    = ""{}
        _NoiseThreshold ("-", Float) = 0
        _NoiseDisplace  ("-", Float) = 1
        _Invert         ("-", Float) = 0
        _Whiteout       ("-", Float) = 0
    }
    
    CGINCLUDE

    #include "UnityCG.cginc"
    
    sampler2D _MainTex;
    float _NoiseThreshold;
    float _NoiseDisplace;
    float _Invert;
    float _Whiteout;

    // PRNG function.
    float nrand(float2 uv)
    {
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    float4 frag(v2f_img i) : SV_Target 
    {
        // Noise displacement.
        float r = (nrand(float2(i.uv.y * 2, _Time.x)) - 0.5) * 2;
        float d = r * _NoiseDisplace * step(_NoiseThreshold, abs(r));

        // Source color.
        float4 s = tex2D(_MainTex, i.uv + float2(d, 0));

        // Invert and whiteout.
        float3 c = s.rgb;
        c = float3(_Invert) + (1.0 - _Invert * 2) * c;
        c = min(c + _Whiteout, 1);

        return float4(c, s.a);
    }

    ENDCG 
    
    Subshader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            Fog { Mode off }      
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
}
