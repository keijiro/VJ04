Shader "Hidden/Camera-DepthTexture" {
Properties {
	_MainTex ("", 2D) = "white" {}
	_Cutoff ("", Float) = 0.5
	_Color ("", Color) = (1,1,1,1)
}
Category {
	Fog { Mode Off }

SubShader {
	Tags { "RenderType"="Opaque" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
struct v2f {
    float4 pos : SV_POSITION;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
    float2 depth : TEXCOORD0;
	#endif
};
v2f vert( appdata_base v ) {
    v2f o;
    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
    UNITY_TRANSFER_DEPTH(o.depth);
    return o;
}
fixed4 frag(v2f i) : SV_Target {
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="Astrella" }
	Pass {
CGPROGRAM
#pragma multi_compile FX_OFF FX_GHOST FX_SLICE
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#pragma glsl
#include "UnityCG.cginc"

struct v2f {
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
    float2 depth : TEXCOORD1;
	#endif
};

uniform float4 _MainTex_ST;
uniform float _Effects;

float nrand(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

v2f vert( appdata_base v ) {
    v2f o;
    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
    UNITY_TRANSFER_DEPTH(o.depth);
    return o;
}

fixed4 frag(v2f i) : SV_Target {
#ifdef FX_GHOST
    clip(nrand(floor(i.uv * 50) / 50 + _Time.y) - _Effects);
#elif FX_SLICE
    clip(fmod(i.uv.y + _Time.y * 0.1, 0.02) - 0.02 * _Effects);
#endif
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="Tunnel" }
	Pass {
CGPROGRAM
#pragma multi_compile SLICE_OFF SLICE_ON
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#pragma glsl
#include "UnityCG.cginc"

sampler2D _PositionTex;
float4 _PositionTex_TexelSize;
float2 _SliceParams;

struct v2f {
    float4 pos : SV_POSITION;
    float3 wpos : TEXCOORD0;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
    float2 depth : TEXCOORD1;
	#endif
};

v2f vert( appdata_base v ) {
    float2 uv1 = v.texcoord;
    uv1 += _PositionTex_TexelSize * 0.5;
    v.vertex.xyz += tex2Dlod(_PositionTex, float4(uv1, 0, 0)).xyz;

    v2f o;
    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
    o.wpos = mul(_Object2World, v.vertex).xyz;
    UNITY_TRANSFER_DEPTH(o.depth);
    return o;
}

fixed4 frag(v2f i) : SV_Target {
#ifdef SLICE_ON
    clip(frac(i.wpos.y * _SliceParams.x) - _SliceParams.y);
#endif
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
    Tags { "RenderType"="Spray" }
    Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#pragma glsl
#include "UnityCG.cginc"

sampler2D _PositionTex;
sampler2D _RotationTex;
float2 _ScaleParams;
float4 _BufferOffset;

struct v2f {
    float4 pos : SV_POSITION;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
    float2 depth : TEXCOORD0;
	#endif
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

v2f vert(appdata_base v)
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

    v2f o;
    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
    UNITY_TRANSFER_DEPTH(o.depth);
    return o;
}

fixed4 frag(v2f i) : SV_Target {
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
    } 
}

SubShader {
	Tags { "RenderType"="TransparentCutout" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
struct v2f {
    float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
    float2 depth : TEXCOORD1;
	#endif
};
uniform float4 _MainTex_ST;
v2f vert( appdata_base v ) {
    v2f o;
    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
    UNITY_TRANSFER_DEPTH(o.depth);
    return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
uniform fixed4 _Color;
fixed4 frag(v2f i) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	clip( texcol.a*_Color.a - _Cutoff );
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="TreeBark" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma glsl_no_auto_normalization
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "TerrainEngine.cginc"
struct v2f {
    float4 pos : SV_POSITION;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
	float2 depth : TEXCOORD0;
	#endif
};
v2f vert( appdata_full v ) {
    v2f o;
    TreeVertBark(v);
	
	o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
    UNITY_TRANSFER_DEPTH(o.depth);
    return o;
}
fixed4 frag(v2f i) : SV_Target {
	UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="TreeLeaf" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma glsl_no_auto_normalization
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "TerrainEngine.cginc"
struct v2f {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
	float2 depth : TEXCOORD1;
	#endif
};
v2f vert( appdata_full v ) {
    v2f o;
    TreeVertLeaf(v);
	
	o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
	o.uv = v.texcoord.xy;
    UNITY_TRANSFER_DEPTH(o.depth);
    return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag(v2f i) : SV_Target {
	half alpha = tex2D(_MainTex, i.uv).a;

	clip (alpha - _Cutoff);
	UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="TreeOpaque" }
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"
struct v2f {
	float4 pos : SV_POSITION;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
	float2 depth : TEXCOORD0;
	#endif
};
struct appdata {
    float4 vertex : POSITION;
    fixed4 color : COLOR;
};
v2f vert( appdata v ) {
	v2f o;
	TerrainAnimateTree(v.vertex, v.color.w);
	o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
    UNITY_TRANSFER_DEPTH(o.depth);
	return o;
}
fixed4 frag( v2f i ) : SV_Target {
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
} 

SubShader {
	Tags { "RenderType"="TreeTransparentCutout" }
	Pass {
		Cull Off
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"

struct v2f {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
	float2 depth : TEXCOORD1;
	#endif
};
struct appdata {
    float4 vertex : POSITION;
    fixed4 color : COLOR;
    float4 texcoord : TEXCOORD0;
};
v2f vert( appdata v ) {
	v2f o;
	TerrainAnimateTree(v.vertex, v.color.w);
	o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
	o.uv = v.texcoord.xy;
    UNITY_TRANSFER_DEPTH(o.depth);
	return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag( v2f i ) : SV_Target {
	half alpha = tex2D(_MainTex, i.uv).a;

	clip (alpha - _Cutoff);
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="TreeBillboard" }
	Pass {
		Cull Off
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"
struct v2f {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
	float2 depth : TEXCOORD1;
	#endif
};
v2f vert (appdata_tree_billboard v) {
	v2f o;
	TerrainBillboardTree(v.vertex, v.texcoord1.xy, v.texcoord.y);
	o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
	o.uv.x = v.texcoord.x;
	o.uv.y = v.texcoord.y > 0;
    UNITY_TRANSFER_DEPTH(o.depth);
	return o;
}
uniform sampler2D _MainTex;
fixed4 frag( v2f i ) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	clip( texcol.a - 0.001 );
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="GrassBillboard" }
	Pass {
		Cull Off		
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"
#pragma glsl_no_auto_normalization

struct v2f {
	float4 pos : SV_POSITION;
	fixed4 color : COLOR;
	float2 uv : TEXCOORD0;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
	float2 depth : TEXCOORD1;
	#endif
};

v2f vert (appdata_full v) {
	v2f o;
	WavingGrassBillboardVert (v);
	o.color = v.color;
	o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
	o.uv = v.texcoord.xy;
    UNITY_TRANSFER_DEPTH(o.depth);
	return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag( v2f i ) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	fixed alpha = texcol.a * i.color.a;
	clip( alpha - _Cutoff );
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}

SubShader {
	Tags { "RenderType"="Grass" }
	Pass {
		Cull Off
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"
struct v2f {
	float4 pos : SV_POSITION;
	fixed4 color : COLOR;
	float2 uv : TEXCOORD0;
	#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
	float2 depth : TEXCOORD1;
	#endif
};
v2f vert (appdata_full v) {
	v2f o;
	WavingGrassVert (v);
	o.color = v.color;
	o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
	o.uv = v.texcoord;
    UNITY_TRANSFER_DEPTH(o.depth);
	return o;
}
uniform sampler2D _MainTex;
uniform fixed _Cutoff;
fixed4 frag(v2f i) : SV_Target {
	fixed4 texcol = tex2D( _MainTex, i.uv );
	fixed alpha = texcol.a * i.color.a;
	clip( alpha - _Cutoff );
    UNITY_OUTPUT_DEPTH(i.depth);
}
ENDCG
	}
}
}
Fallback Off
}
