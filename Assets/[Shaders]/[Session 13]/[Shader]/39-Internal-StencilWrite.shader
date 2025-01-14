﻿

Shader "ShaderSuperb/Session13/39-Internal-StencilWrite"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#include "UnityCG.cginc"

			struct a2v 
			{
				float4 pos : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID// Use this in the vertex Shader input/output structure to define an instance ID. See SV_InstanceID for more information.
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert (a2v v) 
			{ 
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.pos); 
				return o;
			}
			fixed4 frag () : SV_Target 
			{ 
				return fixed4(0,0,0,0); 
			}
			ENDCG
		}
	}
	Fallback Off
}

