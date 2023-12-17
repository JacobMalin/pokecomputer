shader_type spatial;
render_mode depth_prepass_alpha;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D _albedo : hint_default_transparent;

uniform vec3 pos;
uniform vec3 neg;

uniform vec3 w_cam;
varying vec3 w_vtx;

void vertex() {
	w_vtx = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	bool pos_x = (pos.x - w_cam.x) > 0.0 && (pos.x - w_vtx.x) < 0.0;
	bool pos_y = (pos.y - w_cam.y) > 0.0 && (pos.y - w_vtx.y) < 0.0;
	bool pos_z = (pos.z - w_cam.z) > 0.0 && (pos.z - w_vtx.z) < 0.0;
	
	bool neg_x = (neg.x - w_cam.x) < 0.0 && (neg.x - w_vtx.x) > 0.0;
	bool neg_y = (neg.y - w_cam.y) < 0.0 && (neg.y - w_vtx.y) > 0.0;
	bool neg_z = (neg.z - w_cam.z) < 0.0 && (neg.z - w_vtx.z) > 0.0;
	
	if (!(pos_x || pos_y || pos_z || neg_x || neg_y || neg_z)) discard;
}