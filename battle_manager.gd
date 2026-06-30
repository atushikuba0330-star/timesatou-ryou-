extends Node

func resolve_turn():
	var battle_slots = []
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.state == slot.State.READY_TO_BATTLE:
			battle_slots.append(slot)
	var processed = []
	for slot in battle_slots:
		if slot in processed:
			continue
		if slot.card == null:
			continue
		var enemy = slot.enemy_slot

		if enemy in battle_slots and enemy not in processed and enemy.shield_value == 0:
			resolve_pair(slot, enemy)
			processed.append(slot)
			processed.append(enemy)
		else:
			resolve_vs_chanting(slot)
			processed.append(slot)
func resolve_pair(a, b):
	if a.card == null or b.card == null:
		return

	var power_a = a.card.get_current_power()  # ← 変更
	var power_b = b.card.get_current_power()  # ← 変更
	var diff = power_a - power_b

	if diff > 0:
		get_tree().current_scene.damage_enemy(diff)
		b.destroy_card()
		_finish_card_with_ability(a)
	elif diff < 0:
		get_tree().current_scene.damage_player(-diff)
		a.destroy_card()
		_finish_card_with_ability(b)
	else:
		a.destroy_card()
		b.destroy_card()

func resolve_vs_chanting(slot):
	var power = slot.card.get_current_power()
	var enemy = slot.enemy_slot

	if enemy.shield_value > 0:
		var diff = power
		diff = max(diff, 0)
		var cut = int(diff * (enemy.shield_value * 0.1))
		diff = diff - cut
		print("シールド発動 残りダメージ:", diff)
	
		if not slot.is_player:  # ← 追加（プレイヤーのシールドが発動した場合）
			GameData.shield_cut_total += cut
			print("シールドカット合計:", GameData.shield_cut_total)
			if GameData.shield_cut_total >= 500:
				GameData.ultimate_unlocked = true
	
		enemy.shield_value = 0
		if slot.is_player:
			get_tree().current_scene.damage_enemy(diff)
		else:
			get_tree().current_scene.damage_player(diff)
		_finish_card_with_ability(slot)
	else:
		var enemy_power = 0
		if enemy.card != null:
			enemy_power = enemy.card.get_current_power()
		var diff = power - enemy_power
		diff = max(diff, 0)
		if slot.is_player:
			get_tree().current_scene.damage_enemy(diff)
		else:
			get_tree().current_scene.damage_player(diff)
		_finish_card_with_ability(slot)
		if enemy.card != null:
			_destroy_card_interrupted(enemy)

func _finish_card_with_ability(slot):
	if slot.card:
		if slot.card.data.element == "火" and slot.is_player:
			GameData.fire_win_count += 1
			print("火属性勝利数:", GameData.fire_win_count)
			if GameData.fire_win_count >= 5:
				GameData.ultimate_unlocked = true
		
		activate_ability(slot)
		await slot.card.play_zoom_out()
		slot.destroy_card()
func _destroy_card_interrupted(slot):
	if slot.card == null:
		return
	await slot.card.play_break_apart()
	slot.destroy_card(true)

func activate_ability(slot):
	var ability_manager = get_node_or_null("/root/Main/AbilityManager")
	if ability_manager == null:
		return
	print("activate_ability呼ばれた:", slot.card.data.ability)
	ability_manager.activate_ability(slot)
