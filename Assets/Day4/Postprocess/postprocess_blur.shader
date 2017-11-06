Shader "ShaderWorkshop/Postprocess/Blur"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_BlurResolution ("Blur Resolution", Float) = 2048
		_BlurRadius ("Blur Radius", Float) = 4

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
			ZWrite[_Zwrite]
			Ztest[_Ztest]
			Cull[_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Assets/Shaders/lib/Blur.cginc"

			sampler2D _MainTex;
			float _BlurResolution;
			float _BlurRadius;

			struct vertexInput {
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = v.texcoord0;

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				fixed3 mainTex = GaussianBlur(_MainTex, i.texcoord0, _BlurRadius/_BlurResolution, fixed2(1,0));
				return fixed4(mainTex, 1.0);
			}
			ENDCG
		}

		GrabPass{ "_GrabTex" }

		Pass {
			ZWrite[_Zwrite]
			Ztest[_Ztest]
			Cull[_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Assets/Shaders/lib/Blur.cginc"

			sampler2D _GrabTex;
			float _BlurResolution;
			float _BlurRadius;

			struct vertexInput {
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = v.texcoord0;
				o.texcoord0.y = 1.0 - o.texcoord0.y;

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				fixed3 mainTex = GaussianBlur(_GrabTex, i.texcoord0, _BlurRadius/_BlurResolution, fixed2(0,1));
				return fixed4(mainTex, 1.0);
			}
			ENDCG
		}
	}
}
