extends Sprite2D

func _ready():

	$hollyartsshield.visible = false


func launch(start_pos, end_pos):

	# 対面スロット位置
	global_position = end_pos

	scale = Vector2.ONE

	# hollyarts再生
	await _play_until_14(self)
	


	# shield表示
	$hollyartsshield.visible = true

	await _play_until_14($hollyartsshield)

	# ゆっくり縮小
	var tween = create_tween()

	tween.tween_property(
		self,
		"scale",
		Vector2.ZERO,
		1.5
	)

	await tween.finished

	queue_free()


func _play_until_14(sprite: Sprite2D):

	sprite.frame = 0

	var stop_frame := 11

	var max_frame :=(sprite.hframes * sprite.vframes) - 1

	stop_frame = min(stop_frame, max_frame)

	for i in range(stop_frame + 1):

		sprite.frame = i

		await get_tree().create_timer(0.05).timeout

	# 14フレーム目で停止
	sprite.frame = stop_frame
