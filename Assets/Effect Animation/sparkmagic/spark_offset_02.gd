extends Sprite2D

func play_offset():

	frame = 0

	for i in range(hframes * vframes):

		frame = i

		await get_tree().create_timer(0.05).timeout
