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

		if enemy in battle_slots and enemy not in processed:
			resolve_pair(slot, enemy)
			processed.append(slot)
			processed.append(enemy)
		else:
			# 相手がREADY_TO_BATTLEでない場合
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
	var power = slot.card.get_current_power()  # ← 変更
	var enemy = slot.enemy_slot
	var enemy_power = 0
	if enemy.card != null:
		enemy_power = enemy.card.get_current_power()  # ← 変更（将来用）

	var diff = power - enemy_power

	if slot.is_player:
		get_tree().current_scene.damage_enemy(diff)
	else:
		get_tree().current_scene.damage_player(diff)

	_finish_card_with_ability(slot)

	if enemy.card != null:
		_destroy_card_interrupted(enemy)

func _finish_card_with_ability(slot):
	# アビリティ発動 → 魔法陣ズームアウト後に消える（未実装部分はここに追加）
	if slot.card:
		await slot.card.play_zoom_out()
		slot.destroy_card()

func _destroy_card_interrupted(slot):
	if slot.card == null:
		return
	await slot.card.play_break_apart()
	slot.destroy_card()
