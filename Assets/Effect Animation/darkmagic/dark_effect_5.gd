extends Sprite2D

func _ready():

	$darksubEffect.visible = false
	$FlashLayer/FlashRect.modulate.a = 0.0


func launch(start_pos, end_pos):

	# 置いたスロットの上に表示
	global_position = start_pos + Vector2(110, -20)

	frame = 0

	await _play_dark_effect()

	queue_free()


func _play_dark_effect():

	var sub_started := false

	for i in range(hframes * vframes):

		frame = i

		# 46フレーム目でdarksubEffect開始
		if i == 46 and !sub_started:

			sub_started = true

			$darksubEffect.visible = true

			# 同時再生
			_play_dark_sub()

		await get_tree().create_timer(0.05).timeout


func _play_dark_sub():

	$darksubEffect.frame = 0

	var flash_started := false

	for i in range(
		$darksubEffect.hframes * $darksubEffect.vframes
	):

		$darksubEffect.frame = i

		# 8フレーム目でフラッシュ
		if i == 8 and !flash_started:

			flash_started = true

			_flash_screen()

		await get_tree().create_timer(0.05).timeout


func _flash_screen():

	var flash = $FlashLayer/FlashRect

	# 発動位置
	flash.position = Vector2.ZERO

	# 最初は小さく
	flash.scale = Vector2(0.01, 0.01)

	flash.modulate.a = 1.0

	var tween = create_tween()

	tween.set_parallel(true)

	# 円形に広がる
	tween.tween_property(
		flash,
		"scale",
		Vector2(50, 50),
		1.0
	)

	await tween.finished

	await get_tree().create_timer(1.0).timeout

	var fade = create_tween()

	fade.tween_property(
		flash,
		"modulate:a",
		0.0,
		3.0
	)

	await fade.finished

	await get_tree().create_timer(1.0).timeout

	var flash_out = create_tween()

	flash_out.tween_property(
		flash,
		"modulate:a",
		0.0,
		3.0
	)

	await flash_out.finished
