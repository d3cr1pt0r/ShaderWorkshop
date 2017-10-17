Shader "ShaderWorkshop/VFX/Flame_2"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_DisplacementTex ("Displacement Texture", 2D) = "black" {}

		_Color1 ("Color 1", Color) = (1,1,1,1)
		_Color2 ("Color 2", Color) = (1,1,1,1)

		_Scale ("Displacement Scale", Range(0, 1)) = 1
		_GradientPower ("Gradient Power", Range(0, 5)) = 1
		_GradientOffset ("GradientOffset", Range(-1, 1)) = 0

		_SpeedX ("Speed X", Range(-8, 8)) = 0
		_SpeedY ("Speed Y", Range(-8, 8)) = 0

		_IntensityX ("Intensity X", Range(-4, 4)) = 1
		_IntensityY ("Intensity Y", Range(-4, 4)) = 1

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
				float2 texcoord0 : TEXCOORD0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
			};

			sampler2D _MainTex;
			sampler2D _DisplacementTex;

			float4 _MainTex_ST;
			float4 _DisplacementTex_ST;

			fixed4 _Color1;
			fixed4 _Color2;

			half _Scale;
			half _GradientPower;
			half _GradientOffset;
			half _SpeedX;
			half _SpeedY;
			half _IntensityX;
			half _IntensityY;
			
			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);

				// uv scaling
				float2 t0 = v.texcoord0.xy - float2(0.5, 0.5);
				t0.xy = t0.xy * half2(_Scale, _Scale);
				t0.xy = t0.xy + float2(0.5, 0.5);

				// apply tiling and offset
				o.texcoord0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.texcoord1 = TRANSFORM_TEX(t0.xy, _DisplacementTex) + half2(0, _Time.x * _SpeedX);
				o.texcoord2 = TRANSFORM_TEX(t0.xy, _DisplacementTex) + half2(0, _Time.x * _SpeedY);

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				half2 displacementTex1 = tex2D(_DisplacementTex, i.texcoord1).xy;
				half2 displacementTex2 = tex2D(_DisplacementTex, i.texcoord2).xy;

				displacementTex1.xy = (displacementTex1.xy * 2.0 - 1.0) * half2(_IntensityX, _IntensityY);
				displacementTex2.xy = (displacementTex2.xy * 2.0 - 1.0) * half2(_IntensityX, _IntensityY);

				fixed mask =  tex2D(_MainTex, i.texcoord0.xy).b;
				fixed3 mainTex = tex2D(_MainTex, i.texcoord0.xy + (displacementTex1.xy + displacementTex2.xy) * mask * pow(i.texcoord0.y + _GradientOffset, _GradientPower)).rgb;

				//return pow(i.texcoord0.y + _GradientOffset, _GradientPower);

				return fixed4((_Color1.rgb * mainTex.r + _Color2.rgb * mainTex.g) * mask, 1.0);
			}
			ENDCG
		}
	}
}
