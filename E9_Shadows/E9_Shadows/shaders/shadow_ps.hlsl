
Texture2D shaderTexture : register(t0);
Texture2D depthMapTexture[2] : register(t1);

SamplerState diffuseSampler  : register(s0);
SamplerState shadowSampler[2] : register(s1);

cbuffer LightBuffer : register(b0)
{
	float4 ambient[2];
	float4 diffuse[2];
	float4 direction[2];
    float4 position[2];
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
    float4 lightViewPos1 : TEXCOORD1;
    float4 lightViewPos2 : TEXCOORD2;
};

// Calculate lighting intensity based on direction and normal. Combine with light colour.
float4 calculateLighting(float4 lightDirection, float3 normal, float4 diffuse)
{
    float intensity = saturate(dot(normal, lightDirection.xyz));
    float4 colour = saturate(diffuse * intensity);
    return colour;
}

// Is the gemoetry in our shadow map
bool hasDepthData(float2 uv)
{
    if (uv.x < 0.f || uv.x > 1.f || uv.y < 0.f || uv.y > 1.f)
    {
        return false;
    }
    return true;
}

bool isInShadow(Texture2D sMap, float2 uv, float4 lightViewPosition, float bias, int index)
{
    // Sample the shadow map (get depth of geometry)
    float depthValue = sMap.Sample(shadowSampler[index], uv).r;
	// Calculate the depth from the light.
    float lightDepthValue = lightViewPosition.z / lightViewPosition.w;
    lightDepthValue -= bias;

	// Compare the depth of the shadow map value and the depth of the light to determine whether to shadow or to light this pixel.
    if (lightDepthValue < depthValue)
    {
        return false;
    }
    return true;
}

float2 getProjectiveCoords(float4 lightViewPosition)
{
    // Calculate the projected texture coordinates.
    float2 projTex = lightViewPosition.xy / lightViewPosition.w;
    projTex *= float2(0.5, -0.5);
    projTex += float2(0.5f, 0.5f);
    return projTex;
}

float4 main(InputType input) : SV_TARGET
{
    float shadowMapBias = 0.005f;
    float4 colour = float4(0.f, 0.f, 0.f, 1.f);
    float4 textureColour = shaderTexture.Sample(diffuseSampler, input.tex);

	// Calculate the projected texture coordinates.
    float2 pTexCoord = getProjectiveCoords(input.lightViewPos1);
    float2 pTexCoord2 = getProjectiveCoords(input.lightViewPos2);
	
    // Shadow test. Is or isn't in shadow
    if (hasDepthData(pTexCoord))
    {
        // Has depth map data
        if (!isInShadow(depthMapTexture[0], pTexCoord, input.lightViewPos1, shadowMapBias, 0))
        {
            // not in shadow1, therefore light1
            colour += calculateLighting(-direction[0], input.normal, diffuse[0]);
        }
    }

    if (hasDepthData(pTexCoord2)) {
        if (!isInShadow(depthMapTexture[1], pTexCoord2, input.lightViewPos2, shadowMapBias, 1)) {
            //not in shadow2, therefore light2
            colour += calculateLighting(-direction[1], input.normal, diffuse[1]);
        }
    }

    //if (hasDepthData(pTexCoord) && hasDepthData(pTexCoord2)) {
    //    if (!isInShadow(depthMapTexture, pTexCoord, input.lightViewPos1, shadowMapBias, 0) && !isInShadow(depthMap2Texture, pTexCoord2, input.lightViewPos2, shadowMapBias, 1)) {
    //        //not in either shadow, therefore both lights
    //        colour = calculateLighting(-direction[0], input.normal, diffuse[0]) + calculateLighting(-direction[1], input.normal, diffuse[1]);
    //    }
    //}
    
    colour = saturate(colour + ambient[0] + ambient[1]);
    return saturate(colour) * textureColour;
}