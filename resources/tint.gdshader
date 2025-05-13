shader_type canvas_item;

uniform sampler2D gradient_texture;

void fragment() {
	if (COLOR.x == COLOR.y && COLOR.y == COLOR.z) {
		COLOR.rgb = texture(gradient_texture, vec2(COLOR.r, 0)).rgb;
	}
}
