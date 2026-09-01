extends Sprite2D

@export var magic_scale := 4.0
@export var expand_time := 5.0
@export var rain_time := 5.0


func launch(start_pos, end_pos):

	# 画面中央
	global_position = get_viewport_rect().size / 2

	# 初期サイズ
	scale = Vector2(0.1, 0.1)

	# 雨停止
	$rainEffectTest.emitting = false

	# 拡大＋回転
	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		self,
		"scale",
		Vector2(magic_scale, magic_scale),
		expand_time
	)

	# ゆっくり2周回転
	tween.tween_property(
		self,
		"rotation",
		TAU * 2,
		expand_time
	)

	await tween.finished

	# 雨開始
	$rainEffectTest.emitting = true

	await get_tree().create_timer(rain_time).timeout

	# 雨停止
	$rainEffectTest.emitting = false

	# 残粒子待ち
	await get_tree().create_timer(2.0).timeout

	queue_free()
