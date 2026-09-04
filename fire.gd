extends Sprite2D

@export var move_time := 0.4
@export var frame_delay := 0.15

func launch(start_pos: Vector2, end_pos: Vector2):
	global_position = end_pos+ Vector2(100, 130)

	frame = 0

	_play_animation.call_deferred()

	var tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		end_pos + Vector2(100, 130), # 着弾地点も右へ50px
		move_time
	)

	await tween.finished
	queue_free()


func _play_animation():
	for loop_count in range(8):
		for i in range(hframes):
			frame = i
			await get_tree().create_timer(frame_delay).timeout

	frame = 0
