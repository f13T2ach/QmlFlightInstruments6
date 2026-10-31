#version 440

layout(location = 0) in highp vec2 qt_TexCoord0;
layout(location = 0) out highp vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float pitchRad;
    float rollRad;
};

void main()
{
    vec2 p = (qt_TexCoord0 - vec2(0.5)) * 2.0;
    p.y = -p.y;

    vec3 ray = normalize(vec3(p.x, p.y, -1.6));
    vec3 up = vec3(-sin(rollRad) * cos(pitchRad),
                    cos(rollRad) * cos(pitchRad),
                   -sin(pitchRad));
    highp float h = dot(ray, up);

    vec3 sky = vec3(0.184, 0.498, 0.827);
    vec3 ground = vec3(0.478, 0.310, 0.141);
    highp float blend = smoothstep(-0.003, 0.003, h);
    vec3 color = mix(ground, sky, blend);

    highp float line = 1.0 - smoothstep(0.0, 0.012, abs(h));
    color = mix(color, vec3(0.85), line * 0.45);

    fragColor = vec4(color, 1.0) * qt_Opacity;
}
