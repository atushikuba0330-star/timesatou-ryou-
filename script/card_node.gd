extends Control

@export var data: CardData
var dragging = false
var power = 0
var chant_progress = 0
var locked: bool = false
var actual_cast_time: int = 0

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

@warning_ignore("unused_parameter")
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
	# プレイヤーのカードは自分側(is_player=true)のスロットにしか置けない
	for slot in get_tree().get_nodes_in_group("slots"):
		if not slot.is_player:
			continue
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
		actual_cast_time = data.cast_time
	if chain_overlay:
		chain_overlay.visible = locked

func set_locked(value: bool):
	locked = value
	if chain_overlay:
		chain_overlay.visible = value

func get_current_power() -> int:
	return CardCombat.compute_power(self)

func update_magic_circle():
	CardVisualEffects.update_magic_circle(self)

func get_display_order():
	return CardVisualEffects.get_display_order(actual_cast_time)

func play_zoom_out():
	await CardVisualEffects.play_zoom_out(self)

func play_break_apart():
	await CardVisualEffects.play_break_apart(self)

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

func _on_mouse_entered():
	var preview = get_tree().current_scene.get_node_or_null("CardPreview")
	if preview:
		preview.show_preview(self)

func _on_mouse_exited():
	var preview = get_tree().current_scene.get_node_or_null("CardPreview")
	if preview:
		preview.hide_preview()
