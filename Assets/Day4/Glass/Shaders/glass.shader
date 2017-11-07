Shader "ShaderWorkshop/VFX/Glass"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_AlphaTex ("Alpha Texture", 2D) = "white" {}
		_NormalTex ("Normal Textrure", 2D) = "black" {}

		_TintColor ("Tint Color", Color) = (1,1,1,1)

		_RefractionPower ("Refraction Power", Range(0, 0.2)) = 0

		[Enum(Off,0,On,1)] _Zwrite("Zwrite", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _Ztest("Ztest", Float) = 4
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2
		_ColorMask("Color Mask", Float) = 15

		_Stencil("Stencil ID", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Int) = 8
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilOpPass("Stencil Operation Pass", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilOpFail("Stencil Operation Fail", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilOpZFail("Stencil Operation ZFail", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255
	}

	SubShader {
		Tags{ "Queue" = "Geometry" }

		Stencil	{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOpPass]
			Fail[_StencilOpFail]
			ZFail[_StencilOpZFail]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		GrabPass { "_GrabTex" }

		Pass {
			ZWrite[_Zwrite]
			Ztest[_Ztest]
			Cull[_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			sampler2D _NormalTex;
			sampler2D _GrabTex;

			fixed4 _TintColor;
			half _RefractionPower;

			struct vertexInput {
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
			};

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = v.texcoord0;
				o.texcoord1 = o.vertex;

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				float2 screen_space_uv = i.texcoord1.xy / i.texcoord1.w;
				screen_space_uv.xy = screen_space_uv.xy * 0.5 + 0.5;
				screen_space_uv.y = 1.0 - screen_space_uv.y;

				fixed3 mainTex = tex2D(_MainTex, i.texcoord0).rgb * _TintColor.rgb;
				fixed alphaTex = tex2D(_AlphaTex, i.texcoord0).a * _TintColor.a;
				fixed4 normalTex = tex2D(_NormalTex, i.texcoord0) * 2.0 - 1.0;
				fixed3 grabTex = tex2D(_GrabTex, screen_space_uv + normalTex.xy * _RefractionPower).rgb;

				fixed3 mix = mainTex.rgb * alphaTex + grabTex.rgb * (1.0 - alphaTex);

				return fixed4(mix, 1.0);
			}
			ENDCG
		}
	}
}
