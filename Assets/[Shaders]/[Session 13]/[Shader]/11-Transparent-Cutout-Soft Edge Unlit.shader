﻿
/*
Renders doubled sides objects without lighting. Useful for
grass, trees or foliage.

This shader renders two passes for all geometry, one
for opaque parts and one with semitransparent details.

This makes it possible to render transparent objects
like grass without them being sorted by depth.
*/

Shader "ShaderSuperb/Session13/11-Transparent-Cutout-Soft Edge Unlit"
{
	Properties 
	{
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
		_Cutoff ("Base Alpha cutoff", Range (0,.9)) = .5
	}

	SubShader 
	{
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" }

		Lighting off
		
		// Render both front and back facing polygons.
		Cull Off
		
		// first pass:
		//   render any pixels that are more than [_Cutoff] opaque
		Pass 
		{  
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//【Fog Apply】Step 1. Needed for fog variation to be compiled.
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata_t 
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			 	//【Fog Apply】Step 2. Used to pass fog amount around number should be a free texcoord.
				UNITY_FOG_COORDS(1)
				//【Maro for VR】.Step 1. https://docs.unity3d.com/Manual/SinglePassStereoRenderingHoloLens.html
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;
			
			v2f vert (appdata_t v)
			{
				v2f o; 
				//使用此功能可以使Shader功能访问实例ID。 它必须在顶点着色器的开头使用，并且对于片段着色器是可选的。
				UNITY_SETUP_INSTANCE_ID(v);
				//【Maro for VR】.Step 2. https://docs.unity3d.com/Manual/SinglePassStereoRenderingHoloLens.html
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				//【Fog Apply】Step 3. Compute fog amount from clip space position.
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 _Color;
			fixed4 frag (v2f i) : SV_Target
			{
				half4 col = _Color * tex2D(_MainTex, i.texcoord);
				clip(col.a - _Cutoff);
				//【Fog Apply】Step 4.Apply fog (additive pass are automatically handled)
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}

		// Second pass:
		//   render the semitransparent details.
		Pass 
		{
			Tags { "RequireOption" = "SoftVegetation" }
			
			// Dont write to the depth buffer
			ZWrite off
			
			// Set up alpha blending
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata_t 
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cutoff;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 _Color;
			fixed4 frag (v2f i) : SV_Target
			{
				half4 col = _Color * tex2D(_MainTex, i.texcoord);
				clip(-(col.a - _Cutoff));
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}

