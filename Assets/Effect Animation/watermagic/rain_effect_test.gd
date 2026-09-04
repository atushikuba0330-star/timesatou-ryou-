extends CPUParticles2D

func launch(start_pos, end_pos):

	global_position = Vector2(640, 0)

	emitting = true

	await get_tree().create_timer(10.0).timeout

	emitting = false

	await get_tree().create_timer(2.0).timeout

	queue_free()
