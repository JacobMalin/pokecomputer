shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D left_tex : source_color;
uniform sampler2D right_tex : source_color;

void vertex() {
}

void fragment() {
	vec2 manual_screen_uv = UV;
	
	if (VIEW_INDEX == VIEW_MONO_LEFT) { 
	ALBEDO = texture(right_tex, UV).rgb;
	} else if (VIEW_INDEX == VIEW_RIGHT) {
	ALBEDO = texture(right_tex, UV).rgb;
	} 
}
