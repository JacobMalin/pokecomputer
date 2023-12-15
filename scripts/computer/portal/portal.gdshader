shader_type spatial;
render_mode unshaded;

uniform sampler2D left_tex;
uniform sampler2D right_tex;

uniform float x_offset;
uniform float y_offset;

void vertex() {
}

void fragment() {
	if (VIEW_INDEX == VIEW_MONO_LEFT) {
		vec2 left_screen_uv = SCREEN_UV + vec2(x_offset, y_offset);
		ALBEDO = texture(left_tex, left_screen_uv).rgb;
	} else if (VIEW_INDEX == VIEW_RIGHT) {
		vec2 right_screen_uv = SCREEN_UV + vec2(-x_offset, y_offset);
		ALBEDO = texture(right_tex, right_screen_uv).rgb;
	}
	
	// Color correction
	ALBEDO = pow(ALBEDO, vec3(3));
}
