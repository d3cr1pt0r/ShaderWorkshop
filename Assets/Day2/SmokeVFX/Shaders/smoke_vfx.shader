Shader "ShaderWorkshop/VFX/smoke_vfx"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "black" {}
		_DisplacementTex ("Displacement Texture", 2D) = "black" {}
		_TintColor ("Tint Color", Color) = (1,1,1,1)

		_Parameters1 ("Parameters 1", Vector) = (0,0,0,0)
		_Parameters2 ("Parameters 2", Vector) = (0,0,0,0)

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

		Pass {
			Blend SrcAlpha OneMinusSrcAlpha

			ZWrite[_Zwrite]
			Ztest[_Ztest]
			Cull[_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct vertexInput {
				float4 vertex : POSITION;
				fixed4 color0 : COLOR0;
				float2 texcoord0 : TEXCOORD0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				fixed4 color0 : TEXCOORD0;
				float2 texcoord0 : TEXCOORD1;
				float2 texcoord1 : TEXCOORD2;
				float2 texcoord2 : TEXCOORD3;
			};

			sampler2D _MainTex;
			sampler2D _DisplacementTex;

			float4 _MainTex_ST;
			float4 _DisplacementTex_ST;

			fixed4 _TintColor;
			half4 _Parameters1;
			half4 _Parameters2;

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color0 = v.color0 * _TintColor;
				o.texcoord0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.texcoord1 = TRANSFORM_TEX(v.texcoord0, _DisplacementTex) + frac(fixed2(_Time.x * _Parameters1.x, _Time.x * _Parameters1.y));
				o.texcoord2 = TRANSFORM_TEX(v.texcoord0, _DisplacementTex) + frac(fixed2(_Time.x * _Parameters2.x, _Time.x * _Parameters2.y));

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				fixed mask = tex2D(_MainTex, i.texcoord0).rgb;
				fixed3 displacementTex1 = (tex2D(_DisplacementTex, i.texcoord1).rgb * 2.0 - 1.0) * mask;
				fixed3 displacementTex2 = (tex2D(_DisplacementTex, i.texcoord1).rgb * 2.0 - 1.0) * mask;
				fixed3 mainTex = tex2D(_MainTex, i.texcoord0 + fixed2(displacementTex1.r * _Parameters1.z, displacementTex1.b * _Parameters1.w) + fixed2(displacementTex2.r * _Parameters2.z, displacementTex2.b * _Parameters2.w)).rgb;
				fixed t = mainTex.r * mainTex.g * 2.0;

				return fixed4(t * i.color0.rgb, mainTex.b * i.color0.a);
			}
			ENDCG
		}
	}
}
