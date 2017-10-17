Shader "ShaderWorkshop/LightingNM"
{
	Properties {
		_MainTex("Main Texture", 2D) = "white" {}
		_NormalTex ("Normal Texture", 2D) = "black" {}
		_CubeMap ("Cube Map", Cube) = "black" {}
		_AmbientColor ("Ambient Color", Color) = (1,1,1,1)
		_DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_RimColor ("Rim Color", Color) = (1,1,1,1)

		_SpecularMultiplier("Specular Multiplier", Float) = 1
		_SpecularShininess("Specular Shininess", Float) = 1

		_RimPower("Rim Power", Float) = 1
		_RimMultiplier("Rim Multiplier", Float) = 1
		_RimPassThrough("Rim PassThrough", Float) = 1

		_BumpDepth ("Bump Depth", Float) = 1
		_IBLIntensity ("IBL Intensity", Float) = 1
		_Reflectivity ("Reflectivity", Range(0, 1)) = 1
		_CubeMapMipLevel ("Cubemap Mip Level", Range(0, 15)) = 6

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
			#include "Lighting.cginc"

			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
				float2 texcoord0 : TEXCOORD0;
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;

				float3 worldNormal : TEXCOORD1;
				float3 worldTangent: TEXCOORD2;
				float3 worldPosition : TEXCOORD3;
			};

			sampler2D _MainTex;
			sampler2D _NormalTex;
			samplerCUBE _CubeMap;
			float4 _MainTex_ST;

			fixed4 _AmbientColor;
			fixed4 _DiffuseColor;
			fixed4 _SpecularColor;
			fixed4 _RimColor;

			half _SpecularMultiplier;
			half _SpecularShininess;
			half _RimPower;
			half _RimMultiplier;
			half _RimPassThrough;

			half _CubeMapMipLevel;
			half _Reflectivity;
			half _BumpDepth;
			half _IBLIntensity;

			half4 _GlobalLightDir;

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.texcoord0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.worldNormal = normalize(mul((float3x3)(unity_ObjectToWorld), v.normal.xyz));
				o.worldTangent = normalize(mul((float3x3)(unity_ObjectToWorld), v.tangent.xyz));
				o.worldPosition = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				// sample main texture
				fixed3 mainTex = tex2D(_MainTex, i.texcoord0).rgb;
				// sample normal map and convert it to (-1, 1) space
				float4 normalTex = tex2D(_NormalTex, i.texcoord0).rgba * 2.0 - 1.0;

				// calculate viewDirection, lightDirection and tangent normal needed for lighting
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition.xyz);
				float3 lightDirection = normalize(_GlobalLightDir.xyz);
				float3 tangentNormal = GetTangentNormal(normalTex, i.worldTangent, i.worldNormal, _BumpDepth);

				// sample cube map reflection texture
				fixed3 cubeTex = texCUBElod(_CubeMap, half4(lerp(i.worldNormal, tangentNormal, _Reflectivity), _CubeMapMipLevel)) + _IBLIntensity;

				// lighting
				fixed3 diffuseAmount = DiffuseLighting(i.worldNormal, lightDirection);
				fixed3 diffuseLight = diffuseAmount * _DiffuseColor.rgb;
				fixed3 specularLight = diffuseAmount.r * SpecularLighting(_SpecularColor.rgb, lightDirection, tangentNormal, viewDirection, _SpecularShininess, _SpecularMultiplier);
				fixed3 rimLight = RimLighting(viewDirection, lightDirection, i.worldNormal, _RimColor.rgb, _RimPower, _RimMultiplier, _RimPassThrough);

				// calculate final light
				half3 finalLight = ConvertToGamma(_AmbientColor.rgb + diffuseLight + specularLight + rimLight);

//				return fixed4(finalLight, 1.0);

				// main texture + light
				return fixed4(mainTex * finalLight * cubeTex, 1.0);
			}
			ENDCG
		}
	}
}
