﻿

Shader "ShaderSuperb/Session13/24-BlitCopyDepth"
{
	Properties 
	{ 
		_MainTex ("Texture", any) = "" {} 
	}

	SubShader 
	{ 
		Pass 
		{
 			ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

			#include "UnityCG.cginc"

            //声明深度纹理
			UNITY_DECLARE_DEPTH_TEXTURE(_MainTex);

			uniform float4 _MainTex_ST;

            struct appdata_t 
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f 
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                //【基本立体视觉实例设置】 Step 1
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                //变量初始化宏
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                //【基本立体视觉实例设置】 Step 2
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //初始化立体视觉实例Index,unity_StereoEyeIndex
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                //采样深度纹理
                return SAMPLE_RAW_DEPTH_TEXTURE(_MainTex, i.texcoord);
            }
            ENDCG

		}
	}
	Fallback Off
}

