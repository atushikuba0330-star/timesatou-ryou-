extends Sprite2D

func _ready():

	$hollyshieldEffect.visible = false


func launch(start_pos, end_pos):

	# カードを置いたスロット位置
	global_position = start_pos + Vector2(110, 0)

	visible = true

	# hollyshield再生
	await _play_sprite(self)

	# hollyshieldEffect再生
	$hollyshieldEffect.visible = true

	await _play_sprite($hollyshieldEffect)

	queue_free()


func _play_sprite(sprite: Sprite2D):

	sprite.frame = 0

	var frames = sprite.hframes * sprite.vframes

	for i in range(frames):

		sprite.frame = i

		await get_tree().create_timer(0.05).timeout
