extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BgmPlayer.play_bgm("battle")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
	BgmPlayer.play_bgm("home")  # ← メニュー用BGMに切り替え
