
Shader "Hidden/Nature/Tree Creator Bark Optimized" 
{

	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
		_BumpSpecMap ("Normalmap (GA) Spec (R)", 2D) = "bump" {}
		_TranslucencyMap ("Trans (RGB) Gloss(A)", 2D) = "white" {}
		
		// These are here only to provide default values
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		[HideInInspector] _TreeInstanceColor ("TreeInstanceColor", Vector) = (1,1,1,1)
		[HideInInspector] _TreeInstanceScale ("TreeInstanceScale", Vector) = (1,1,1,1)
		[HideInInspector] _SquashAmount ("Squash", Float) = 1
	}

	SubShader 
	{ 
		Tags { "IgnoreProjector"="True" "RenderType"="TreeBark" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf BlinnPhong vertex:TreeVertBark addshadow nolightmap
		#include "UnityBuiltin3xTreeLibrary.cginc"

		sampler2D _MainTex;
		sampler2D _BumpSpecMap;
		sampler2D _TranslucencyMap;

		struct Input 
		{
			float2 uv_MainTex;
			fixed4 color : COLOR;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb * IN.color.rgb * IN.color.a;
			
			fixed4 trngls = tex2D (_TranslucencyMap, IN.uv_MainTex);
			o.Gloss = trngls.a * _Color.r;
			o.Alpha = c.a;
			
			half4 norspc = tex2D (_BumpSpecMap, IN.uv_MainTex);
			o.Specular = norspc.r;
			o.Normal = UnpackNormalDXT5nm(norspc);
		}
		ENDCG
	}

	Dependency "BillboardShader" = "Hidden/Nature/Tree Creator Bark Rendertex"
}
