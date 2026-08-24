extends Button


func _on_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://menu.tscn")
	SePlayer.play_se("res://SE (1).wav")
