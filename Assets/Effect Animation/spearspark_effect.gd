extends CPUParticles2D

func launch(start_pos, end_pos):

	# カードを置いたスロットで発生
	global_position = start_pos

	emitting = true

	await get_tree().create_timer(1.0).timeout

	emitting = false

	# 対面の敵スロットに落下
	$spearspark.global_position = end_pos

	$spearspark.visible = true

	await $spearspark.play_spark()

	queue_free()
