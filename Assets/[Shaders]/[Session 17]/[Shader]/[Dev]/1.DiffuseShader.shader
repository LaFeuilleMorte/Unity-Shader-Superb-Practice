﻿Shader "ShaderSuperb/Session17/Dev/1.DiffuseShader"
{
	Properties
	{
		_DiffuseTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,0,0,1)
		_Ambient("Ambient" ,Range(0, 1)) = 0.25
	}
	
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldNormal :TEXCOORD1;
			};


			sampler2D _DiffuseTex;
			float4 _DiffuseTex_ST;
			float4 _Color;
			float _Ambient;

			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normalDirection = normalize(i.worldNormal);

				float4 tex = tex2D(_DiffuseTex , i.uv);

				float NdotL = max (_Ambient , dot(normalDirection , _WorldSpaceLightPos0.xyz));

				float4 diffuseTerm = NdotL * _Color * tex * _LightColor0 ;

				return diffuseTerm;
			}
			ENDCG
		}
	}
}
