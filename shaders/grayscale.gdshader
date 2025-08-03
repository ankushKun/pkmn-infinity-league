shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 color = texture(TEXTURE, UV);
	// Calculate luminance for grayscale
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	// Apply grayscale and preserve alpha
	COLOR = vec4(vec3(gray), color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
