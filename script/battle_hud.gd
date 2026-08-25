class_name BattleHUD
extends RefCounted

# script/main.gd の _process() にあった、HP/マナ表示の更新処理だけを切り出したユーティリティ。
# main は Main(Node2D) のインスタンスを想定。

static func update(main) -> void:
	main.get_node("LabelPlayer_HP").text = "HP: " + str(main.player_hp)
	main.get_node("LabelEnemy_HP").text = "Enemy HP: " + str(main.enemy_hp)
	main.get_node("LabelPlayer_Mana").text = "Mana: " + str(main.mana_manager.player_mana)
	main.get_node("LabelEnemy_Mana").text = "Enemy Mana: " + str(main.mana_manager.enemy_mana)

	var over_mana = main.mana_manager.player_mana - GameData.base_max_mana
	var over_mana_label = main.get_node("LabelOverMana")
	if over_mana > 0:
		over_mana_label.text = "+" + str(over_mana)
		over_mana_label.visible = true
	else:
		over_mana_label.visible = false

	# ゲージを更新
	main.player_hp_bar.value = main.player_hp
	main.enemy_hp_bar.value = main.enemy_hp
	main.player_mp_bar.value = main.mana_manager.player_mana
	main.enemy_mp_bar.value = main.mana_manager.enemy_mana

	if GameData.ultimate_unlocked:
		for card in main.deck_display.get_children():
			if card.locked:
				card.set_locked(false)
