extends Sprite2D

func _ready():

	$meteorexplosion.visible = false
	$FlashLayer/FlashRect.modulate.a = 0.0


func launch(start_pos, end_pos):

	# スロット位置で発動
	global_position = start_pos

	# firelastarts再生
	await _play_firelastarts()

	# meteorexplosion再生
	$meteorexplosion.visible = true

	await _play_explosion()

	queue_free()


func _play_firelastarts():

	frame = 0

	for i in range(hframes * vframes):

		frame = i

		await get_tree().create_timer(0.05).timeout


func _play_explosion():

	$meteorexplosion.frame = 0

	var flash_started := false

	var total_frames = (
		$meteorexplosion.hframes *
		$meteorexplosion.vframes
	)

	for i in range(total_frames):

		$meteorexplosion.frame = i

		# 10フレーム目でFlash
		if i == 10 and !flash_started:

			flash_started = true

			_flash_screen()

		await get_tree().create_timer(0.05).timeout

	$meteorexplosion.visible = false


func _flash_screen():

	var flash = $FlashLayer/FlashRect

	flash.modulate.a = 0.0

	var fade_in = create_tween()

	fade_in.tween_property(
		flash,
		"modulate:a",
		1.0,
		0.1
	)

	await fade_in.finished

	var fade_out = create_tween()

	fade_out.tween_property(
		flash,
		"modulate:a",
		0.0,
		2.0
	)
