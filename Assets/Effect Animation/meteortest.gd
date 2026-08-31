extends Sprite2D

func _ready():
	$meteorexplosion.visible = false


func launch(start_pos, end_pos):

	# 対面スロットに落とす
	global_position = end_pos+ Vector2(200, 30)

	frame = 0

	await _play_meteor_animation()



	# 爆発表示
	$meteorexplosion.visible = true

	await $meteorexplosion.play_explosion()

	queue_free()


func _play_meteor_animation():

	for i in range(hframes * vframes):

		frame = i

		await get_tree().create_timer(0.05).timeout
