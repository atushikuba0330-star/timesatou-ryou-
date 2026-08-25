shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float noise = texture(noise_texture, UV).r;
	
	if (noise < dissolve_amount) {
		discard;
	}
	
	// 消える境界を光らせる
	float edge = smoothstep(dissolve_amount, dissolve_amount + 0.1, noise);
	color.rgb += (1.0 - edge) * vec3(0.5, 0.3, 1.0);
	
	COLOR = color;
}
