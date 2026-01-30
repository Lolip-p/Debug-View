#version 330 compatibility

#include "settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;

in float blockId;
in vec2 lmcoord;
in vec2 texcoord;
in vec3 normal;
in vec3 viewPos;
in vec4 tangent;
in vec4 glcolor;
in vec3 barycentric;

// Texture
uniform sampler2D normals;					// normalMap
uniform sampler2D specular;                 // specularMap

mat3 tbnNormalTangent(vec3 normal, vec4 tangent) {
    vec3 bitangent = cross(tangent.xyz, normal) * tangent.w;
    return mat3(tangent.xyz, bitangent, normal);
}

void main() {
    vec4 albedo = texture(gtexture, texcoord) * glcolor;
    vec4 lmcolor = texture(lightmap, lmcoord);

    // Wireframe
    #if MODE == 0
    float closestEdge = min(barycentric.x, min(barycentric.y, barycentric.z));
    float edgeFactor = smoothstep(0.0, fwidth(closestEdge), closestEdge);
    albedo = mix(vec4(0.0, 1.0, 0.0, 1.0), albedo, edgeFactor);
    #endif


    
    mat3 TBN = tbnNormalTangent(normal, tangent);

    vec3 normalMap = texture(normals, texcoord).xyz;
    float textureAO = normalMap.b;
    normalMap.xy = normalMap.xy * 2.0 - 1.0;
    normalMap.z = sqrt(1.0 - dot(normalMap.xy, normalMap.xy));
    normalMap = normalize(TBN * normalMap);
    vec3 normalMapWorld = mat3(gbufferModelViewInverse) * normalMap;
    
    #if MODE == 10
    vec3 worldSunDir = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition);
	float lightDot = clamp(dot(worldSunDir, normalMapWorld), 0.0, 1.0); // 
    

    vec4 specularMap = texture(specular, texcoord);
    float f0 = specularMap.g;
    bool metal = specularMap.g >= 229.5;
    // red channel
    float perceptualSmoothness = specularMap.r;
    float roughness = pow(1.0 - perceptualSmoothness, 2.0);
    float smoothness = 1.0 - roughness;
    // blue channel
    float porosity = specularMap.b < 64.5/255.0 ? specularMap.b / 64.0 : 0.0;
    float sss = specularMap.b >= 64.5/255.0 ? (specularMap.b - 64.0) / (255.0 - 64.0) : 0.0;
    // alpha channel
    float emmisive = specularMap.a >= 254.5/255.0 ? 0.0 : specularMap.a;

    //IPBR
    if(abs(blockId - 10006.0) < 0.5) {    // water
        smoothness = 1.0;
    }

    vec3 rayDir = normalize(viewPos.xyz);
    float fresnel = pow(clamp(1.0 + dot(normalMap, rayDir), 0.0, 1.0), 6.0) * 1.0;
    float reflectiveStrength = f0 + (1.0 - f0) * fresnel * smoothness;


    // specular
    vec3 reflectedRay = reflect(rayDir, normalMap);
    float sunReflaction = pow(clamp(dot(reflectedRay, normalize(shadowLightPosition)), 0.0, 1.0), 1.0 + 15.0 * smoothness);
    sunReflaction *= clamp(dot(normalMap, normalize(shadowLightPosition)) * 100.0, 0.0, 1.0);
    //sunReflaction *= smoothness;     // soften



    vec3 what = albedo.rgb * ((skyStrength * textureAO) + lightDot * (1.0 - reflectiveStrength));		// light

    what += reflectiveStrength * sunReflaction * (metal? albedo.rgb:vec3(1.0));
    what = clamp(what + albedo.rgb * emmisive, 0.0, 1.0);


    albedo.rgb = what;
    //albedo.rgb = vec3(reflectiveStrength);
    #endif


    /* DRAWBUFFERS:012 */
    gl_FragData[0] = albedo;
    gl_FragData[1].rgb = lmcolor.rgb;
    gl_FragData[2].rgb = normalMap * 0.5 + 0.5;
}
