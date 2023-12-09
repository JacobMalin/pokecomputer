shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D left_tex : source_color;
uniform sampler2D right_tex : source_color;

uniform vec3 v_local_position = vec3(0.0);
varying vec2 v_normalized_screen_position;

void vertex() {
	vec2 v_clip_position = (PROJECTION_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0)).xy;
	v_normalized_screen_position = v_clip_position * 0.5 + vec2(0.5); // [-1.0, 1.0] -> [0.0, 1.0]
}

void fragment() {
	if (VIEW_INDEX == VIEW_MONO_LEFT) { 
	ALBEDO = texture(left_tex, SCREEN_UV).rgb;
	} else if (VIEW_INDEX == VIEW_RIGHT) {
	ALBEDO = texture(right_tex, SCREEN_UV).rgb;
	} 
}
