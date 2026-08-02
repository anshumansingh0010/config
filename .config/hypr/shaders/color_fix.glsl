#version 300 es
precision mediump float;

// 'varying' becomes 'in'
in vec2 v_texcoord;
uniform sampler2D tex;

// We must declare our own output variable
out vec4 fragColor;

void main() {
    // 'texture2D' becomes 'texture'
    vec4 color = texture(tex, v_texcoord);

    // --- MANUAL ADJUSTMENTS ---
    float saturation = 1.4;  // 1.0 is default
    float contrast = 1.03;   // 1.0 is default
    float brightness = 1.0;  // 1.0 is default
    // -------------------------

    // Apply Contrast & Brightness
    color.rgb = ((color.rgb - 0.5) * contrast + 0.5) * brightness;

    // Apply Saturation (NVIDIA style)
    float gray = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    color.rgb = mix(vec3(gray), color.rgb, saturation);

    // Assign to our custom output instead of gl_FragColor
    fragColor = color;
}
