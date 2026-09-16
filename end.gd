extends Button

@onready var desc_label = $"../Label"
@export var description_text: String = "" 

func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _on_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://titole.tscn")
	SePlayer.play_se("res://audiostock_60330.mp3")

func _on_mouse_entered():
	desc_label.text = description_text
	desc_label.visible = true

func _on_mouse_exited():
	desc_label.visible = false
