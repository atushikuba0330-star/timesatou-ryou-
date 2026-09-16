extends Sprite2D

@export var frame_delay := 0.05
@export var dark2_frame_delay := 0.08
@export var dark2_loop_count := 3

@onready var dark2 = $dark2

func launch(from_position: Vector2, to_position: Vector2):

	# 発生位置調整
	global_position = to_position + Vector2(110, 200)

	frame = 0
	visible = true
	modulate.a = 1.0

	dark2.visible = false
	dark2.frame = 0

	await _play_animation()

func _play_animation() -> void:

	# 魔法陣アニメーション
	for i in range(hframes):
		frame = i
		await get_tree().create_timer(frame_delay).timeout
