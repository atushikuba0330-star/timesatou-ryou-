extends Sprite2D




func launch(start_pos, end_pos):

	# カードを置いたスロット位置
	global_position = start_pos

	# 4→0へ逆再生
	await _play_reverse()

	# 対面スロットへ移動
	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		end_pos,
		0.5
	)

	await tween.finished

	# 爆発
	$darkartsexplosion.visible = true

	await _play_sprite(
		$darkartsexplosion
	)

	queue_free()


func _play_reverse():

	for i in range(4, -1, -1):

		frame = i

		await get_tree().create_timer(0.07).timeout


func _play_sprite(sprite: Sprite2D):

	sprite.frame = 0

	var total_frames =sprite.hframes * sprite.vframes

	for i in range(total_frames):

		sprite.frame = i

		await get_tree().create_timer(0.05).timeout

	sprite.visible = false
