extends Control
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func fly_to(target_position: Vector2) -> void:

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 1.0)
	await tween.finished
	queue_free()
