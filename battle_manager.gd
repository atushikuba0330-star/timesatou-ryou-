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

		# ニュートラルカード(即時発動): 戦闘を介さず効果を発動して消える
		if slot.card.data.is_instant:
			NeutralCardEffects.trigger(get_tree(), slot)
			slot.destroy_card()
			processed.append(slot)
			continue

		var enemy = slot.enemy_slot

		if enemy in battle_slots and enemy not in processed and enemy.shield_value == 0:
			CombatResolver.resolve_pair(self, slot, enemy)
			processed.append(slot)
			processed.append(enemy)
		else:
			CombatResolver.resolve_vs_chanting(self, slot)
			processed.append(slot)
			processed.append(enemy)

func finish_card_with_ability(slot, count_as_win: bool = true):
	if slot.card:
		if count_as_win and slot.card.data.element == "火" and slot.is_player:
			GameData.fire_win_count += 1
			if GameData.fire_win_count >= 5:
				GameData.ultimate_unlocked = true

		# 基礎攻撃カード(アビリティ無し)が通常解決したら、自分側の封印を1つ解除する
		if slot.card.data.ability == "" and not slot.card.data.is_ultimate and not slot.card.data.is_instant:
			NeutralCardEffects.release_seal(get_tree(), slot.is_player)

		activate_ability(slot)
		await slot.card.play_zoom_out()
		slot.destroy_card()

func destroy_card_interrupted(slot):
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
