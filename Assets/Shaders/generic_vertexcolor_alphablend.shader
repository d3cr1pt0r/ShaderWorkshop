Shader "ShaderWorkshop/generic_vertexcolor_alphablend"
{
	Properties {
		_TintColor ("Tint Color", Color) = (1,1,1,1)

		[Enum(Off,0,On,1)] _Zwrite("Zwrite", Float) = 0
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
		Tags { "Queue" = "Transparent" }

		Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            ZFail Replace
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
				fixed4 color : COLOR0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				fixed4 color : TEXCOORD0;
			};

			fixed4 _TintColor;

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);

				// transfer color
				o.color = v.color * _TintColor;

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				return i.color;
			}
			ENDCG
		}
	}
}
