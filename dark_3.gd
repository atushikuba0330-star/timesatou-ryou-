extends Sprite2D

@export var frame_delay := 0.1

func launch(from_position: Vector2, to_position: Vector2):

	# 対面スロットに表示
	global_position = to_position + Vector2(115, 140)

	frame = 0
	visible = true

	await _play_animation()

	queue_free()

func _play_animation() -> void:

	for i in range(hframes * vframes):
		frame = i

		await get_tree().create_timer(frame_delay).timeout
