#define ConvertToGamma(_v_) pow(_v_, 0.454545);

fixed3 DiffuseLighting(fixed3 normalWorld, fixed3 lightDirection) {
	fixed diffuseOut = max(0.0, dot(normalWorld, lightDirection));

	return fixed3(diffuseOut, diffuseOut, diffuseOut);
}

fixed3 RimLighting(fixed3 viewDirection, fixed3 lightDirection, fixed3 normalWorld, fixed3 rimColor, float rimPower, float rimMultiplier, float rimPassThrough) {
	fixed diffuseAmount = max(0.0, dot(normalWorld, lightDirection));
	fixed rimAmount = 1.0 - max(0.0, dot(viewDirection, normalWorld));
	fixed3 rimOut = lerp(0.0f, rimColor * pow(rimAmount, rimPower) * rimMultiplier, saturate(diffuseAmount + rimPassThrough));

	return rimOut;
}

fixed3 RimLighting2(fixed diffuseAmount, fixed3 viewDirection, fixed3 normalWorld, fixed3 rimColor, half rimPower, half rimMultiplier, fixed rimPassThrough) {
	fixed rimAmount = 1.0 - max(0.0, dot(viewDirection, normalWorld));
	fixed3 rimOut = lerp(fixed3(0, 0, 0), saturate(rimColor * pow(rimAmount, rimPower) * rimMultiplier), diffuseAmount + rimPassThrough);

	return rimOut;
}

fixed3 SpecularLighting(fixed3 specularColor, fixed3 lightDirection, fixed3 normalWorld, fixed3 viewDirection, float specularShininess, float specularMultiplier) {
	float3 specularOut = specularColor * pow(max(0.0, dot(reflect(-normalize(lightDirection), normalWorld), viewDirection)), specularShininess) * specularMultiplier;

	return specularOut;
}

float3 PointLighting(half3 vertexPos, half4 pointLightPosAndRadius, fixed3 pointLightColor, fixed3 normalWorld, half intensity) {
	float3 vertexToLightSource = pointLightPosAndRadius.xyz - vertexPos;
	fixed3 lightDirection = normalize(vertexToLightSource);
	float3 d = vertexToLightSource * pointLightPosAndRadius.w;
	float atten = saturate(1 - dot(d, d));

	return atten * intensity * pointLightColor.rgb * max(0.0, dot(normalWorld, lightDirection));
}

float3 GetTangentNormal(float4 normalTexture, float3 worldTangent, float3 worldNormal, float bumpDepth) {
	float3 biTangent = cross(worldTangent, worldNormal);

	float3 localCoords = float3(normalTexture.ag * 2.0 - 1.0, 0.0);
	localCoords.z = bumpDepth;

	float3x3 local2WorldTranspose = float3x3(
		worldTangent,
		biTangent,
		worldNormal
	);

	return normalize(mul(localCoords, local2WorldTranspose));
}