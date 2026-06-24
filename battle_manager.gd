
extends Node

func resolve(slot):
	if slot.card == null:
		return
	
	var enemy_slot = slot.enemy_slot
	var my_card = slot.card
	
	if enemy_slot and enemy_slot.card:
		var enemy = enemy_slot.card
		
		var result = my_card.data.power - enemy.data.power
		
		if result > 0:
			enemy_slot.destroy_card()
			
			if slot.is_player:
				get_tree().current_scene.damage_enemy(result)
			else:
				get_tree().current_scene.damage_player(result)
				
		elif result < 0:
			if slot.is_player:
				get_tree().current_scene.damage_player(-result)
			else:
				get_tree().current_scene.damage_enemy(-result)
				
			enemy_slot.destroy_card()
			
		else:
			enemy_slot.destroy_card()
	
	else:
		if slot.is_player:
			get_tree().current_scene.damage_enemy(my_card.data.power)
		else:
			get_tree().current_scene.damage_player(my_card.data.power)
	
	slot.destroy_card()
