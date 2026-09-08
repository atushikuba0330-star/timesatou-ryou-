extends Sprite2D

func _ready():

	$hollysatellite.visible = false
	$hollyOffset.visible = false


func launch(start_pos, end_pos):

	global_position = end_pos+ Vector2(100, 0)

	frame = 0

	await _play_satellite()

	queue_free()


func _play_satellite():

	var effect_started := false

	for i in range(hframes * vframes):

		frame = i

		# 4フレーム目で同時再生
		if i == 4 and not effect_started:

			effect_started = true

			$hollysatellite.visible = true
			$hollyOffset.visible = true

			if $hollysatellite.has_method("play_effect"):
				$hollysatellite.play_effect()

			if $hollyOffset.has_method("play_effect"):
				$hollyOffset.play_effect()

		await get_tree().create_timer(0.05).timeout
