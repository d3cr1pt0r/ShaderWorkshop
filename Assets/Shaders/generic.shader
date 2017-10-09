Shader "ShaderWorkshop/generic"
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
			};

			struct fragmentInput {
				float4 vertex : SV_POSITION;
			};

			fragmentInput vert (vertexInput v) {
				fragmentInput o;

				// local vertex position multiplied by the MVP matrix
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}
			
			fixed4 frag (fragmentInput i) : SV_Target {
				return fixed4(1,1,1,1);
			}
			ENDCG
		}
	}
}
