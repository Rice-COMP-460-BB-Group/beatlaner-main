shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0); // Animate from 0.0 to 1.0
uniform float fall_speed = 50.0; // Speed of falling dust
uniform float jitter = 1.5; // Horizontal shake
uniform float dissolve_noise_scale = 20.0; // How "chunky" the crumble looks
uniform float lock_threshold = 0.; // Bottom 5% doesn't move
uniform float chunk_size = 4.0; // Try values like 2.0, 4.0, 8.0
float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = FRAGCOORD.xy;


	vec2 chunk_uv = floor(UV * chunk_size) / chunk_size;

    // Use noise for random crumble delay
    float noise = random(uv / dissolve_noise_scale);
	float height_factor = 1.0 - UV.y;

	height_factor = max(height_factor - lock_threshold, 0.0) / (1.0 - lock_threshold);

	float fall_start = smoothstep(0.0, 1.0, progress - noise);
    float y_offset = fall_start * progress * fall_speed * height_factor*10.0;

    // Pixels start falling after their noise value < progress


    // Vertical fall based on time
    //float y_offset = fall_start * progress * fall_speed;

    // Sideways jitter
    float x_offset = sin(uv.y * 10.0 + progress * 20.0) * jitter * fall_start;

    // Apply offset
    COLOR = texture(TEXTURE, UV + vec2(x_offset, -y_offset) / vec2(500,500));

    // Optional fade out over time
    //COLOR.a *= 1.0 - progress;
}