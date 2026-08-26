extends Node2D

var target_position: Vector2

func launch(start_pos, end_pos):

	global_position = start_pos

	target_position = end_pos

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		0.5
	)

	await tween.finished

	queue_free()
