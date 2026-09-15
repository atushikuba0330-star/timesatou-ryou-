extends Sprite2D

@export var move_distance := 120.0
@export var duration := 0.15
@export var frame_delay := 0.04

func launch(pos: Vector2):
	global_position = pos
	frame = 0

	_play_animation.call_deferred()

	var tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		pos + Vector2(move_distance, 0),
		duration
	)

	await tween.finished
	queue_free()


func _play_animation():
	for i in range(hframes):
		frame = i
		await get_tree().create_timer(frame_delay).timeout
