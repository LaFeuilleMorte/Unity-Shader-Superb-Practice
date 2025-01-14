//https://docs.unity3d.com/Manual/SL-SurfaceShaderExamples.html

Shader "ShaderSuperb/Session3/03-Simple Texture"
{
	Properties
	{
		_MainTex("Main Texture" , 2D) = "grey"{}
	}

	SubShader 
	{
		Tags { "RenderType" = "Opaque" }

		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;

		struct Input 
		{
			//在surf程序中直接通过访问uv_MainTex来取得这张贴图当前需要计算的点的坐标值
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
