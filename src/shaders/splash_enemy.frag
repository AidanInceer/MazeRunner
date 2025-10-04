// Splash Enemy Shader
// Creates a burning/fire effect with jump animation

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;
uniform vec2 enemyPos;
uniform float animationPhase;  // 0: normal, 1: jumping, 2: flashing
uniform float animationTimer;
uniform bool isSplashing;

varying vec2 VaryingTexCoord;

// Fire colors - brighter and more intense
vec3 fireColor1 = vec3(1.0, 0.4, 0.0);  // Bright orange
vec3 fireColor2 = vec3(1.0, 0.7, 0.0);  // Orange
vec3 fireColor3 = vec3(1.0, 1.0, 0.2);  // Bright yellow
vec3 fireColor4 = vec3(1.0, 0.2, 0.0);  // Bright red-orange
vec3 fireColor5 = vec3(1.0, 0.8, 0.0);  // Golden yellow

// Noise function for fire effect
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Smooth noise
float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal noise
float fractalNoise(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * smoothNoise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    
    return value;
}

void main() {
    vec2 uv = VaryingTexCoord;
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    
    // Base enemy color (brighter orange)
    vec3 baseColor = vec3(1.0, 0.5, 0.0);
    
    // Jump animation - move the center up
    float jumpOffset = 0.0;
    if (animationPhase == 1) {
        // Jump animation: move up over 0.2 seconds
        float jumpProgress = animationTimer / 0.2;
        jumpOffset = sin(jumpProgress * 3.14159) * 0.15;
    }
    
    // Adjust center for jump
    vec2 adjustedCenter = center + vec2(0.0, jumpOffset);
    float adjustedDist = distance(uv, adjustedCenter);
    
    // Create enemy shape (circle)
    float enemyShape = 1.0 - smoothstep(0.3, 0.35, adjustedDist);
    
    if (isSplashing) {
        // Enhanced fire effect during splash
        vec2 fireUV = uv * 2.0 - 1.0;
        fireUV.y += time * 3.0;  // Faster upward animation
        
        // Multiple layers of fire noise for more complexity
        float fireNoise1 = fractalNoise(fireUV * 4.0 + time);
        float fireNoise2 = fractalNoise(fireUV * 2.0 + time * 0.5);
        float fireNoise3 = fractalNoise(fireUV * 8.0 + time * 2.0);
        
        float combinedNoise = (fireNoise1 + fireNoise2 * 0.5 + fireNoise3 * 0.3) / 1.8;
        
        float fireIntensity = 1.0 - adjustedDist * 1.5;
        fireIntensity = max(0.0, fireIntensity);
        
        // Enhanced fire color gradient with more layers
        vec3 fireColor;
        if (fireIntensity > 0.9) {
            // Brightest center - white-hot
            fireColor = mix(fireColor3, vec3(1.0, 1.0, 1.0), (fireIntensity - 0.9) / 0.1);
        } else if (fireIntensity > 0.7) {
            // Bright yellow to golden
            fireColor = mix(fireColor5, fireColor3, (fireIntensity - 0.7) / 0.2);
        } else if (fireIntensity > 0.5) {
            // Golden to orange
            fireColor = mix(fireColor2, fireColor5, (fireIntensity - 0.5) / 0.2);
        } else if (fireIntensity > 0.3) {
            // Orange to bright orange
            fireColor = mix(fireColor1, fireColor2, (fireIntensity - 0.3) / 0.2);
        } else {
            // Bright red-orange
            fireColor = fireColor4;
        }
        
        // Enhanced fire noise with more intensity
        fireColor *= (0.6 + 0.4 * combinedNoise);
        
        // Add pulsing effect
        float pulse = 0.8 + 0.2 * sin(time * 8.0);
        fireColor *= pulse;
        
        // Flash effect during splash - more intense
        if (animationPhase == 2) {
            float flashIntensity = sin(animationTimer * 25.0) * 0.5 + 0.5;
            fireColor += vec3(flashIntensity * 0.8);
            // Add white flash
            fireColor += vec3(flashIntensity * 0.3);
        }
        
        // Add outer glow effect
        float glowIntensity = 1.0 - smoothstep(0.2, 0.4, adjustedDist);
        vec3 glowColor = fireColor * 0.5;
        
        // Combine with enemy shape and glow
        vec3 finalColor = mix(baseColor, fireColor, enemyShape * fireIntensity);
        finalColor += glowColor * glowIntensity * 0.3;
        
        gl_FragColor = vec4(finalColor, enemyShape + glowIntensity * 0.2);
    } else {
        // Normal state - brighter base color with subtle glow
        float glowIntensity = 1.0 - smoothstep(0.3, 0.4, adjustedDist);
        vec3 glowColor = baseColor * 0.3;
        vec3 finalColor = baseColor + glowColor * glowIntensity;
        gl_FragColor = vec4(finalColor, enemyShape + glowIntensity * 0.1);
    }
}
