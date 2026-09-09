extends Control

var element = "fire"

var face_variants = [
	preload("res://Character files/20260726_045341526_iOS-removebg-preview.png"),
	preload("res://Character files/20260726_045341651_iOS-removebg-preview.png"),
	preload("res://Character files/20260726_045341689_iOS-removebg-preview.png"),
	]


func _ready():
	_show_random_face()
func _show_random_face():
	var random_face = face_variants[randi() % face_variants.size()]
	$face.texture = random_face
