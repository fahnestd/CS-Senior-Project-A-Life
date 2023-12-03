shader_type canvas_item;

vec4 soft_light(vec4 base, vec4 blend){
	vec4 limit = step(0.5, blend);
	return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}

vec4 hard_light(vec4 base, vec4 blend){
	vec4 limit = step(0.5, blend);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

uniform float overlayAmount : hint_range(0, 1);

void fragment() {
    // Sample the texture color
    vec4 baseColor = texture(TEXTURE, UV);
	
    COLOR = hard_light(baseColor, COLOR) * overlayAmount;
}

