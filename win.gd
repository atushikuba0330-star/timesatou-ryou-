extends Control

func _ready() -> void:
	SePlayer.play_se("res://SE (1).wav")

func _on_button_pressed():
	get_tree().change_scene_to_file("res://reward.tscn")
