fixed3 TriplanarMapping(sampler2D tex, float3 vertexPosition, float3 vertexNormal, float texScale, float blendSharpness) {
	float3 xn = tex2D(tex, vertexPosition.zy * texScale);
	float3 yn = tex2D(tex, vertexPosition.xz * texScale);
	float3 zn = tex2D(tex, vertexPosition.xy * texScale);

	half3 blendWeightsWorld = pow(abs(vertexNormal), blendSharpness);
	blendWeightsWorld = blendWeightsWorld / (blendWeightsWorld.x + blendWeightsWorld.y + blendWeightsWorld.z);

	return xn * blendWeightsWorld.x + yn * blendWeightsWorld.y + zn * blendWeightsWorld.z;
}

fixed3 TriplanarMappingDisplaced(sampler2D tex, float3 vertexPosition, float3 vertexNormal, float texScale, float blendSharpness, float2 displacement, float displacementPower) {
	float3 xn = tex2D(tex, (vertexPosition.zy + displacement.xy * displacementPower) * texScale);
	float3 yn = tex2D(tex, (vertexPosition.xz + displacement.xy * displacementPower) * texScale);
	float3 zn = tex2D(tex, (vertexPosition.xy + displacement.xy * displacementPower) * texScale);

	half3 blendWeightsWorld = pow(abs(vertexNormal), blendSharpness);
	blendWeightsWorld = blendWeightsWorld / (blendWeightsWorld.x + blendWeightsWorld.y + blendWeightsWorld.z);

	return xn * blendWeightsWorld.x + yn * blendWeightsWorld.y + zn * blendWeightsWorld.z;
}