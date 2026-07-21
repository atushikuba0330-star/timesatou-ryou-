class_name CardVisualEffects
extends RefCounted

# card_node.gd から見た目に関する処理（魔法陣アニメーション・消滅演出）だけを
# 切り出したユーティリティ。card は CardNode(Control) のインスタンスを想定。

static func get_display_order(actual_cast_time: int) -> Array:
	match actual_cast_time:
		1:
			return [0]
		2:
			return [1, 0]
		3:
			return [2, 1, 0]
		4:
			return [3, 2, 1, 0]
		5:
			return [4, 3, 2, 1, 0]
	return []

static func update_magic_circle(card) -> void:
	if card.data == null:
		return

	var order = get_display_order(card.actual_cast_time)
	var target_count = min(card.chant_progress, card.actual_cast_time)
	target_count = min(target_count, order.size())

	var current_count = card.magic_holder.get_child_count()

	for i in range(current_count, target_count):
		var index = order[i]

		if index >= card.data.magic_circles.size():
			continue
		if index >= card.data.magic_positions.size():
			continue

		var sprite = Sprite2D.new()
		sprite.texture = card.data.magic_circles[index]

		sprite.centered = true
		sprite.position = card.data.magic_positions[index]

		var target_scale

		match index:
			0:
				target_scale = Vector2(0.3, 0.3)
			1, 2, 3:
				target_scale = Vector2(0.2, 0.2)
			4:
				target_scale = Vector2(0.4, 0.4)

		sprite.scale = Vector2(0.05, 0.05)

		sprite.z_as_relative = false
		sprite.z_index = 100

		card.magic_holder.add_child(sprite)

		var tween = card.create_tween()
		tween.tween_property(sprite, "scale", target_scale, 0.2)

static func play_zoom_out(card) -> void:
	var i = 0

	for child in card.magic_holder.get_children():
		var tween = card.create_tween()

		tween.tween_interval(i * 0.08)

		tween.tween_property(child, "scale", Vector2(0.05, 0.05), 0.2)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN)

		i += 1

	await card.get_tree().create_timer(0.2).timeout

static func play_break_apart(card) -> void:
	card.set_process(false)

	var pieces = card.magic_holder.get_children()

	if pieces.size() == 0:
		var tween = card.create_tween()
		tween.tween_property(card, "modulate:a", 0.0, 0.3)
		await tween.finished
		return

	for sprite in pieces:
		var mat = ShaderMaterial.new()
		mat.shader = load("res://dissolve.gdshader")

		var noise = FastNoiseLite.new()
		noise.seed = randi()
		var noise_tex = NoiseTexture2D.new()
		noise_tex.noise = noise
		noise_tex.width = 64
		noise_tex.height = 64
		mat.set_shader_parameter("noise_texture", noise_tex)

		sprite.material = mat

		var tween = card.create_tween()
		tween.tween_method(
			func(v): mat.set_shader_parameter("dissolve_amount", v),
			0.0, 1.0, 0.6
		)
		tween.tween_callback(sprite.queue_free)

	var card_tween = card.create_tween()
	card_tween.tween_property(card, "modulate:a", 0.0, 0.4)

	await card.get_tree().create_timer(0.6).timeout
