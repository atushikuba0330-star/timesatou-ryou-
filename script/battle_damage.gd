class_name BattleDamage
extends RefCounted

# script/main.gd にあった damage_player() / damage_enemy() を切り出したユーティリティ。
# main は Main(Node2D) のインスタンスを想定。

static func damage_player(main, value) -> void:
	if not main.is_inside_tree():
		return

	for relic in GameData.player_relics:
		if relic.relic_type == "reflect":
			var reflect_damage = int(value * (relic.value * 0.01))
			damage_enemy(main, reflect_damage)
			print("鏡の盾反射ダメージ:", reflect_damage)

	if main.player_hp - value <= 0 and not GameData.phoenix_used:
		for relic in GameData.player_relics:
			if relic.relic_type == "phoenix":
				GameData.phoenix_used = true
				main.player_hp = int(main.max_hp * 0.5)  # HP最大値の50%まで回復
				print("不死鳥の羽発動！HP:", main.player_hp)
				return

	main.player_hp -= value
	print("プレイヤーHP", main.player_hp)
	show_damage_label(main, value, main.player_hp_bar.global_position)

	if main.player_hp <= 0:
		if not main.is_inside_tree():
			return
		main.mana_manager.set_process(false)
		await main.get_tree().process_frame
		if not main.is_inside_tree():
			return
		main.get_tree().change_scene_to_file("res://lose.tscn")

static func damage_enemy(main, value) -> void:
	if not main.is_inside_tree():
		return

	main.enemy_hp -= value
	print("エネミーHP", main.enemy_hp)
	show_damage_label(main, value, main.enemy_hp_bar.global_position)

	if main.enemy_hp <= 0:
		if not main.is_inside_tree():
			return
		main.mana_manager.set_process(false)
		await main.get_tree().process_frame
		if not main.is_inside_tree():
			return
		main.get_tree().change_scene_to_file("res://win.tscn")

# ダメージが発生するたびに damage_popup.tscn を1つインスタンス化し、
# HPバーの位置に数値を表示して上に浮かびながらフェードアウトさせる。
# 使い捨てなので、同じフレームで複数箇所にダメージが出ても取り合いにならない。
static func show_damage_label(main, value, spawn_position: Vector2) -> void:
	var popup_scene = preload("res://damage_popup.tscn")
	var label = popup_scene.instantiate()
	label.text = "-" + str(value)
	main.add_child(label)
	label.global_position = spawn_position
	label.start_float()
