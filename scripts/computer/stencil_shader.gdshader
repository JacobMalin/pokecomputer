shader_type canvas_item;

uniform int eye;
uniform sampler2D stencil_tex;
 
void fragment() {
	COLOR.a = texture(stencil_tex, UV).g;
}