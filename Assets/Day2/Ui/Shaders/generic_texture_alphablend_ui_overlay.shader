﻿Shader "ShaderWorkshop/generic_texture_alphablend_ui_overlay"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_AlphaTex ("Alpha Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "black" {}

		_Color("Tint Color", Color) = (1,1,1,1)
		_Power ("Power", Range(0, 1)) = 0

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
		Tags { "Queue" = "Transparent" }

		Stencil	{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOpPass]
			Fail[_StencilOpFail]
			ZFail[_StencilOpZFail]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Pass {
			Blend SrcAlpha OneMinusSrcAlpha

			ZWrite [_Zwrite]
			Ztest [_Ztest]
        	Cull [_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct vertexInput {
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : COLOR0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			sampler2D _MaskTex;

			float4 _MainTex_ST;
			float4 _AlphaTex_ST;
			float4 _MaskTex_ST;
			fixed _Power;

			fixed4 _Color;
			
			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);

#ifdef UNITY_HALF_TEXEL_OFFSET
				o.vertex.xy += (_ScreenParams.zw - 1.0) * float2(-1.0, 1.0);
#endif

				// apply tiling and offset
				o.texcoord0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.texcoord1 = TRANSFORM_TEX(v.texcoord1.xy, _MaskTex);

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				fixed3 mainTex = tex2D(_MainTex, i.texcoord0).rgb;
				fixed alphaTex = tex2D(_AlphaTex, i.texcoord0).a;
				fixed maskTex = tex2D(_MaskTex, i.texcoord1).a * _Power;

				return fixed4(mainTex.rgb * _Color.rgb + maskTex, alphaTex * _Color.a);
			}
			ENDCG
		}
	}
}
