precision mediump float;

uniform float time;
uniform sampler2D uDataTexture;
uniform vec3 uColor;
uniform vec4 uResolution;

varying vec2 vUv;
varying vec3 vPosition;

float PI = 3.1415926535897932384626433832795;

// 2D Random
float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

vec3 orange = vec3(1.0, 0.5, 0.0);

void main() {
    vec2 newUv = (vUv - vec2(0.5)) * uResolution.zw + vec2(0.5);

    vec4 offset = texture2D(uDataTexture, vUv);

    // vec4 color = vec4(orange, noise(offset.xy * 10.0));

    // combine the offset with the original uv

    vec2 finalUv = newUv + offset.xy;

    // get the color from the texture

    vec4 generatedTexture = texture2D(uDataTexture, finalUv);

    // color = mix(color, generatedTexture, 0.5);

    vec4 color = generatedTexture;

    // add the color to the scene

    gl_FragColor = color;
}