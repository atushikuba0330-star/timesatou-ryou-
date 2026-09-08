extends Sprite2D

func _ready():

	$subthunder.visible = false
	$subthunder2.visible = false
	$subthunder3.visible = false
	$Mainethunder.visible = false

	$FlashLayer/FlashRect.modulate.a = 0.0


func launch(start_pos, end_pos):

	# 画面中央
	global_position = get_viewport_rect().size / 2

	frame = 0

	await _play_sparklastarts()

	queue_free()


func _play_sparklastarts():

	var sub_started := false
	var main_started := false

	for i in range(hframes * vframes):

		frame = i

		# 15フレーム目でサブサンダー
		if i == 15 and !sub_started:

			sub_started = true

			var screen_size = get_viewport_rect().size

			$subthunder.global_position = Vector2(
				randf_range(100, screen_size.x - 100),
				randf_range(100, screen_size.y - 100)
			)

			$subthunder2.global_position = Vector2(
				randf_range(100, screen_size.x - 100),
				randf_range(100, screen_size.y - 100)
			)

			$subthunder3.global_position = Vector2(
				randf_range(100, screen_size.x - 100),
				randf_range(100, screen_size.y - 100)
			)

			$subthunder.visible = true
			$subthunder2.visible = true
			$subthunder3.visible = true

			_play_sprite($subthunder)
			_play_sprite($subthunder2)
			_play_sprite($subthunder3)

		# 25フレーム目でメインサンダー
		if i == 25 and !main_started:

			main_started = true

			$Mainethunder.visible = true

			_play_mainthunder()

		await get_tree().create_timer(0.05).timeout


func _play_mainthunder():

	$Mainethunder.frame = 0

	var flash_started := false

	for i in range(
		$Mainethunder.hframes * $Mainethunder.vframes
	):

		$Mainethunder.frame = i

		# Mainethunderの7フレーム目
		if i == 4 and !flash_started:

			flash_started = true

			_flash_screen()

		await get_tree().create_timer(0.05).timeout

	$Mainethunder.visible = false


func _play_sprite(sprite: Sprite2D):

	sprite.frame = 0

	for i in range(sprite.hframes * sprite.vframes):

		sprite.frame = i

		await get_tree().create_timer(0.05).timeout

	sprite.visible = false


func _flash_screen():

	var flash = $FlashLayer/FlashRect

	flash.modulate.a = 0.0

	# フラッシュ
	var fade_in = create_tween()

	fade_in.tween_property(
		flash,
		"modulate:a",
		1.0,
		0.1
	)

	await fade_in.finished

	# 竜巻を巨大化＋消滅
	var cyclone_tween = create_tween()

	cyclone_tween.set_parallel(true)

	cyclone_tween.tween_property(
		self,
		"scale",
		Vector2(10, 10),
		2.0
	)

	cyclone_tween.tween_property(
		self,
		"rotation",
		deg_to_rad(1080),
		2.0
	)

	cyclone_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		2.0
	)

	await cyclone_tween.finished

	# フラッシュ解除
	var fade_out = create_tween()

	fade_out.tween_property(
		flash,
		"modulate:a",
		0.0,
		3.0
	)

	await fade_out.finished
