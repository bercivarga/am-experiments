precision mediump float;

uniform float u_time;
uniform sampler2D uDataTexture;
uniform vec3 uColor;
uniform vec4 uResolution;
uniform vec2 u_mouse;
uniform vec2 u_actual_resolution;

varying vec2 vUv;
varying vec3 vPosition;

float PI = 3.1415926535897932384626433832795;

vec3 random3(vec3 c) {
    float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
    vec3 r;
    r.z = fract(512.0*j);
    j *= .125;
    r.x = fract(512.0*j);
    j *= .125;
    r.y = fract(512.0*j);
    return r-0.5;
}
/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;
/* 3d simplex noise */
float simplex3d(vec3 p) {
      /* 1. find current tetrahedron T and it's four vertices */
      /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
      /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
      /* calculate s and x */
      vec3 s = floor(p + dot(p, vec3(F3)));
      vec3 x = p - s + dot(s, vec3(G3));
      /* calculate i1 and i2 */
      vec3 e = step(vec3(0.0), x - x.yzx);
      vec3 i1 = e*(1.0 - e.zxy);
      vec3 i2 = 1.0 - e.zxy*(1.0 - e);
      /* x1, x2, x3 */
      vec3 x1 = x - i1 + G3;
      vec3 x2 = x - i2 + 2.0*G3;
      vec3 x3 = x - 1.0 + 3.0*G3;
      /* 2. find four surflets and store them in d */
      vec4 w, d;
      /* calculate surflet weights */
      w.x = dot(x, x);
      w.y = dot(x1, x1);
      w.z = dot(x2, x2);
      w.w = dot(x3, x3);
      /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
      w = max(0.6 - w, 0.0);
      /* calculate surflet components */
      d.x = dot(random3(s), x);
      d.y = dot(random3(s + i1), x1);
      d.z = dot(random3(s + i2), x2);
      d.w = dot(random3(s + 1.0), x3);
      /* multiply d by w^4 */
      w *= w;
      w *= w;
      d *= w;
      /* 3. return the sum of the four surflets */
      return dot(d, vec4(52.0));
}
// map a value from one range to another
vec2 map(vec2 value, vec2 start1, vec2 stop1, vec2 start2, vec2 stop2) {
    return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
}

vec3 orange = vec3(1.0, 0.5, 0.0);
vec3 blue = vec3(0.0, 0.5, 1.0);
vec3 green = vec3(0.0, 1.0, 0.5);
vec3 red  = vec3(1.0, 0.0, 0.5);

void main() {

    // vec2 newUv = (vUv - vec2(0.5)) * uResolution.zw + vec2(0.5);

    // vec4 offset = texture2D(uDataTexture, vUv);

    // vec2 finalUv = newUv + offset.xy;

    // vec4 generatedTexture = texture2D(uDataTexture, finalUv);

    // gl_FragColor = color;

    // keep aspect ratio

    vec2 newUv = (vUv - vec2(0.5)) * uResolution.zw + vec2(0.5);

    vec3 color = vec3(0.0);

    vec2 mouse = map(u_mouse, vec2(0.0), uResolution.xy, vec2(0.0), vec2(1.0)); 

    vec3 accentColor = blue;
    
    // Experiment with colors based on mouse position
    // if (mouse.x < 0.5 && mouse.y < 0.5) {
    //     accentColor = blue;
    // } else if (mouse.x > 0.5 && mouse.y < 0.5) {
    //     accentColor = green;
    // } else if (mouse.x > 0.5 && mouse.y > 0.5) {
    //     accentColor = red;
    // }

    float noiseVal = simplex3d(vec3(newUv, u_time * 0.1));

    color = mix(color, accentColor, noiseVal);

    // color = mix(color, generatedTexture.rgb, 0.2);


    // render a 5x5 grid of rectangles around the mouse position with a width and height of 40px each
    const float rowColSize = 5.0;
    float gridSize = u_actual_resolution.x / u_actual_resolution.y * 40.0;
    float gridX = floor(mouse.x * u_actual_resolution.x / gridSize);
    float gridY = floor(mouse.y * u_actual_resolution.y / gridSize);
    vec2 gridPos = vec2(gridX, gridY) * vec2(gridSize) / u_actual_resolution;

    vec2 gridUv = map(newUv, gridPos, gridPos + vec2(gridSize) / u_actual_resolution, vec2(0.0), vec2(1.0));

    if (gridUv.x > 0.0 && gridUv.x < 1.0 && gridUv.y > 0.0 && gridUv.y < 1.0) {
        // for (float i = 0.0; i < rowColSize; i++) {
        //     for (float j = 0.0; j < rowColSize; j++) {
        //         vec2 gridUv = map(newUv, gridPos + vec2(i, j) * vec2(gridSize) / u_actual_resolution, gridPos + vec2(i + 1.0, j + 1.0) * vec2(gridSize) / u_actual_resolution, vec2(0.0), vec2(1.0));

        //         float xVal = i * gridSize / u_actual_resolution.x;
        //         float yVal = j * gridSize / u_actual_resolution.y;

        //         if (gridUv.x > 0.0 && gridUv.x < rowColSize && gridUv.y > 0.0 && gridUv.y < rowColSize) {
        //             color = mix(color, accentColor, 0.5);
        //         }
        //     }
        // }

        color = mix(color, accentColor, 0.5);
    }

    gl_FragColor = vec4(color, 1.0);
}