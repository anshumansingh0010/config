#version 300 es
precision mediump float;

// In GLSL 300 es, 'varying' is replaced by 'in'
in vec2 v_texcoord;
uniform sampler2D tex;

// You must declare your own output variable instead of using gl_FragColor
out vec4 fragColor;

void main() {
    // texture2D is replaced by the simpler texture()
    vec4 color = texture(tex, v_texcoord);
    
    float avg = (color.r + color.g + color.b) / 3.0;
    float mx = max(color.r, max(color.g, color.b));
    float amt = (mx - avg) * 0.75; 
    
    fragColor = vec4(color.rgb + amt * (color.rgb - mx), color.a);
}
