shader_type canvas_item;

// Parameters
uniform vec4 ice_tint : source_color = vec4(0.7, 0.85, 1.0, 1.0); // Ice blue color
uniform float tint_intensity : hint_range(0.0, 1.0) = 0.6; // How strong the tint is
uniform float icicle_height : hint_range(0.1, 1.0) = 0.3; // How long the icicles are
uniform int icicle_count : hint_range(3, 20) = 6; // Number of icicles
uniform float icicle_width : hint_range(0.01, 0.1) = 0.03; // Width of each icicle

void fragment() {
    // Sample the texture
    vec4 texture_color = texture(TEXTURE, UV);
    vec4 final_output = texture_color;

    if (texture_color.a >= 0.01) {
        // Apply ice tint to the whole sprite
        vec3 tinted_color = mix(texture_color.rgb, ice_tint.rgb, tint_intensity);

        // Edge detection for finding sprite boundaries
        vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));

        // Sample neighboring pixels for edge detection
        float alpha_center = texture_color.a;
        float alpha_up = texture(TEXTURE, UV + vec2(0.0, -pixel_size.y)).a;
        float alpha_down = texture(TEXTURE, UV + vec2(0.0, pixel_size.y)).a;
        float alpha_left = texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0)).a;
        float alpha_right = texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)).a;

        // Edge is where alpha changes
        float edge = abs(alpha_center - alpha_up) +
                     abs(alpha_center - alpha_down) +
                     abs(alpha_center - alpha_left) +
                     abs(alpha_center - alpha_right);

        // Detect bottom edges
        float bottom_edge = alpha_center > 0.5 && alpha_down < 0.5 ? 1.0 : 0.0;

        // Calculate distance to bottom edge of the sprite
        float dist_to_bottom = 0.0;
        for (float i = 0.0; i <= 1.0; i += 0.01) {
            vec2 check_pos = UV + vec2(0.0, i * 0.5);
            if (check_pos.y > 1.0) break;

            float check_alpha = texture(TEXTURE, check_pos).a;
            if (check_alpha < 0.5) {
                dist_to_bottom = i;
                break;
            }
        }

        // Create a smoother edge transition
        float edge_smooth = smoothstep(0.1, 0.5, edge) * 0.7;

        // Icicle effect - only on bottom edges and extending outside
        float icicle_effect = 0.0;

        // Add icicles beneath the sprite
        if (texture_color.a < 0.1) {
            // We're in transparent space

            // Check if we're below the sprite
            float above_check = 0.0;
            for (float i = 0.01; i < 0.3; i += 0.01) {
                if (UV.y - i < 0.0) break;
                above_check = max(above_check, texture(TEXTURE, vec2(UV.x, UV.y - i)).a);
            }

            if (above_check > 0.5) {
                // We're below the sprite, create icicles
                for (int i = 0; i < icicle_count; i++) {
                    // Convert the int to float before arithmetic operations
                    float i_float = float(i);
                    float count_float = float(icicle_count);

                    // Calculate center position for this icicle
                    float center_x = (i_float + 0.5) / count_float;

                    // Add variation
                    center_x += sin(center_x * 57.32 + TIME * 0.1) * 0.03;

                    float dist = abs(UV.x - center_x);
                    if (dist < icicle_width) {
                        // Calculate height for this icicle
                        float this_height = icicle_height * (0.7 + sin(center_x * 23.45) * 0.3);

                        // Distance from sprite bottom
                        float y_dist = UV.y;
                        for (float j = 0.0; j < 0.5; j += 0.01) {
                            float sample_alpha = texture(TEXTURE, vec2(UV.x, UV.y - j)).a;
                            if (sample_alpha > 0.5) {
                                y_dist = j;
                                break;
                            }
                        }

                        // Create tapered shape
                        float y_factor = y_dist / this_height;
                        float x_factor = 1.0 - pow(dist / icicle_width, 2.0);

                        if (y_factor < 1.0) {
                            float icicle = x_factor * (1.0 - y_factor);
                            icicle_effect = max(icicle_effect, icicle);
                        }
                    }
                }
            }
        }

        // Combine effects: tinted sprite, ice outline, and external icicles
        vec3 outline_color = mix(tinted_color, ice_tint.rgb * 1.3, edge_smooth);

        // If we're inside the sprite
        if (texture_color.a > 0.5) {
            final_output = vec4(outline_color, texture_color.a);
        } else {
            // If we're in an icicle outside the sprite
            if (icicle_effect > 0.0) {
                vec3 icicle_color = ice_tint.rgb * (1.2 + 0.3 * sin(UV.x * 10.0 + TIME));
                final_output = vec4(icicle_color, icicle_effect * 0.8);
            }
        }
    }

    COLOR = final_output;
}