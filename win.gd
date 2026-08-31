extends Control

func _ready() -> void:
	SePlayer.play_se("res://audiostock_1604995.mp3")


func _on_button_pressed():
	get_tree().change_scene_to_file("res://reward.tscn")
	SePlayer.play_se("res://SE (1).wav")
