
Shader "ShaderSuperb/Session15/RGBA-Other/RGBA-22-Pattern Movement Mask"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_SourceNewTex_1("_SourceNewTex_1(RGB)", 2D) = "white" { }
		_NewTex_1("NewTex_1(RGB)", 2D) = "white" { }
		_NewTex_2("NewTex_2(RGB)", 2D) = "white" { }
		_PatternMovementMask_PosX_1("_PatternMovementMask_PosX_1", Range(-2, 2)) = 1
		_PatternMovementMask_PosY_1("_PatternMovementMask_PosY_1", Range(-2, 2)) = 1
		_PatternMovementMask_Speed_1("_PatternMovementMask_Speed_1", Range(1, 16)) = 1
		_SpriteFade("SpriteFade", Range(0, 1)) = 1.0

		// required for UI.Mask
		[HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
		[HideInInspector]_Stencil("Stencil ID", Float) = 0
		[HideInInspector]_StencilOp("Stencil Operation", Float) = 0
		[HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
		[HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
		[HideInInspector]_ColorMask("Color Mask", Float) = 15

	}

	SubShader
	{

		Tags {"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True"}
		ZWrite Off Blend SrcAlpha OneMinusSrcAlpha Cull Off

		// required for UI.Mask
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct appdata_t{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 texcoord  : TEXCOORD0;
				float4 vertex   : SV_POSITION;
				float4 color    : COLOR;
			};

			sampler2D _MainTex;
			float _SpriteFade;
			sampler2D _SourceNewTex_1;
			sampler2D _NewTex_1;
			sampler2D _NewTex_2;
			float _PatternMovementMask_PosX_1;
			float _PatternMovementMask_PosY_1;
			float _PatternMovementMask_Speed_1;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color;
				return OUT;
			}


			float4 PatternMovementMask(float2 uv, sampler2D source, float4 rgba, float4 mask, float posx, float posy, float speed)
			{
				float t = _Time * 20 * speed;
				uv = fmod(abs(uv+float2(posx*t, posy*t)),1);
				float4 result = tex2D(source, uv);
				result.a = result.a * rgba.a * mask.r;
				return result;
			}
			float4 frag (v2f i) : COLOR
			{
				float4 NewTex_1 = tex2D(_NewTex_1, i.texcoord);
				float4 NewTex_2 = tex2D(_NewTex_2, i.texcoord);
				float4 _PatternMovementMask_1 = PatternMovementMask(i.texcoord,_SourceNewTex_1,NewTex_1,NewTex_2,_PatternMovementMask_PosX_1,_PatternMovementMask_PosY_1,_PatternMovementMask_Speed_1);
				float4 FinalResult = _PatternMovementMask_1;
				FinalResult.rgb *= i.color.rgb;
				FinalResult.a = FinalResult.a * _SpriteFade * i.color.a;
				return FinalResult;
			}

			ENDCG
		}
	}
	Fallback "Sprites/Default"
}
