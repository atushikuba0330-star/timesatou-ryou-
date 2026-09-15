extends Sprite2D

func _ready():

	$hollyloyal2.visible = false
	$hollybell.visible = false
	$FlashLayer/FlashRect.modulate.a = 0.0


func launch(start_pos, end_pos):

	global_position = start_pos + Vector2(110, -60)

	visible = true
	$hollyloyal2.visible = true

	# 同時再生
	await _play_pair(
		self,
		$hollyloyal2
	)

	# ベル再生
	$hollybell.visible = true

	await _play_sprite($hollybell)
	
	# エフェクトを画面外へ移動
	global_position = Vector2(-10000, -10000)

	# フラッシュ
	await _flash_screen()

	queue_free()


func _play_pair(
	sprite_a: Sprite2D,
	sprite_b: Sprite2D
):

	sprite_a.frame = 0
	sprite_b.frame = 0

	var frames = maxi(
		sprite_a.hframes * sprite_a.vframes,
		sprite_b.hframes * sprite_b.vframes
	)

	for i in range(frames):

		if i < sprite_a.hframes * sprite_a.vframes:
			sprite_a.frame = i

		if i < sprite_b.hframes * sprite_b.vframes:
			sprite_b.frame = i

		await get_tree().create_timer(0.05).timeout


func _play_sprite(sprite: Sprite2D):

	sprite.frame = 0

	for i in range(sprite.hframes * sprite.vframes):

		sprite.frame = i

		await get_tree().create_timer(0.05).timeout


func _flash_screen():

	var flash = $FlashLayer/FlashRect

	flash.modulate.a = 0

	var flash_in = create_tween()

	flash_in.tween_property(
		flash,
		"modulate:a",
		1.0,
		0.1
	)

	await flash_in.finished

	# 真っ白状態を1秒維持
	await get_tree().create_timer(1.5).timeout

	var fade_out = create_tween()

	fade_out.tween_property(
		flash,
		"modulate:a",
		0.0,
		3.0
	)

	await fade_out.finished
	
	
