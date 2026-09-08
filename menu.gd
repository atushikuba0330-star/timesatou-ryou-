extends Node2D

@onready var char_holder = $CharacterHolder

var character_scenes = [
	preload("res://CharaFire.tscn"),
	preload("res://CharaWater.tscn"),
	preload("res://CharaLight.tscn"),
	preload("res://CharaThunder.tscn"),
	preload("res://CharaDarkness.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready() :
	_show_random_character()

func _show_random_character():
	for child in char_holder.get_children():
		child.queue_free()

	var random_scene = character_scenes[randi() % character_scenes.size()]
	var char_instance = random_scene.instantiate()
	char_holder.add_child(char_instance)

	char_instance.position = Vector2(1200, 100)
	char_instance.scale = Vector2(1.0, 1.0)

	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	var base_y = char_instance.position.y
	tween.tween_property(char_instance, "position:y", base_y - 20, 1.5)
	tween.tween_property(char_instance, "position:y", base_y + 20, 1.5)
	
