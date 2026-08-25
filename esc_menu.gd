extends CanvasLayer

func _ready():
	visible = false

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		var current_scene = get_tree().current_scene.name
		if current_scene == "Main":  # ← バトルシーン名に合わせて変更
			toggle_menu()


func toggle_menu():
	visible = not visible
	get_tree().paused = visible

func _on_resume_pressed():
	toggle_menu()

func _on_title_pressed():
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://menu.tscn")
	BgmPlayer.play_bgm("Home")
