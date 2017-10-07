Shader "ShaderWorkshop/generic_texture"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (1,1,1,1)

		[Enum(Off,0,On,1)] _Zwrite("Zwrite", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _Ztest("Ztest", Float) = 4
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2
        _ColorMask ("Color Mask", Float) = 15

        _Stencil ("Stencil ID", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 8
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
	}

	SubShader {
		Tags { "Queue" = "Geometry" }

		Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

		Pass {
			ZWrite [_Zwrite]
			Ztest [_Ztest]
        	Cull [_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct vertexInput {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fixed4 _TintColor;
			
			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);

				// apply tiling and offset
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				fixed3 mainTex = tex2D(_MainTex, i.uv).rgb;

				return fixed4(mainTex.rgb * _TintColor.rgb, 1.0);
			}
			ENDCG
		}
	}
}
