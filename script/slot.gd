extends Control

var card = null
@export var enemy_slot: Control
@export var is_player: bool = true

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
	
	c.show_magic_circle()
	
func  destroy_card():
	if card:
		card.queue_free()
		card = null
	
func progress_turn():
	if card:
		card.chant_progress += 1
		
		if enemy_slot and enemy_slot.card:
			var enemy = enemy_slot.card
			
			if enemy.chant_progress >= enemy.data.cast_time:
				intercept(enemy)
				return
				
		if card.chant_progress >= card.data.cast_time:
			card.chant_progress = 0
			resolve_battle()
			
func intercept(enemy):
	
	var result = card.power - enemy.power
	
	card.chant_progress = 0
	enemy.chant_progress = 0
	
	if result > 0:
		enemy_slot.destroy_card()
		
	elif result < 0:
		destroy_card()
		
	else:
		enemy_slot.destroy_card()
		destroy_card()
	
func _ready():
	add_to_group("slots")
	

func resolve_battle():
	if enemy_slot and enemy_slot.card:
		var enemy = enemy_slot.card
		
		var result = card.power - enemy.power
		
		if result > 0:
			# 自分が勝ち
			enemy_slot.destroy_card()
			
			if is_player:
				get_tree().current_scene.damage_enemy(result)
			else:
				get_tree().current_scene.damage_player(result)
			
			destroy_card()
			
		elif result < 0:
			# 敵が勝ち
			destroy_card()
			
			if is_player:
				get_tree().current_scene.damage_player(-result)
			else:
				get_tree().current_scene.damage_enemy(-result)
			
			enemy_slot.destroy_card()
			
		else:
			# 完全相殺
			enemy_slot.destroy_card()
			destroy_card()
			
	else:
		if is_player:
			get_tree().current_scene.damage_enemy(card.power)
		else:
			get_tree().current_scene.damage_player(card.power)
			
		destroy_card()
