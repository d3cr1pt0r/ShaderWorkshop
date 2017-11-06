fixed3 GaussianBlur(sampler2D tex, float2 uv, float blur, fixed2 dir) {
	fixed3 sum = fixed3(0, 0, 0);

	sum += tex2D(tex, float2(uv.x - 4.0*blur*dir.x, uv.y - 4.0*blur*dir.y)) * 0.0162162162;
	sum += tex2D(tex, float2(uv.x - 3.0*blur*dir.x, uv.y - 3.0*blur*dir.y)) * 0.0540540541;
	sum += tex2D(tex, float2(uv.x - 2.0*blur*dir.x, uv.y - 2.0*blur*dir.y)) * 0.1216216216;
	sum += tex2D(tex, float2(uv.x - 1.0*blur*dir.x, uv.y - 1.0*blur*dir.y)) * 0.1945945946;

	sum += tex2D(tex, float2(uv.x, uv.y)) * 0.2270270270;

	sum += tex2D(tex, float2(uv.x + 1.0*blur*dir.x, uv.y + 1.0*blur*dir.y)) * 0.1945945946;
	sum += tex2D(tex, float2(uv.x + 2.0*blur*dir.x, uv.y + 2.0*blur*dir.y)) * 0.1216216216;
	sum += tex2D(tex, float2(uv.x + 3.0*blur*dir.x, uv.y + 3.0*blur*dir.y)) * 0.0540540541;
	sum += tex2D(tex, float2(uv.x + 4.0*blur*dir.x, uv.y + 4.0*blur*dir.y)) * 0.0162162162;

	return sum;
}