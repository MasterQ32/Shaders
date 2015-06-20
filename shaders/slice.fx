
float4x4 matWorld;
float4x4 matWorldViewProj;

Texture entSkin1;

sampler2D smpDiffuse = sampler_state 
{
	Texture = <entSkin1>;
};

struct VS_OUT
{
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
	float3 local : TEXCOORD1;
};

VS_OUT vs(
	float4 pos : POSITION,
	float2 tex : TEXCOORD0)
{
	VS_OUT o;
	o.pos = mul(pos, matWorldViewProj);
	o.local = pos.xyz;
	o.uv = tex;

	return o;	
}

float4 ps_outside(VS_OUT i) : COLOR0
{
	float3 plane = float3(0, 0, 0);
	float3 normal = float3(0, 1, 0);
	
	clip(-dot(normal, i.local - plane));
	
	return tex2D(smpDiffuse, i.uv);
}

float4 ps_inside(VS_OUT i) : COLOR0
{
	float3 plane = float3(0, 0, 0);
	float3 normal = float3(0, 1, 0);
	
	clip(-dot(normal, i.local - plane));
	
	return float4(1, 0, 0, 1);
}

technique
{
	pass
	{
		CullMode = CW;
		VertexShader = compile vs_2_0 vs();
		PixelShader = compile ps_2_0 ps_inside();
	}
	pass
	{
		CullMode = CCW;
		VertexShader = compile vs_2_0 vs();
		PixelShader = compile ps_2_0 ps_outside();
	}
}