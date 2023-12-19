shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_disable;

uniform bool override;
uniform vec3 pos;
uniform vec3 neg;

uniform vec3 w_cam;
varying vec3 w_vtx;

void vertex() {
	w_vtx = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	bool inside = pos.x > w_vtx.x && pos.y > w_vtx.y && pos.z > w_vtx.z && 
				  neg.x < w_vtx.x && neg.y < w_vtx.y && neg.z < w_vtx.z;
	
	if (!override && !inside) discard;
	
	vec4 albedo_tex = texture(texture_albedo,UV);
	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.05;
}