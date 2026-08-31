extends Node2D

func launch(start_pos, end_pos):

	global_position = start_pos

	$AnimationPlayer.play("RESET")

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		end_pos,
		0.5
	)

	await tween.finished

	queue_free()
