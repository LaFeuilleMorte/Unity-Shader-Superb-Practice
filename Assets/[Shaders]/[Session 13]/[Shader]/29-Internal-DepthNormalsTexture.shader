

Shader "ShaderSuperb/Session13/29-Internal-DepthNormalsTexture"
{
	Properties 
	{
		_MainTex ("", 2D) = "white" {}
		_Cutoff ("", Float) = 0.5
		_Color ("", Color) = (1,1,1,1)
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct v2f 
			{
			    float4 pos : SV_POSITION;
			    float4 nz : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_base v ) 
			{
			    v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			    o.pos = UnityObjectToClipPos(v.vertex);
			    //计算法线视角方向
			    o.nz.xyz = COMPUTE_VIEW_NORMAL;
			    //计算深度值
			    o.nz.w = COMPUTE_DEPTH_01;
			    return o;
			}
			fixed4 frag(v2f i) : SV_Target 
			{
				//Unity将法线编码到R和G通道里，而深度编码到B和A通道里。
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}
			ENDCG
		}
	}

	SubShader 
	{
		Tags { "RenderType"="TransparentCutout" }
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct v2f 
			{
			    float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			    float4 nz : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			uniform float4 _MainTex_ST;
			v2f vert( appdata_base v ) 
			{
			    v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			    o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			    o.nz.xyz = COMPUTE_VIEW_NORMAL;
			    o.nz.w = COMPUTE_DEPTH_01;
			    return o;
			}
			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;
			uniform fixed4 _Color;
			fixed4 frag(v2f i) : SV_Target 
			{
				fixed4 texcol = tex2D( _MainTex, i.uv );
				clip( texcol.a*_Color.a - _Cutoff );
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}
			ENDCG
		}
	}

	SubShader 
	{
		Tags { "RenderType"="TreeBark" }
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityBuiltin3xTreeLibrary.cginc"
			struct v2f 
			{
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
				float4 nz : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v ) 
			{
			    v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				//树皮顶点计算帮助函数
			    TreeVertBark(v);
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
			    o.nz.xyz = COMPUTE_VIEW_NORMAL;
			    o.nz.w = COMPUTE_DEPTH_01;
			    return o;
			}

			fixed4 frag( v2f i ) : SV_Target 
			{
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}
			ENDCG
		}
	}

	SubShader 
	{
		Tags { "RenderType"="TreeLeaf" }
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityBuiltin3xTreeLibrary.cginc"

			struct v2f 
			{
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
				float4 nz : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert( appdata_full v ) 
			{
			    v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				//树叶顶点计算帮助函数
			    TreeVertLeaf(v);
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
			    o.nz.xyz = COMPUTE_VIEW_NORMAL;
			    o.nz.w = COMPUTE_DEPTH_01;
			    return o;
			}

			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;

			fixed4 frag( v2f i ) : SV_Target 
			{
				half alpha = tex2D(_MainTex, i.uv).a;

				clip (alpha - _Cutoff);
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}

			ENDCG
		}
	}

	SubShader 
	{
		Tags { "RenderType"="TreeOpaque" "DisableBatching"="True" }
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "TerrainEngine.cginc"

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float4 nz : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			struct appdata 
			{
			    float4 vertex : POSITION;
			    float3 normal : NORMAL;
			    fixed4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			v2f vert( appdata v ) 
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				TerrainAnimateTree(v.vertex, v.color.w);
				o.pos = UnityObjectToClipPos(v.vertex);
			    o.nz.xyz = COMPUTE_VIEW_NORMAL;
			    o.nz.w = COMPUTE_DEPTH_01;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target 
			{
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}

			ENDCG
		}
	} 

	SubShader 
	{
		Tags { "RenderType"="TreeTransparentCutout" "DisableBatching"="True" }
		Pass 
		{
			Cull Back
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "TerrainEngine.cginc"

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 nz : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			struct appdata 
			{
			    float4 vertex : POSITION;
			    float3 normal : NORMAL;
			    fixed4 color : COLOR;
			    float4 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			v2f vert( appdata v ) 
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				TerrainAnimateTree(v.vertex, v.color.w);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
			    o.nz.xyz = COMPUTE_VIEW_NORMAL;
			    o.nz.w = COMPUTE_DEPTH_01;
				return o;
			}
			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;
			fixed4 frag(v2f i) : SV_Target 
			{
				half alpha = tex2D(_MainTex, i.uv).a;

				clip (alpha - _Cutoff);
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}
			ENDCG
		}

		Pass 
		{
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "TerrainEngine.cginc"

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 nz : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			struct appdata 
			{
			    float4 vertex : POSITION;
			    float3 normal : NORMAL;
			    fixed4 color : COLOR;
			    float4 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata v ) 
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				//terrain下树顶点的运动帮助函数
				TerrainAnimateTree(v.vertex, v.color.w);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
			    o.nz.xyz = -COMPUTE_VIEW_NORMAL;
			    o.nz.w = COMPUTE_DEPTH_01;
				return o;
			}
			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;
			fixed4 frag(v2f i) : SV_Target 
			{
				fixed4 texcol = tex2D( _MainTex, i.uv );
				clip( texcol.a - _Cutoff );
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}
			ENDCG
		}

	}

	SubShader 
	{
		Tags { "RenderType"="TreeBillboard" }
		Pass 
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "TerrainEngine.cginc"
			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 nz : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert (appdata_tree_billboard v) 
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				//billboard版的树帮助函数
				TerrainBillboardTree(v.vertex, v.texcoord1.xy, v.texcoord.y);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.x = v.texcoord.x;
				o.uv.y = v.texcoord.y > 0;
			    o.nz.xyz = float3(0,0,1);
			    o.nz.w = COMPUTE_DEPTH_01;
				return o;
			}
			uniform sampler2D _MainTex;
			fixed4 frag(v2f i) : SV_Target 
			{
				fixed4 texcol = tex2D( _MainTex, i.uv );
				clip( texcol.a - 0.001 );
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}
			ENDCG
		}
	}

	SubShader 
	{
		Tags { "RenderType"="GrassBillboard" }
		Pass 
		{
			Cull Off		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "TerrainEngine.cginc"

			struct v2f 
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
				float2 uv : TEXCOORD0;
				float4 nz : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert (appdata_full v) 
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				//wave草地Billboard顶点帮助函数
				WavingGrassBillboardVert (v);
				o.color = v.color;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
			    o.nz.xyz = COMPUTE_VIEW_NORMAL;
			    o.nz.w = COMPUTE_DEPTH_01;
				return o;
			}

			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;
			fixed4 frag(v2f i) : SV_Target 
			{
				fixed4 texcol = tex2D( _MainTex, i.uv );
				fixed alpha = texcol.a * i.color.a;
				clip( alpha - _Cutoff );
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}
			ENDCG
		}
	}

	SubShader 
	{
		Tags { "RenderType"="Grass" }
		Pass 
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "TerrainEngine.cginc"
			struct v2f 
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
				float2 uv : TEXCOORD0;
				float4 nz : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert (appdata_full v) 
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				//草地顶点帮助函数
				WavingGrassVert (v);
				o.color = v.color;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
			    o.nz.xyz = COMPUTE_VIEW_NORMAL;
			    o.nz.w = COMPUTE_DEPTH_01;
				return o;
			}
			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;
			fixed4 frag(v2f i) : SV_Target 
			{
				fixed4 texcol = tex2D( _MainTex, i.uv );
				fixed alpha = texcol.a * i.color.a;
				clip( alpha - _Cutoff );
				return EncodeDepthNormal (i.nz.w, i.nz.xyz);
			}
			ENDCG
		}
	}
	Fallback Off
}

