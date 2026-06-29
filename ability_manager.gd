extends Node

func activate_ability(slot):
	if slot.card == null:
		return
	
	var ability = slot.card.data.ability
	var value = slot.card.data.ability_value
	
	match ability:
		"インパクト":
			var damage = value * 50
			if slot.is_player:
				get_tree().current_scene.damage_enemy(damage)
			else:
				get_tree().current_scene.damage_player(damage)
		"残骸":
			if slot.is_player:
				var damage = value * get_tree().current_scene.player_break_count * 30
				get_tree().current_scene.damage_enemy(damage)
			else:
				var damage = value * get_tree().current_scene.enemy_break_count * 30
				get_tree().current_scene.damage_player(damage)
		"スパーク":
			print("スパーク処理開始")
			var target_slots = _get_adjacent_enemy_slots(slot, value)
			print("対象スロット数:", target_slots.size())
			for target in target_slots:
				print("対象カード:", target.card)
				if target.card != null:
					get_node("/root/Main/BattleManager")._destroy_card_interrupted(target)

		"ミラージュ":
			var basic_card_data = load("res://card/water1.tres")
			var card_scene = load("res://card_node.tscn")
			var adjacent_slots = _get_adjacent_player_slots(slot, value)
			for target_slot in adjacent_slots:
				if target_slot.can_place():
					var new_card = card_scene.instantiate()
					new_card.data = basic_card_data
					get_tree().root.add_child(new_card)
					target_slot.place(new_card)

		"シールド":
			slot.shield_value = value
			print("シールド付与:", value)

func _get_adjacent_enemy_slots(slot, count):
	var result = []
	var enemy = slot.enemy_slot
	var parent = enemy.get_parent()
	var all_slots = parent.get_children()
	var center = enemy.slot_index
	
	# 0を除いて隣だけを対象にする
	var offsets = [-1, 1, -2, 2, -3, 3, -4, 4]
	for offset in offsets:
		if result.size() >= count:
			break
		var idx = center + offset
		if idx >= 0 and idx < all_slots.size():
			result.append(all_slots[idx])
	
	return result

func _get_adjacent_player_slots(slot, count):
	var result = []
	var parent = slot.get_parent()
	var all_slots = parent.get_children()
	var center = slot.slot_index
	
	var offsets = [-1, 1, -2, 2, -3, 3, -4, 4]
	for offset in offsets:
		if result.size() >= count:
			break
		var idx = center + offset
		if idx >= 0 and idx < all_slots.size():
			result.append(all_slots[idx])
	
	return result
