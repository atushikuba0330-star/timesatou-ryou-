class_name CombatResolver
extends RefCounted

# battle_manager.gd から、1対1のカードバトル判定ロジックだけを切り出したユーティリティ。
# battle_manager は BattleManager(Node) のインスタンス（finish_card_with_ability /
# destroy_card_interrupted を呼び戻すため）を想定。

static func resolve_pair(battle_manager, a, b) -> void:
	if a.card == null or b.card == null:
		return
	var power_a = a.card.get_current_power()
	var power_b = b.card.get_current_power()
	var diff = power_a - power_b
	var tree = battle_manager.get_tree()

	if diff > 0:
		if a.is_player:
			tree.current_scene.damage_enemy(diff)
		else:
			tree.current_scene.damage_player(diff)
		b.destroy_card()
		battle_manager.finish_card_with_ability(a)
	elif diff < 0:
		if b.is_player:
			tree.current_scene.damage_enemy(-diff)
		else:
			tree.current_scene.damage_player(-diff)
		a.destroy_card()
		battle_manager.finish_card_with_ability(b)
	else:
		battle_manager.finish_card_with_ability(a, false)
		battle_manager.finish_card_with_ability(b, false)

static func resolve_vs_chanting(battle_manager, slot) -> void:
	var tree = battle_manager.get_tree()
	var power = slot.card.get_current_power()
	var enemy = slot.enemy_slot

	if enemy.shield_value > 0:
		var diff = max(power, 0)
		var cut = int(diff * (enemy.shield_value * 0.1))
		diff = max(diff - cut,0)
		print("シールド発動 残りダメージ:", diff)

		if not slot.is_player:  # プレイヤーのシールドが発動した場合
			GameData.shield_cut_total += cut
			print("シールドカット合計:", GameData.shield_cut_total)
			if GameData.shield_cut_total >= 500:
				GameData.ultimate_unlocked = true

		enemy.shield_value = 0
		if slot.is_player:
			tree.current_scene.damage_enemy(diff)
		else:
			tree.current_scene.damage_player(diff)
		battle_manager.finish_card_with_ability(slot)
	else:
		var enemy_power = 0
		if enemy.card != null:
			enemy_power = enemy.card.get_current_power()
		var diff = max(power - enemy_power, 0)
		if slot.is_player:
			tree.current_scene.damage_enemy(diff)
		else:
			tree.current_scene.damage_player(diff)
		battle_manager.finish_card_with_ability(slot)
		if enemy.card != null:
			battle_manager.destroy_card_interrupted(enemy)
