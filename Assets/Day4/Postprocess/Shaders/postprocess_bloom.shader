Shader "ShaderWorkshop/Postprocess/Bloom"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_Cutoff ("Cutoff", Range(0, 1)) = 0
		_BloomPower ("Bloom Power", Range(0, 2)) = 1
		_BlurResolution ("Blur Resolution", Float) = 2048
		_BlurRadius ("Blur Radius", Float) = 4
		_GrayscaleConversion ("Grayscale Conversion", Vector) = (0.3, 0.59, 0.11, 1)

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

			sampler2D _MainTex;
			fixed _Cutoff;
			fixed4 _GrayscaleConversion;

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
				fixed3 mainTex = tex2D(_MainTex, i.texcoord0).rgb;
				fixed grayscale = dot(mainTex, _GrayscaleConversion.rgb);

				mainTex = step(_Cutoff, grayscale) * mainTex;

				return fixed4(mainTex,1);
			}
			ENDCG
		}

		GrabPass { "_GrabTexCutoff" }

		Pass {
			ZWrite[_Zwrite]
			Ztest[_Ztest]
			Cull[_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Assets/Shaders/lib/Blur.cginc"

			sampler2D _GrabTexCutoff;
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
				fixed3 mainTex = GaussianBlur(_GrabTexCutoff, i.texcoord0, _BlurRadius/_BlurResolution, fixed2(1,0));

				return fixed4(mainTex,1);
			}
			ENDCG
		}

		GrabPass { "_GrabTexBlur" }

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
			sampler2D _GrabTexBlur;
			float _BlurResolution;
			float _BlurRadius;
			float _BloomPower;

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
				fixed3 mainTex = tex2D(_MainTex, fixed2(i.texcoord0.x, 1.0 - i.texcoord0.y)).rgb;
				fixed3 mainTex1 = GaussianBlur(_GrabTexBlur, i.texcoord0, _BlurRadius/_BlurResolution, fixed2(0,1));

				return fixed4(saturate(mainTex + mainTex1 * _BloomPower),1);
			}
			ENDCG
		}
	}
}
