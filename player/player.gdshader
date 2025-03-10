shader_type canvas_item;





void fragment() {
    vec2 uv = UV;
    float edge_factor = smoothstep(0.4, 0.5, min(uv.x, 1.0 - uv.x)) *
                        smoothstep(0.4, 0.5, min(uv.y, 1.0 - uv.y));
    COLOR = vec4(1.0, 0.0, 0.0, edge_factor * 0.6);  // Red tint with transparency
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
