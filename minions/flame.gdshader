shader_type canvas_item;

// Base outline thickness (in pixels)
uniform float outline_size : hint_range(1, 8) = 2.0;
// Additional uniform to control how intense the pulsation is.
uniform float pulsation_intensity : hint_range(0.0, 5.0) = 5.0;
// Alpha threshold for edge detection (sprite vs. transparent)
uniform float threshold : hint_range(0.0, 1.0) = 0.8;

// Uniform to control gradual appearance (0.0 = off, 1.0 = fully on)
uniform float fade : hint_range(0.0, 1.0) = 0.0;

// Flame colors – feel free to modify these.
uniform vec4 flame_color_primary   : source_color = vec4(1.0, 0.5, 0.0, 1.0); // bright orange
uniform vec4 flame_color_secondary : source_color = vec4(1.0, 1.0, 0.0, 1.0); // yellow
uniform vec4 flame_color_tertiary  : source_color = vec4(1.0, 0.0, 0.0, 1.0); // red

// Noise parameters for turbulence and flicker.
uniform float noise_scale       : hint_range(1.0, 20.0) = 10.0;
uniform float flame_speed       : hint_range(0.0, 10.0) = 3.0;
uniform float flicker_intensity : hint_range(0.0, 2.0) = 1.0;

// Time value (animate this via script or AnimationPlayer)
uniform float time : hint_range(0, 10000) = 0.0;

// 2D hash function for noise generation.
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// 2D noise function (basic value noise)
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion for layered noise
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    // Sample the sprite texture.
    vec4 texColor = texture(TEXTURE, UV);
    float centerAlpha = texColor.a;
    float neighborAlphaMax = 0.0;

    // Default effect color is the original texture.
    vec4 effectColor = texColor;

    // --------------------------------------------------------------------
    // Compute a smooth pulsation factor by averaging two lower-frequency fbm samples.
    float pulseNoise1 = fbm(UV * (noise_scale * 2.0) + vec2(time * flame_speed, time * flame_speed));
    float pulseNoise2 = fbm(UV * (noise_scale * 2.0) + vec2(time * flame_speed + 5.0, time * flame_speed - 5.0));
    float pulseNoise = (pulseNoise1 + pulseNoise2) * 0.5;

    // Reduce the base thickness to make the outline thinner.
    float base_thickness = outline_size * 0.5;
    // Increase the pulsation range: dynamic outline thickness will vary from base_thickness to
    // base_thickness * (1.0 + pulsation_intensity).
    float dynamic_outline_size = base_thickness * (1.0 + pulsation_intensity * pulseNoise);
    int steps = int(dynamic_outline_size);
    // --------------------------------------------------------------------

    // Loop over a small area around the pixel to find edge pixels.
    for (int x = -steps; x <= steps; x++) {
        for (int y = -steps; y <= steps; y++) {
            vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE;
            float sampleAlpha = texture(TEXTURE, UV + offset).a;
            neighborAlphaMax = max(neighborAlphaMax, sampleAlpha);
        }
    }

    // If this pixel is outside the main sprite but borders an opaque pixel, it’s part of the outline.
    if (centerAlpha < threshold && neighborAlphaMax > threshold) {
        // Add turbulence: distort UVs using fbm for a natural wavy motion.
        vec2 turbulence = vec2(
            fbm(UV * noise_scale + time * flame_speed),
            fbm(UV * noise_scale - time * flame_speed)
        );
        // Adjust the distortion magnitude (tweak 0.05 as needed)
        vec2 distortedUV = UV + (turbulence - 0.5) * 0.05;

        // Get a noise value from the distorted UV to drive color variation.
        float n = fbm(distortedUV * noise_scale + time * flame_speed);

        // Create an additional flicker effect using a sine function.
        float flicker = 1.0 + (sin(time * flame_speed + n * 6.2831) * 0.3 * flicker_intensity);

        // Optionally use vertical position to help drive brightness (simulate flame shape)
        float verticalFactor = UV.y;

        // Dynamically mix between three flame colors based on the noise value.
        vec4 flameColor = flame_color_primary;
        if (n < 0.4) {
            flameColor = mix(flame_color_tertiary, flame_color_primary, n / 0.4);
        } else if (n > 0.6) {
            flameColor = mix(flame_color_primary, flame_color_secondary, (n - 0.6) / 0.4);
        }

        // Modulate brightness with verticalFactor (flames can be brighter near certain areas)
        flameColor.rgb *= mix(0.8, 1.2, verticalFactor);
        // Apply the flicker modulation.
        flameColor.rgb *= flicker;

        // Compute an outline alpha that also fluctuates with the noise and flicker.
        float finalAlpha = clamp(flicker * (0.6 + n * 0.4), 0.0, 1.0);
        // Make the outline a bit transparent.
        finalAlpha *= 0.7;

        effectColor = vec4(flameColor.rgb, finalAlpha);
    }

    // Gradually blend from the original texture to the flame effect using fade.
    COLOR = mix(texColor, effectColor, fade);
}
