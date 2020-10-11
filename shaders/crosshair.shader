shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 cs = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgba;
	vec4 c = textureLod(TEXTURE, UV, 0.0).rgba;
	cs.rgb = vec3(1.0) - cs.rgb;
	COLOR.rgb = cs.rgb;
	COLOR.a = c.a;
	COLOR.r += 0.1;
	COLOR.g += 0.1;
	COLOR.b += 0.1;
}