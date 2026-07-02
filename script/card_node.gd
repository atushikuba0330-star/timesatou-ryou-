extends Control

@export var data: CardData
var dragging = false
var power = 0
var chant_progress = 0

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		
		var copy = duplicate()
		get_tree().root.add_child(copy)
		
		copy.global_position = get_global_mouse_position()
		copy.dragging = true

@warning_ignore("unused_parameter")
func _process(delta):
	if dragging:
		global_position = get_global_mouse_position()
		
func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		if dragging:
			try_place()
			dragging = false
		
func try_place():
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			if slot.can_place():
				slot.place(self)
				return
	
	queue_free()

func _ready():
	if data:
		$Panel/TextureRect.texture = data.icon
		$Panel/Label.text = data.name
		power = data.power
