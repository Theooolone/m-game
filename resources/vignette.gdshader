shader_type canvas_item;

uniform vec4 color: source_color;

void fragment() {
	float value = distance(UV, vec2(0.5));
	COLOR = vec4(color.rgb, color.a*value);
}
