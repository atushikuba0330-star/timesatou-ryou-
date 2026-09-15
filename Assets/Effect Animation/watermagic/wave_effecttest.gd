extends CPUParticles2D

func launch(start_pos, end_pos):

	var screen_size = get_viewport_rect().size

	# 画面下中央
	global_position = Vector2(
		screen_size.x / 2,
		screen_size.y + 600
	)

	emitting = true

	# 粒子が全部出終わるまで待つ
	await get_tree().create_timer(lifetime + 1.0).timeout

	queue_free()
