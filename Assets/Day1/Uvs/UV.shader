Shader "ShaderWorkshop/uv"
{
	Properties {
		
	}

	SubShader {
		Tags { "Queue" = "Geometry" }

		Pass {
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
			};

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = v.texcoord0;

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				return fixed4(i.texcoord0.x, 0, 0, 1);
			}
			ENDCG
		}
	}
}
