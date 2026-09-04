extends Sprite2D

func launch(start_pos, end_pos):

	# 発射位置を右へ50px
	global_position = start_pos + Vector2(100, 0)

	frame = 0

	_play_animation()

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		end_pos + Vector2(100, 0), # 着弾地点も右へ50px
		0.5
	)

	await tween.finished

	queue_free()


func _play_animation():

	for i in range(hframes):

		frame = i

		await get_tree().create_timer(0.05).timeout
