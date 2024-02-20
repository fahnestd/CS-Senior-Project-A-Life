shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// Get the original fragment color
    vec4 originalColor = texture(TEXTURE, UV);

    // Set the alpha component to 20% (0.2)
    originalColor.a = 0.5;

    // Output the modified color
    COLOR = originalColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
