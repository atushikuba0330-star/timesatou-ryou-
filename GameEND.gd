extends Button

func _on_pressed() -> void:
	SePlayer.play_se("res://SE (1).wav")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
