extends Sprite2D

func _ready():

	var tween = create_tween()

	tween.set_loops()

	tween.tween_property(
		self,
		"rotation",
		TAU,
		4.0
	)
