extends Sprite2D

func launch(start_pos, end_pos):

	# 着弾位置へ表示
	global_position = end_pos+ Vector2(110, 00)

	frame = 0

	await _play_animation()

	queue_free()


func _play_animation():

	for i in range(hframes * vframes):

		frame = i

		await get_tree().create_timer(0.05).timeout
