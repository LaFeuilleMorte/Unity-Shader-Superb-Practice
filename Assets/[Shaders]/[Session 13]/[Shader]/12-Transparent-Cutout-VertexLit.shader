

Shader "ShaderSuperb/Session13/12-Transparent-Cutout-VertexLit"
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Spec Color", Color) = (1,1,1,0)
		_Emission ("Emissive Color", Color) = (0,0,0,0)
		_Shininess ("Shininess", Range (0.1, 1)) = 0.7
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	}

	SubShader 
	{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		LOD 100
		
		// Non-lightmapped
		Pass 
		{
			Tags { "LightMode" = "Vertex" }
			Alphatest Greater [_Cutoff]
			AlphaToMask True
			ColorMask RGB
			Material 
			{
				Diffuse [_Color]
				Ambient [_Color]
				Shininess [_Shininess]
				Specular [_SpecColor]
				Emission [_Emission]	
			}
			Lighting On
			SeparateSpecular On
			SetTexture [_MainTex] 
			{
				Combine texture * primary DOUBLE, texture * primary 
			} 
		}
		
		// Lightmapped, encoded as dLDR
		Pass 
		{
			Tags { "LightMode" = "VertexLM" }
			Alphatest Greater [_Cutoff]
			AlphaToMask True
			ColorMask RGB
			
			BindChannels 
			{
				Bind "Vertex", vertex
				Bind "normal", normal
				Bind "texcoord1", texcoord0 // lightmap uses 2nd uv
				Bind "texcoord", texcoord1 // main uses 1st uv
			}
			SetTexture [unity_Lightmap] 
			{
				matrix [unity_LightmapMatrix]
				constantColor [_Color]
				combine texture * constant
			}
			SetTexture [_MainTex] 
			{
				combine texture * previous DOUBLE, texture * primary
			}
		}
		
		// Lightmapped, encoded as RGBM
		Pass 
		{
			Tags { "LightMode" = "VertexLMRGBM" }
			Alphatest Greater [_Cutoff]
			AlphaToMask True
			ColorMask RGB
			
			BindChannels 
			{
				Bind "Vertex", vertex
				Bind "normal", normal
				Bind "texcoord1", texcoord0 // lightmap uses 2nd uv
				Bind "texcoord1", texcoord1 // unused
				Bind "texcoord", texcoord2 // main uses 1st uv
			}
			
			SetTexture [unity_Lightmap] 
			{
				matrix [unity_LightmapMatrix]
				combine texture * texture alpha DOUBLE
			}

			SetTexture [unity_Lightmap] 
			{
				constantColor [_Color]
				combine previous * constant
			}

			SetTexture [_MainTex] 
			{
				combine texture * previous QUAD, texture * primary
			}
		}
		
		// Pass to render object as a shadow caster
		Pass 
		{
			Name "Caster"
			Tags { "LightMode" = "ShadowCaster" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
			#include "UnityCG.cginc"

			struct v2f 
			{ 
				//#define V2F_SHADOW_CASTER V2F_SHADOW_CASTER_NOPOS float4 pos : SV_POSITION
				//加阴影 part 1
				V2F_SHADOW_CASTER;
				float2  uv : TEXCOORD1;
				//For VR
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _MainTex_ST;

			v2f vert( appdata_base v )
			{
				v2f o;
				//使Shader功能访问实例ID。 它必须在顶点着色器的开头使用，并且对于片段着色器是可选的
				UNITY_SETUP_INSTANCE_ID(v);
				//For VR
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				//法线偏移阴影有助于减少自阴影伪像,类似于旧的TRANSFER_SHADOW_CASTER，但它需要v.normal才能存在。
				//加阴影 part 2
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;
			uniform fixed4 _Color;

			float4 frag( v2f i ) : SV_Target
			{
				fixed4 texcol = tex2D( _MainTex, i.uv );
				clip( texcol.a*_Color.a - _Cutoff );
				// #define SHADOW_CASTER_FRAGMENT(i) return UnityEncodeCubeShadowDepth ((length(i.vec) + unity_LightShadowBias.x) * _LightPositionRange.w);
				//加阴影 part 3
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG

		}
		
	}
}

