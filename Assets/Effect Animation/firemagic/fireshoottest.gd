extends Sprite2D

func launch(start_pos, end_pos):

	global_position = start_pos + Vector2(100, 130)

	# 向きを自動判定
	if start_pos.y < end_pos.y:
		rotation_degrees = 180
	else:
		rotation_degrees = 0

	frame = 0

	

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		end_pos + Vector2(100, 130),
		0.3
	)

	await tween.finished

	queue_free()
