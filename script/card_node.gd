extends Control

@export var data: CardData
var dragging = false
var power = 0
var chant_progress = 0
var locked: bool = false

@onready var magic_holder = $Panel/Magicholder
@onready var label_ability_count = $Panel/LabelAbilityCount
@onready var chain_overlay = $Panel/ChainOverlay

func _gui_input(event):
	if locked:
		return  # ロック中はドラッグできない
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
	
	update_ability_count()

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
		if data.icon:
			$Panel/TextureRect.texture = data.icon
		$Panel/Label.text = data.name
		power = data.power
	if chain_overlay:
		chain_overlay.visible = locked

func set_locked(value: bool):
	locked = value
	if chain_overlay:
		chain_overlay.visible = value

func get_current_power() -> int:
	if data == null:
		return 0
	return int(data.power * (float(chant_progress) / float(data.cast_time)))
	
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

func play_break_apart():
	set_process(false)
	
	var pieces = magic_holder.get_children()
	
	if pieces.size() == 0:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		await tween.finished
		return
	
	for sprite in pieces:
		var mat = ShaderMaterial.new()
		mat.shader = load("res://dissolve.gdshader")
		
		var noise = FastNoiseLite.new()
		noise.seed = randi()
		var noise_tex = NoiseTexture2D.new()
		noise_tex.noise = noise
		noise_tex.width = 64
		noise_tex.height = 64
		mat.set_shader_parameter("noise_texture", noise_tex)
		
		sprite.material = mat
		
		var tween = create_tween()
		tween.tween_method(
			func(v): mat.set_shader_parameter("dissolve_amount", v),
			0.0, 1.0, 0.6
		)
		tween.tween_callback(sprite.queue_free)
	
	var card_tween = create_tween()
	card_tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	await get_tree().create_timer(0.6).timeout
	
func update_ability_count():
	if data == null or label_ability_count == null:
		return
	
	if data.ability == "残骸":
		var scene = get_tree().current_scene
		if not scene.has_method("damage_player"):
			label_ability_count.visible = false
			return
		
		var break_count = 0
		if is_player_card():
			break_count = scene.player_break_count
		else:
			break_count = scene.enemy_break_count
		
		label_ability_count.text = "残骸: " + str(break_count * data.ability_value * 30)
		label_ability_count.visible = true
	else:
		label_ability_count.visible = false

func is_player_card():
	var parent = get_parent()
	if parent and parent.has_method("can_place"):
		return parent.is_player
	return true
