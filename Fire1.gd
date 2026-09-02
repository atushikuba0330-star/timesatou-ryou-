extends Sprite2D

@export var move_time := 0.5
@export var life_time := 0.5

func launch(start_pos: Vector2, end_pos: Vector2):
	global_position = start_pos
	frame = 0

	_play_animation()

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"global_position",
		end_pos,
		move_time
	)

	tween.parallel().tween_property(
		self,
		"rotation_degrees",
		360,
		life_time
	)

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2(2.0, 2.0),
		life_time
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		life_time
	)

	await tween.finished
	queue_free()


func _play_animation():
	for i in range(hframes):
		frame = i
		await get_tree().create_timer(0.05).timeout
