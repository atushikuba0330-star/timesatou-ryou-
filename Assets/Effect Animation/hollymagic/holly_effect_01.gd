extends Sprite2D

func _ready():

	$hollyparticle01.visible = false
	$shieldEffect.visible = false


func launch(start_pos, end_pos):

	# カードを置いたスロット位置
	global_position = start_pos + Vector2(90, 0)

	frame = 0

	await _play_holly_effect()

	queue_free()


func _play_holly_effect():

	var particle_started := false

	for i in range(hframes * vframes):

		frame = i

		# 5フレーム後にパーティクル開始
		if i == 5 and not particle_started:

			particle_started = true

			$hollyparticle01.visible = true

			# 同時再生
			$hollyparticle01.play_particle()

		await get_tree().create_timer(0.05).timeout

	# hollyEffect終了待ち
	await get_tree().create_timer(0.2).timeout

	# shieldEffect開始
	$shieldEffect.visible = true

	await _play_sprite($shieldEffect)


func _play_sprite(sprite: Sprite2D):

	sprite.frame = 0

	for i in range(sprite.hframes * sprite.vframes):

		sprite.frame = i

		await get_tree().create_timer(0.05).timeout
