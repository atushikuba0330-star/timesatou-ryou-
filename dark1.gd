extends Sprite2D

@export var frame_delay := 0.08

func launch(pos: Vector2):
	global_position = pos
	frame = 0

	scale = Vector2(0.5, 0.5)

	var tween = create_tween()
	tween.tween_property(
		self,
		"scale",
		Vector2(2.0, 2.0),
		0.25
	)

	for i in range(hframes):
		frame = i
		await get_tree().create_timer(frame_delay).timeout

	queue_free() 
