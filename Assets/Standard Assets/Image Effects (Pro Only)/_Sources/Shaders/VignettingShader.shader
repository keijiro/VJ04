Shader "Hidden/Vignetting" {
	Properties {
		_MainTex ("Base", 2D) = "white" {}
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	
	half _Intensity;
    half _CurveCoeff;

	float4 _MainTex_TexelSize;
	
	half4 frag(v2f_img i) : SV_Target {
		half2 coords = i.uv;
		half2 uv = i.uv;
		
		coords = (coords - 0.5) * 2.0;		
		half coordDot = dot (coords,coords);
		half4 color = tex2D (_MainTex, uv);	 

		float mask = max(1.0 - pow(coordDot, _CurveCoeff) * _Intensity * 0.1, 0);

		return color * mask;
	}

	ENDCG 
	
Subshader {
 Pass {
	  ZTest Always Cull Off ZWrite Off
	  Fog { Mode off }      

      CGPROGRAM
      #pragma fragmentoption ARB_precision_hint_fastest 
      #pragma vertex vert_img
      #pragma fragment frag
      ENDCG
  }
}

Fallback off	
} 
