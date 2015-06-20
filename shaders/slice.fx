
float4 vecSkill41;
float4 vecSkill45;

float4x4 matViewInv;
float4x4 matWorld;
float4x4 matWorldInv;
float4x4 matWorldViewProj;

float4 vecViewPos;

Texture entSkin1;
Texture mtlSkin1;

sampler2D smpDiffuse = sampler_state 
{
	Texture = <entSkin1>;
};

sampler2D smpDiffuseInterior = sampler_state
{
	Texture = <mtlSkin1>;	
};

// Loosly adapted from http://http.developer.nvidia.com/GPUGems3/gpugems3_ch01.html
// Read article for more information
float4 textureTriplanar(sampler2D smp, float3 position, float3 normal, float scale)
{
	float3 blend_weights = abs(normal);
	blend_weights = (blend_weights - 0.2) * 7;  
	blend_weights = max(blend_weights, 0);
	blend_weights /= (blend_weights.x + blend_weights.y + blend_weights.z);   
	
	float2 coord1 = position.yz * scale;  
	float2 coord2 = position.zx * scale;  
	float2 coord3 = position.xy * scale;  
	
	float4 col1 = tex2D(smp, coord1);
	float4 col2 = tex2D(smp, coord2);
	float4 col3 = tex2D(smp, coord3);
	
	return col1 * blend_weights.x +  
			 col2 * blend_weights.y +  
			 col3 * blend_weights.z;  
}

float intersectPlane(float3 rayOrigin, float3 rayDir, float3 fulcrum, float3 normal)
{
	float numerator = dot(fulcrum - rayOrigin, normal);
	float denominator = dot(rayDir, normal);
	if(abs(denominator) <= 0.01f) { // If plane/ray nearly parallel
		return 1E10f; // we hit plane in far distance
	}
	return numerator / denominator;
}

struct VS_OUT
{
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
	float3 local : TEXCOORD1;
	float3 normal : TEXCOORD2;
	float3 world : TEXCOORD3;
	float3 camera : TEXCOORD4;
};

VS_OUT vs(
	float4 pos : POSITION,
	float3 normal : NORMAL,
	float2 tex : TEXCOORD0)
{
	VS_OUT o;
	o.pos = mul(pos, matWorldViewProj);
	o.local = pos.xyz;
	o.world = mul(pos, matWorld).xyz;
	o.normal = mul(normal, (float3x3)matWorld);
	o.camera = mul(float4(vecViewPos.xyz,1), matWorldInv).xyz;
	o.uv = tex;
	return o;	
}

float4 ps_outside(VS_OUT i) : COLOR0
{
	float3 plane = vecSkill45.xyz;
	float3 normal = vecSkill41.xyz;
	
	clip(-dot(normal, i.local - plane));
	
	return tex2D(smpDiffuse, i.uv);
}

float4 ps_inside(VS_OUT i) : COLOR0
{
	float3 plane = vecSkill45.xyz;
	float3 normal = vecSkill41.xyz;
	
	clip(-dot(normal, i.local - plane));
	
	float3 dir = normalize(i.local - i.camera);
	float dist = intersectPlane(i.camera, dir, plane, normal);
	if(dist > 1E9) {
		return float4(1, 0, 0, 1);	
	}
	
	float3 pos = i.camera + dist * dir;
	
	return float4(1, 0, 0, 1) * textureTriplanar(smpDiffuseInterior, pos, normal, 0.01f);;
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