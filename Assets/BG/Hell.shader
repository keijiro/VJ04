Shader "Custom/Hell"
{
    Properties
    {
        _Color      ("Color", Color)        = (1, 1, 1, 1)
        _ColorAmp   ("Color Amp", Float)    = 1
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    struct v2f
    {
        float4 position : SV_POSITION;
        float4 color : COLOR;
    };

    float4 _Color;
    float _ColorAmp;

    v2f vert(appdata_base v)
    {
        v2f o;
        o.position = mul(UNITY_MATRIX_MVP, v.vertex);
        o.color = _Color * v.normal.y;
        return o;
    }

    half4 frag(v2f i) : COLOR
    {
        return i.color * _ColorAmp;
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Fog { Mode Off }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    } 
}
