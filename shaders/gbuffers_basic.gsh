#version 330 compatibility

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

in float blockId_v[];
in vec2 texcoord_v[];
in vec2 lmcoord_v[];
in vec3 normal_v[];
in vec3 viewPos_v[];
in vec4 tangent_v[];
in vec4 glcolor_v[];

out float blockId;
out vec2 texcoord;
out vec2 lmcoord;
out vec3 normal;
out vec3 viewPos;
out vec4 tangent;
out vec4 glcolor;
out vec3 barycentric; // Координаты для определения краев

void main() {
    for(int i = 0; i < 3; i++) {
        gl_Position = gl_in[i].gl_Position;
        
        blockId = blockId_v[i];
        texcoord = texcoord_v[i];
        lmcoord = lmcoord_v[i];
        normal = normal_v[i];
        viewPos = viewPos_v[i];
        tangent = tangent_v[i];
        glcolor = glcolor_v[i];

        // Назначаем "вес" вершины для определения ребер
        if(i == 0) barycentric = vec3(1.0, 0.0, 0.0);
        else if(i == 1) barycentric = vec3(0.0, 1.0, 0.0);
        else barycentric = vec3(0.0, 0.0, 1.0);

        EmitVertex();
    }
    EndPrimitive();
}
