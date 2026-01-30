#version 330 compatibility

#include "settings.glsl"

in vec2 texcoord;

uniform sampler2D colortex0;				// albedo
uniform sampler2D colortex1;				// lightmap
uniform sampler2D colortex2;				// normal
uniform sampler2D depthtex0;				// depth

uniform float far;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 shadowLightPosition;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

void main() {
    vec3 albedo = texture(colortex0, texcoord).rgb;
    vec3 lightmap = texture(colortex1, texcoord).rgb;
    vec3 normal = texture(colortex2, texcoord).rgb;
	float depth = texture(depthtex0, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	vec3 outColor;
	#if MODE == 1 || MODE == 0
	outColor = albedo;
	#endif
	#if MODE == 2
	outColor = lightmap;
	#endif
	#if MODE == 3 || MODE == 4
	outColor = normalize((normal - 0.5) * 2.0);		// normal
	#endif
	#if MODE == 5
	outColor = mix(vec3(0.0), vec3(1.0), length(viewPos) / far);	// depth
	#endif
	#if MODE == 6
	outColor = viewPos;		// viewPos
	#endif
	#if MODE == 7
	outColor = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;	// feetPlayerPos
	#endif
	#if MODE == 8
	outColor = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz + cameraPosition;	// worldPos
	#endif
	#if MODE == 9
	outColor = normal;		// normalMap
	#endif
	#if MODE == 10
	outColor = albedo;
	#endif

	/*DRAWBUFFERS:0*/
	gl_FragData[0].rgb = outColor;
}
