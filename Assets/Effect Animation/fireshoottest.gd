extends Sprite2D

func launch(start_pos, end_pos):

	global_position = start_pos

	frame = 0

	_play_animation()

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		end_pos,
		0.5
	)

	await tween.finished

	queue_free()


func _play_animation():

	for i in range(hframes):

		frame = i

		await get_tree().create_timer(0.05).timeout
