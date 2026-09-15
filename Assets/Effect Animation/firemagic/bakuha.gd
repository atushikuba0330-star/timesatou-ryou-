extends Sprite2D

@export var move_time := 0.4
@export var frame_delay := 0.15

@onready var fire_spark = $fireSpark

func launch(start_pos: Vector2, end_pos: Vector2):
	global_position = end_pos + Vector2(100, 130)

	# fireSparkを隠しておく
	fire_spark.visible = false

	frame = 0

	_play_animation.call_deferred()

	var tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		end_pos + Vector2(100, 130),
		move_time
	)

	await tween.finished


func _play_animation():
	# bakuha再生
	for loop_count in range(8):
		for i in range(hframes):
			frame = i
			await get_tree().create_timer(frame_delay).timeout

	frame = 0

	# fireSpark表示
	fire_spark.visible = true

	# fireSpark再生
	for i in range(fire_spark.hframes):
		fire_spark.frame = i
		await get_tree().create_timer(frame_delay).timeout

	queue_free()
