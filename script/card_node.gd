extends Control

@export var data: CardData
var dragging = false
var power = 0
var chant_progress = 0

@onready var magic_holder = $Panel/Magicholder

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		
		var copy = duplicate()
		get_tree().root.add_child(copy)
		
		copy.global_position = get_global_mouse_position()
		copy.dragging = true

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

func update_magic_circle():
	if data == null:
		return

	for child in magic_holder.get_children():
		child.queue_free()

	var order = get_display_order()
	var count = min(chant_progress, order.size())

	for i in range(count):
		var index = order[i]

		if index >= data.magic_circles.size():
			continue
		if index >= data.magic_positions.size():
			continue

		var sprite = Sprite2D.new()
		sprite.texture = data.magic_circles[index]

		sprite.centered = true
		sprite.position = data.magic_positions[index]

		match index:
			0: # 中央
				sprite.scale = Vector2(0.3, 0.3)
			1,2,3: # 小
				sprite.scale = Vector2(0.2, 0.2)
			4: # 下（大）
				sprite.scale = Vector2(0.4, 0.4)


		sprite.z_as_relative = false
		sprite.z_index = 100

		magic_holder.add_child(sprite)


func get_display_order():
	match data.cast_time:
		1:
			return [0]
		2:
			return [1, 0]
		3:
			return [2, 1, 0]
		4:
			return [3, 2, 1, 0]
		5:
			return [4, 3, 2, 1, 0]
