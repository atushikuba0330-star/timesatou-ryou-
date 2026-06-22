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
	
	for child in magic_holder.get_children():
		child.rotation += delta

		
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

	var order = get_display_order()
	var target_count = min(chant_progress, data.cast_time)
	target_count = min(target_count, order.size())

	var current_count = magic_holder.get_child_count()

	for i in range(current_count, target_count):
		var index = order[i]

		if index >= data.magic_circles.size():
			continue
		if index >= data.magic_positions.size():
			continue

		var sprite = Sprite2D.new()
		sprite.texture = data.magic_circles[index]

		sprite.centered = true
		sprite.position = data.magic_positions[index]

		var target_scale

		match index:
			0: 
				target_scale = Vector2(0.3, 0.3)
			1,2,3: 
				target_scale = Vector2(0.2, 0.2)
			4:
				target_scale = Vector2(0.4, 0.4)
		
		sprite.scale = Vector2(0.05, 0.05)
		
		sprite.z_as_relative = false
		sprite.z_index = 100

		magic_holder.add_child(sprite)
		
		var tween = create_tween()
		tween.tween_property(sprite, "scale", target_scale, 0.2)

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
			

func play_zoom_out():
	
	var i = 0
	
	for child in magic_holder.get_children():
		var tween = create_tween()
		
		tween.tween_interval(i * 0.08)
		
		tween.tween_property(child, "scale", Vector2(0.05, 0.05), 0.2)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN)
		
		i += 1

	await get_tree().create_timer(0.2).timeout
