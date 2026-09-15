extends CPUParticles2D

func launch(start_pos, end_pos):

	# 敵側なら反転
	if start_pos.y > end_pos.y:

		gravity = Vector2(0, -980)

	else:

		gravity = Vector2(0, 980)

	# カードを置いたスロットで発生
	global_position = start_pos + Vector2(130, 0)

	emitting = true

	await get_tree().create_timer(1.0).timeout

	emitting = false

	# 対面スロットへ
	$spearspark.global_position = end_pos + Vector2(110, 0)

	$spearspark.visible = true

	await $spearspark.play_spark()

	queue_free()
