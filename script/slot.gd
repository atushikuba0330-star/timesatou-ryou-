
extends Control

var card = null
@export var enemy_slot: Control
@export var is_player: bool = true

signal chant_finished(slot)

func can_place():
	return card == null
	

func place(c):
	var mana_manager = get_node("/root/Main/ManaManager")
	
	if is_player:
		if mana_manager.player_mana < c.data.cost:
			print("マナ不足")
			c.queue_free()
			return
		mana_manager.player_mana -= c.data.cost
	else:
		if mana_manager.enemy_mana < c.data.cost:
			c.queue_free()
			return
		mana_manager.enemy_mana -= c.data.cost
		
	card = c
	
	c.get_parent().remove_child(c)
	add_child(c)
	
	c.position = Vector2.ZERO
	
	card.chant_progress = 1
	card.update_magic_circle()
	

func destroy_card():
	if card:
		card.queue_free()
		card = null
	

func progress_turn():
	if card == null:
		return
		
	card.chant_progress += 1
	card.update_magic_circle()
	
	if card.chant_progress >= card.data.cast_time:
		emit_signal("chant_finished", self)  # ←ここが核心
	

func _ready():
	add_to_group("slots")
