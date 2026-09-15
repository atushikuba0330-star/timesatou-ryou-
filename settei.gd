extends Node2D

@onready var char_holder = $char_holder

var character_scenes = [
	preload("res://CharaFireFece.tscn"),
	preload("res://CharaWaterFace.tscn"),
	preload("res://CharaLightFace.tscn"),
	preload("res://CharaThunderFace.tscn"),
	preload("res://CharaDarknessFace.tscn"),
	]


func _show_random_character():
	for child in char_holder.get_children():
		child.queue_free()
		
		
	var scene = character_scenes[randi() % character_scenes.size()]
	var char_instance = scene.instantiate()
	char_holder.add_child(char_instance)


	char_instance.position = Vector2(500, 200)
	char_instance.scale = Vector2(2.0, 2.0)


	var base_y = char_instance.position.y
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(char_instance, "position:y", base_y - 20, 1.5)
	tween.tween_property(char_instance, "position:y", base_y + 20, 1.5)

func _ready():
	_show_random_character()
