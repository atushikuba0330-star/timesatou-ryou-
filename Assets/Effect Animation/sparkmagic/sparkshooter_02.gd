extends Sprite2D

func _ready():

	$sparkOffset02.visible = false


func launch(start_pos, end_pos):

	await get_tree().create_timer(1.0).timeout

	global_position = end_pos + Vector2(110, -100)

	visible = true

	frame = 0

	# sparkshooter02再生
	await _play_animation()

	# shooterを消す
	

	# sparkOffset02表示
	$sparkOffset02.visible = true

	# sparkOffset02再生
	await $sparkOffset02.play_offset()

	queue_free()


func _play_animation():

	for i in range(hframes * vframes):

		frame = i

		await get_tree().create_timer(0.05).timeout
