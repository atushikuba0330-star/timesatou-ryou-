shader_type canvas_item;

uniform float rotation_angle : hint_range(0.0, 6.283185) = 0.0;
uniform float squish : hint_range(0.05, 1.0) = 0.4; // 楕円の潰れ具合
uniform vec2 center = vec2(0.5, 0.84); // 楕円の中心(絵の中でのUV座標)

void fragment() {
	vec2 centered = UV - center;

	// 縦方向の潰れを一旦戻して、正円の状態にする
	centered.y /= squish;

	float s = sin(rotation_angle);
	float c = cos(rotation_angle);
	vec2 rotated = vec2(
		centered.x * c - centered.y * s,
		centered.x * s + centered.y * c
	);

	// 楕円の潰れ具合に戻す
	rotated.y *= squish;

	vec2 rotated_uv = rotated + center;

	if (rotated_uv.x < 0.0 || rotated_uv.x > 1.0 || rotated_uv.y < 0.0 || rotated_uv.y > 1.0) {
		COLOR = vec4(0.0);
	} else {
		COLOR = texture(TEXTURE, rotated_uv);
	}
}