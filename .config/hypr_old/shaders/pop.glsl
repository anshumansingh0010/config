#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;

out vec4 fragColor;

void main() {
    vec4 color = texture(tex, v_texcoord);

    // 1. Boost Saturation
    float luminance = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    color.rgb = mix(vec3(luminance), color.rgb, 1.4); 

    // 2. Increase Contrast
    color.rgb = (color.rgb - 0.5) * 1.1 + 0.5;

    fragColor = color;
}
