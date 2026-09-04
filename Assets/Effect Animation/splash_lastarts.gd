extends Sprite2D

@export var sub_count := 20

var spawned_subs := []

func launch(start_pos, end_pos):

	var screen_size = get_viewport_rect().size

	# 画面中央
	global_position = screen_size / 2

	scale = Vector2(0.1, 0.1)

	$subsplashlastarts.visible = false

	$FlashLayer/FlashRect.modulate.a = 0.0

	# メイン魔法陣出現
	var appear = create_tween()

	appear.set_parallel(true)

	appear.tween_property(
		self,
		"scale",
		Vector2(3, 3),
		1.5
	)

	appear.tween_property(
		self,
		"rotation",
		deg_to_rad(180),
		1.5
	)

	# サブ魔法陣生成
	var sub_template = $subsplashlastarts

	for i in range(sub_count):

		var sub = sub_template.duplicate()

		get_tree().current_scene.add_child(sub)

		sub.visible = true

		sub.global_position = Vector2(
			randf_range(50, screen_size.x - 50),
			randf_range(50, screen_size.y - 50)
		)

		sub.scale = Vector2(
			randf_range(0.4, 0.8),
			randf_range(0.4, 0.8)
		)

		spawned_subs.append(sub)

		var spin = sub.create_tween()

		spin.set_loops()

		spin.tween_property(
			sub,
			"rotation",
			TAU,
			randf_range(3.0, 6.0)
		)

	# 3秒待機
	await get_tree().create_timer(3.0).timeout

	# フラッシュ
	await _flash_screen()

	queue_free()


func _flash_screen():

	var flash = $FlashLayer/FlashRect

	# フラッシュ開始
	var flash_in = create_tween()

	flash_in.tween_property(
		flash,
		"modulate:a",
		1.0,
		0.1
	)

	await flash_in.finished

	# フラッシュ開始から2秒待つ
	await get_tree().create_timer(2.0).timeout

	# メイン魔法陣を画面外へ
	global_position = Vector2(-10000, -10000)

	# サブ魔法陣を画面外へ
	for sub in spawned_subs:

		if is_instance_valid(sub):
			sub.global_position = Vector2(-10000, -10000)

	# 白画面維持
	await get_tree().create_timer(10.0).timeout

	# フェードアウト
	var flash_out = create_tween()

	flash_out.tween_property(
		flash,
		"modulate:a",
		0.0,
		5.0
	)

	await flash_out.finished

	# サブ魔法陣削除
	for sub in spawned_subs:

		if is_instance_valid(sub):
			sub.queue_free()

	spawned_subs.clear()
