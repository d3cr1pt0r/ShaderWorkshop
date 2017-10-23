Shader "ShaderWorkshop/VFX/shield"
{
	Properties {
		_MainTex("_MainTex", 2D) = "white" {}
		_DisplacementTex ("_DisplacementTex", 2D) = "white" {}

		_DisplacementTexScale("_DisplacementTexScale", Range(0, 2)) = 1
		_DisplacementPower ("_DisplacementPower", Range(0, 1)) = 1
		_Multiplier("_Multiplier", Range(1, 10)) = 1
		_TriplanarBlendSharpness("_TriplanarBlendSharpness", Float) = 1

		_RimColor ("_RimColor", Color) = (1,1,1,1)
		_RimPower("_RimPower", Float) = 1
		_RimMultiplier("_RimMultiplier", Float) = 1

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
				Blend One One

				ZWrite[_Zwrite]
				Ztest[_Ztest]
				Cull[_Cull]

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Assets/Shaders/lib/Lighting.cginc"
				#include "Assets/Shaders/lib/TriplanarMapping.cginc"

				sampler2D _MainTex;
				sampler2D _DisplacementTex;

				float4 _MainTex_ST;
				float4 __DisplacementTex_ST;

				fixed _Cutoff;
				half _DisplacementTexScale;
				half _DisplacementPower;
				half _Multiplier;

				fixed4 _RimColor;
				half _RimPower;
				half _RimMultiplier;

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
				fixed3 triplanarNormalTex = TriplanarMapping(_DisplacementTex, i.worldPosition, i.worldNormal, _DisplacementTexScale, _TriplanarBlendSharpness) * 2.0 - 1.0;
				fixed3 triplanarTex = TriplanarMappingDisplaced(_MainTex, i.localPosition, i.localNormal, 1.0f, _TriplanarBlendSharpness, triplanarNormalTex.xy, _DisplacementPower);

				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition.xyz);
				fixed3 rimLight = RimLighting(viewDirection, i.worldNormal, _RimColor, _RimPower, _RimMultiplier);
				
				return fixed4(triplanarTex * rimLight * _Multiplier, 1.0);
			}
			ENDCG
		}
	}
}
