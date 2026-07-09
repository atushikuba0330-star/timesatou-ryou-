extends Node

@onready var se_player = $AudioStreamPlayer

func play_se(path: String):
	se_player.stream = load(path)
	se_player.play()
