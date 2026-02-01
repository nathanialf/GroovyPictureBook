shader_type canvas_item;

uniform sampler2D page_tex;
uniform sampler2D mask_tex;

void vertex() {
}

void fragment() {
	vec3 rgb = texture(page_tex, UV).rgb;
	float a = texture(mask_tex, UV).r;
	COLOR = vec4(rgb, a);
}