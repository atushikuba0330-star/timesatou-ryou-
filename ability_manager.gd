extends Node

func activate_ability(slot):
	if slot.card == null:
		return
	
	var ability = slot.card.data.ability
	var value = slot.card.data.ability_value
	
	# 混沌のダイス：ランダムなアビリティに変える
	for relic in GameData.player_relics:
		if relic.relic_type == "chaos_dice" and slot.is_player:
			var abilities = ["インパクト", "残骸", "スパーク", "ミラージュ", "シールド"]
			ability = abilities.pick_random()
			print("混沌のダイス発動:", ability)
			break
	
	match ability:
		"インパクト":
			var damage = value * 50
# 炎の紋章
			for relic in GameData.player_relics:
				if relic.relic_type == "impact_boost" and slot.is_player:
					damage += relic.value
			if slot.is_player:
				get_tree().current_scene.damage_enemy(damage)
			else:
				get_tree().current_scene.damage_player(damage)
		
		"残骸":
			# 影の紋章
			var boost = 0
			for relic in GameData.player_relics:
				if relic.relic_type == "remains_boost" and slot.is_player:
					boost += relic.value
			if slot.is_player:
				var damage = value * get_tree().current_scene.player_break_count * (30 + boost)
				get_tree().current_scene.damage_enemy(damage)
			else:
				var damage = value * get_tree().current_scene.enemy_break_count * 30
				get_tree().current_scene.damage_player(damage)
		
		"スパーク":
			# 雷の紋章
			var spark_range = value
			for relic in GameData.player_relics:
				if relic.relic_type == "spark_boost" and slot.is_player:
					spark_range += relic.value
			var target_slots = _get_adjacent_enemy_slots(slot, spark_range)
			for target in target_slots:
				if target.card != null:
					get_node("/root/Main/BattleManager")._destroy_card_interrupted(target)
					if slot.is_player:
						GameData.spark_break_count += 1
						if GameData.spark_break_count >= 8:
							GameData.ultimate_unlocked = true
		
		"ミラージュ":
			# 水の紋章
			var mirrage_count = value
			for relic in GameData.player_relics:
				if relic.relic_type == "mirrage_boost" and slot.is_player:
					mirrage_count += relic.value
			var basic_card_data = load("res://card/water1.tres")
			var card_scene = load("res://card_node.tscn")
			var adjacent_slots = _get_adjacent_player_slots(slot, mirrage_count)
			for target_slot in adjacent_slots:
				if target_slot.can_place():
					var new_card = card_scene.instantiate()
					new_card.data = basic_card_data
					get_tree().root.add_child(new_card)
					target_slot.place(new_card, true)
					if slot.is_player:
						GameData.mirrage_count += 1
						if GameData.mirrage_count >= 10:
							GameData.ultimate_unlocked = true
		
		"シールド":
			# 光の紋章
			var shield_val = value
			for relic in GameData.player_relics:
				if relic.relic_type == "shield_boost" and slot.is_player:
					shield_val += relic.value
			slot.shield_value = shield_val
			print("シールド付与:", shield_val)

func _get_adjacent_enemy_slots(slot, count):
	var result = []
	var enemy = slot.enemy_slot
	var parent = enemy.get_parent()
	var all_slots = parent.get_children()
	var center = enemy.slot_index
	
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
