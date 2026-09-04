extends Sprite2D

func launch(start_pos, end_pos):

	visible = false

	await get_tree().create_timer(1.0).timeout

	global_position = end_pos +Vector2(130, 160)

	visible = true

	frame = 0

	await _play_animation()

	queue_free()


func _play_animation():

	for i in range(hframes * vframes):

		frame = i

		await get_tree().create_timer(0.05).timeout
