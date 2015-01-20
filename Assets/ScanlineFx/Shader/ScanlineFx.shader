Shader "Hidden/ScanlineFx"
{
    Properties
    {
        _MainTex   ("-", 2D)    = ""{}
        _Threshold ("-", Float) = 0
        _Displace  ("-", Float) = 1
    }
    
    CGINCLUDE

    #include "UnityCG.cginc"
    
    sampler2D _MainTex;
    float _Threshold;
    float _Displace;

    // PRNG function.
    float nrand(float2 uv)
    {
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    float4 frag(v2f_img i) : SV_Target 
    {
        float r = (nrand(float2(i.uv.y * 2, _Time.x)) - 0.5) * 2;
        float m = step(_Threshold, abs(r));
        return tex2D(_MainTex, i.uv + float2(r * _Displace * m, 0));
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
