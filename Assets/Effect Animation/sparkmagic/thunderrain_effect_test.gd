extends CPUParticles2D

func launch(start_pos, end_pos):

	global_position = end_pos+ Vector2(160, 180)

	emitting = true

	# 2秒間表示
	await get_tree().create_timer(2.0).timeout

	emitting = false

	# 残った粒子が消えるまで少し待つ
	await get_tree().create_timer(1.0).timeout

	queue_free()
