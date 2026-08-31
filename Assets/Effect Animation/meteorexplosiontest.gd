extends Sprite2D

func _ready():
	visible = false


func play_explosion():

	visible = true

	frame = 0

	for i in range(hframes * vframes):

		frame = i

		await get_tree().create_timer(0.05).timeout
