extends Sprite2D

func _ready():

	$lastartssatellite.visible = false


func launch(start_pos, end_pos):

	# カードを置いたスロットの対面で発動
	global_position = end_pos

	# hollylastarts再生
	await _play_sprite(self)

	

	# satellite発射
	$lastartssatellite.visible = true

	$lastartssatellite.global_position = global_position

	var tween = create_tween()

	tween.tween_property(
		$lastartssatellite,
		"global_position",
		end_pos,
		0.5
	)

	await tween.finished

	queue_free()


func _play_sprite(sprite: Sprite2D):

	sprite.frame = 0

	var total_frames =sprite.hframes * sprite.vframes

	for i in range(total_frames):

		sprite.frame = i

		await get_tree().create_timer(0.05).timeout
