extends Sprite2D

@export var move_time := 0.4

func launch(start_pos: Vector2, end_pos: Vector2):
	global_position = start_pos

	# 飛ぶ方向を向く
	rotation = (end_pos - start_pos).angle()

	frame = 0

	# アニメーションを並列実行
	_play_animation.call_deferred()

	# 移動
	var tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		end_pos,
		move_time
	)

	await tween.finished
	queue_free()


func _play_animation():
	for loop_count in range(4): # 4回ループ
		for i in range(hframes):
			frame = i
			await get_tree().create_timer(0.05).timeout

	frame = 0
