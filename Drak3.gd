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

	# dark2表示
	dark2.visible = true

	# dark2を3回ループ
	for loop in range(dark2_loop_count):
		for i in range(dark2.hframes):
			dark2.frame = i
			await get_tree().create_timer(dark2_frame_delay).timeout

	# dark2非表示
	dark2.visible = false

	# 少し待つ
	await get_tree().create_timer(0.3).timeout

	# 魔法陣フェードアウト
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)

	await tween.finished

	queue_free()
