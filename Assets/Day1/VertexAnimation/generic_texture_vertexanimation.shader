// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderWorkshop/generic_texture_vertexanimation"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (1,1,1,1)

		_SpeedX ("Speed X", Range(0, 10)) =  10
		_FrequencyX ("Frequency X", Range(0, 10)) =  10
		_AmplitudeX ("Amplitude X", Range(0, 10)) = 0

		_SpeedY ("Speed Y", Range(0, 10)) =  10
		_FrequencyY ("Frequency Y", Range(0, 10)) =  10
		_AmplitudeY ("Amplitude Y", Range(0, 10)) = 0

		_SpeedZ ("Speed Z", Range(0, 10)) =  10
		_FrequencyZ ("Frequency Z", Range(0, 10)) =  10
		_AmplitudeZ ("Amplitude Z", Range(0, 10)) = 0

		_Multiplier ("Multiplier", Range(0, 1)) = 1

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
				float3 normal : NORMAL;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fixed4 _TintColor;

			float _SpeedX;
			float _SpeedY;
			float _SpeedZ;

			float _FrequencyX;
			float _FrequencyY;
			float _FrequencyZ;

			float _AmplitudeX;
			float _AmplitudeY;
			float _AmplitudeZ;

			float _Multiplier;

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				float m1 = sin((v.vertex.x + _Time.x * _SpeedX) * _FrequencyX) * _AmplitudeX;
				float m2 = cos((v.vertex.y + _Time.x * _SpeedY) * _FrequencyY) * _AmplitudeY;
				float m3 = sin((v.vertex.z + _Time.x * _SpeedZ) * _FrequencyZ) * _AmplitudeZ;

				v.vertex.xyz += v.normal.xyz * (m1 + m2 + m3) * _Multiplier;

				o.vertex = UnityObjectToClipPos(float4(v.vertex.xyz, 1.0));

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
