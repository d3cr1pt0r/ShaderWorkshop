﻿Shader "ShaderWorkshop/TriplanarMapping"
{
	Properties {
		_MainTex("_MainTex", 2D) = "white" {}
		_TriplanarBlendSharpness("_TriplanarBlendSharpness", Float) = 1

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

		SubShader{
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

			Pass {
				ZWrite[_Zwrite]
				Ztest[_Ztest]
				Cull[_Cull]

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Assets/Shaders/lib/TriplanarMapping.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;

				half _TriplanarBlendSharpness;

			struct vertexInput {
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPosition : TEXCOORD2;
				float3 localNormal : TEXCOORD3;
				float3 localPosition : TEXCOORD4;
			};

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = TRANSFORM_TEX(v.texcoord0, _MainTex);

				o.worldPosition = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
				o.worldNormal = normalize(mul((float3x3)(unity_ObjectToWorld), v.normal.xyz));

				o.localPosition = v.vertex.xyz;
				o.localNormal = v.normal.xyz;

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				fixed3 triplanarTex = TriplanarMapping(_MainTex, i.localPosition, i.localNormal, 1.0f, _TriplanarBlendSharpness);
				
				return fixed4(triplanarTex, 1.0);
			}
			ENDCG
		}
	}
}
