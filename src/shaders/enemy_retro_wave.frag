// Theme-based aggressive shader for enemies
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;
uniform sampler2D image;
uniform vec3 enemyColor;
uniform float themeType;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    
    // Theme-based effects
    vec3 themeColor = enemyColor;
    float waveIntensity = 0.08;
    float sparkIntensity = 1.0;
    float noiseIntensity = 0.15;
    
    // Forest theme (0) - Nature/Organic effects
    if (themeType < 0.5) {
        themeColor = vec3(0.0, 1.0, 0.0); // Bright Green
        waveIntensity = 0.03;
        sparkIntensity = 0.5;
        noiseIntensity = 0.05;
    }
    // Cave theme (1) - Rocky/Underground effects
    else if (themeType < 1.5) {
        themeColor = vec3(0.8, 0.4, 0.0); // Orange Brown
        waveIntensity = 0.08;
        sparkIntensity = 1.0;
        noiseIntensity = 0.15;
    }
    // Void theme (2) - Dark/Space effects
    else if (themeType < 2.5) {
        themeColor = vec3(0.0, 0.0, 1.0); // Bright Blue
        waveIntensity = 0.15;
        sparkIntensity = 2.0;
        noiseIntensity = 0.3;
    }
    // Abyss theme (3) - Hell/Fire effects
    else {
        themeColor = vec3(1.0, 0.0, 0.0); // Bright Red
        waveIntensity = 0.12;
        sparkIntensity = 3.0;
        noiseIntensity = 0.4;
    }
    
    // Create theme-based wavy distortion
    float wave1 = sin(uv.x * 30.0 + time * 8.0) * waveIntensity;
    float wave2 = sin(uv.y * 25.0 + time * 6.0) * (waveIntensity * 0.75);
    float wave3 = sin(uv.x * 15.0 + uv.y * 20.0 + time * 4.0) * (waveIntensity * 0.5);
    vec2 distortedUV = uv + vec2(wave1 + wave3, wave2 + wave3);
    
    // Sample with heavy distortion
    vec4 color = texture2D(image, distortedUV);
    
    // Add theme-based scanlines
    float scanline1 = sin(uv.y * resolution.y * 1.2) * 0.12;
    float scanline2 = sin(uv.y * resolution.y * 0.6 + time * 10.0) * 0.08;
    color.rgb += scanline1 + scanline2;
    
    // Add theme-based chromatic aberration
    float aberration = 0.02 * (1.0 + themeType * 0.5);
    color.r = texture2D(image, distortedUV + vec2(aberration, 0.0)).r;
    color.b = texture2D(image, distortedUV - vec2(aberration, 0.0)).b;
    
    // Add theme-based color shifting
    float colorShift1 = sin(time * 12.0 + uv.x * 20.0) * 0.8;
    float colorShift2 = sin(time * 8.0 + uv.y * 15.0) * 0.6;
    float colorShift3 = sin(time * 16.0 + uv.x * 25.0 + uv.y * 18.0) * 0.4;
    color.r += (colorShift1 + colorShift3) * 0.5;
    color.g += (colorShift2 + colorShift3) * 0.3;
    color.b += (colorShift1 + colorShift2) * 0.7;
    
    // Add theme-based sparky noise
    float noise1 = fract(sin(dot(uv + time * 2.0, vec2(12.9898, 78.233))) * 43758.5453);
    float noise2 = fract(sin(dot(uv + time * 1.5, vec2(23.1407, 2.6651))) * 43758.5453);
    float noise3 = fract(sin(dot(uv + time * 3.0, vec2(7.1234, 15.6789))) * 43758.5453);
    color.rgb += (noise1 - 0.5) * noiseIntensity;
    color.rgb += (noise2 - 0.5) * (noiseIntensity * 0.67);
    color.rgb += (noise3 - 0.5) * (noiseIntensity * 0.53);
    
    // Add theme color with very aggressive tinting
    color.rgb = mix(color.rgb, themeColor, 0.9);
    
    // Add theme-based pulsing effect
    float pulse1 = sin(time * 15.0) * 0.4 + 0.6;
    float pulse2 = sin(time * 22.0) * 0.3 + 0.7;
    float pulse3 = sin(time * 8.0) * 0.2 + 0.8;
    color.rgb *= pulse1 * pulse2 * pulse3;
    
    // Add theme-based sparky border effect
    float borderWave1 = sin(uv.x * 12.0 + time * 5.0) * 0.3 + 0.7;
    float borderWave2 = sin(uv.y * 10.0 + time * 3.0) * 0.2 + 0.8;
    float borderFade = 1.0 - smoothstep(0.2, 0.6, length(uv - 0.5));
    color.rgb *= borderWave1 * borderWave2 * borderFade;
    
    // Add theme-based electric spark effects
    float spark1 = step(0.95, fract(sin(dot(uv + time * 0.1, vec2(12.345, 67.890))) * 43758.5453));
    float spark2 = step(0.98, fract(sin(dot(uv + time * 0.2, vec2(34.567, 89.012))) * 43758.5453));
    color.rgb += spark1 * vec3(1.0, 1.0, 1.0) * 0.8;
    color.rgb += spark2 * themeColor * sparkIntensity;
    
    // Add theme-based contrast boost
    color.rgb = pow(color.rgb, vec3(0.7));
    color.rgb *= 1.5;
    
    // Add theme-based electric glow
    float glow = sin(time * 20.0 + length(uv - 0.5) * 10.0) * 0.3 + 0.7;
    color.rgb += glow * themeColor * 0.4;
    
    gl_FragColor = color;
}
