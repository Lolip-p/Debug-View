#version 330 compatibility

#include "settings.glsl"

in vec4 at_tangent;
in vec2 mc_Entity;

uniform mat4 gbufferModelViewInverse;

out float blockId_v;
out vec2 texcoord_v;
out vec2 lmcoord_v;
out vec3 normal_v;
out vec3 viewPos_v;
out vec4 tangent_v;
out vec4 glcolor_v;

void main() {
    blockId_v = mc_Entity.x;

    gl_Position = ftransform();
    
    texcoord_v = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord_v  = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.xy;
	normal_v = gl_NormalMatrix * gl_Normal;
	tangent_v = vec4(normalize(gl_NormalMatrix * at_tangent.xyz), at_tangent.w);
    #if MODE == 4
	normal_v = mat3(gbufferModelViewInverse) * normal_v;
	#endif

    viewPos_v = (gl_ModelViewMatrix * gl_Vertex).xyz;
    
    glcolor_v  = gl_Color;
}
