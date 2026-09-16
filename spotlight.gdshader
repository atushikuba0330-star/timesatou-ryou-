shader_type canvas_item;

// ハイライトしたい場所(画面のUV座標、0.0〜1.0)
uniform vec2 hole_position = vec2(0.5, 0.5);
// 穴の大きさ(UV座標での半幅・半高さ)
uniform vec2 hole_size = vec2(0.2, 0.1);
// 2つ目の穴(使わない時は hole2_size を 0 にしておく)
uniform vec2 hole2_position = vec2(0.5, 0.5);
uniform vec2 hole2_size = vec2(0.0, 0.0);
// 縁をどれくらいぼかすか(0で境界がくっきり、大きいほど滑らかに透明へ)
uniform float edge_softness = 0.02;
// 暗くする色
uniform vec4 dark_color : source_color = vec4(0.0, 0.0, 0.0, 0.7);

void fragment() {
	vec2 diff1 = abs(UV - hole_position) - hole_size;
	float outside1 = max(diff1.x, diff1.y);

	float outside = outside1;

	// 穴2が使われている時だけ判定に加える(サイズが0なら無視)
	if (hole2_size.x > 0.0 || hole2_size.y > 0.0) {
		vec2 diff2 = abs(UV - hole2_position) - hole2_size;
		float outside2 = max(diff2.x, diff2.y);
		outside = min(outside1, outside2);
	}

	float alpha = smoothstep(0.0, edge_softness, outside);
	COLOR = vec4(dark_color.rgb, dark_color.a * alpha);
}
