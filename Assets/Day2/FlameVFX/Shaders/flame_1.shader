Shader "ShaderWorkshop/VFX/Flame_1"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_DisplacementTex ("Displacement Texture", 2D) = "black" {}
		_MaskTex ("Mask Texture", 2D) = "white" {}

		_TintColor ("Tint Color", Color) = (1,1,1,1)

		_Scale1 ("Displacement Scale 1", Range(0, 10)) = 1
		_Scale2 ("Displacement Scale 2", Range(0, 10)) = 1

		_Speed1X ("Speed 1 X", Range(-10, 10)) = 0
		_Speed1Y ("Speed 1 Y", Range(-10, 10)) = 0

		_Speed2X ("Speed 2 X", Range(-10, 10)) = 0
		_Speed2Y ("Speed 2 Y", Range(-10, 10)) = 0

		_Intensity1X ("Intensity 1 X", Range(0, 4)) = 1
		_Intensity1Y ("Intensity 1 Y", Range(0, 4)) = 1

		_Intensity2X ("Intensity 2 X", Range(0, 4)) = 1
		_Intensity2Y ("Intensity 2 Y", Range(0, 4)) = 1

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
			Blend One One

			ZWrite [_Zwrite]
			Ztest [_Ztest]
        	Cull [_Cull]

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct vertexInput {
				float4 vertex : POSITION;
				half2 texcoord0 : TEXCOORD0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				half2 texcoord0 : TEXCOORD0;
				half2 texcoord1 : TEXCOORD1;
				half2 texcoord2 : TEXCOORD2;
			};

			sampler2D _MainTex;
			sampler2D _DisplacementTex;
			sampler2D _MaskTex;

			half4 _MainTex_ST;
			half4 _DisplacementTex_ST;

			fixed4 _TintColor;

			half _Scale1;
			half _Scale2;
			half _Speed1X;
			half _Speed1Y;
			half _Speed2X;
			half _Speed2Y;
			half _Intensity1X;
			half _Intensity1Y;
			half _Intensity2X;
			half _Intensity2Y;

			half2 scaleUv(half2 uv, half scale) {
				uv.xy -= half2(0.5, 0.5);
				uv.xy *= half2(scale, scale);
				uv.xy += half2(0.5, 0.5);

				return uv;
			}

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);

				// uv scaling
				half2 t0 = scaleUv(v.texcoord0, _Scale1);
				half2 t1 = scaleUv(v.texcoord0, _Scale2);

				// apply tiling and offset
				o.texcoord0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.texcoord1 = TRANSFORM_TEX(t0.xy, _DisplacementTex) + half2(_Time.x * _Speed1X, _Time.x * _Speed1Y);
				o.texcoord2 = TRANSFORM_TEX(t1.xy, _DisplacementTex) + half2(_Time.x * _Speed2X, _Time.x * _Speed2Y);

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				half mask = 1.0 - tex2D(_MaskTex, i.texcoord0.xy).a;
				half2 displacementTex1 = tex2D(_DisplacementTex, i.texcoord1).rg * half2(2.0, 2.0) - half2(1.0, 1.0);
				half2 displacementTex2 = tex2D(_DisplacementTex, i.texcoord2).rg * half2(2.0, 2.0) - half2(1.0, 1.0);

				displacementTex1 *= half2(_Intensity1X, _Intensity1Y) * mask;
				displacementTex2 *= half2(_Intensity2X, _Intensity2Y) * mask;

				fixed3 mainTex = tex2D(_MainTex, i.texcoord0.xy + displacementTex1.xy + displacementTex2.xy).rgb;

				return fixed4(mainTex.rgb * _TintColor.rgb, 1.0);
			}
			ENDCG
		}
	}
}
