extends Control

var reward_relic: RelicData = null

func _ready():
	setup_rewards()

func setup_rewards():
	# 遺物の報酬
	var all_relics = _get_all_relics()
	var owned_types = GameData.player_relics.map(func(r): return r.relic_type)
	var available = all_relics.filter(func(r): return r.relic_type not in owned_types)
	if available.size() > 0:
		reward_relic = available.pick_random()
		$HBoxContainer/RelicButton.text = reward_relic.name + "\n" + reward_relic.description
	else:
		$HBoxContainer/RelicButton.text = "遺物なし"
	
	# 特殊カード
	$HBoxContainer/SpecialCardButton.text = "特殊カード\n（準備中）"
	
	# 相手のカード
	$HBoxContainer/EnemyCardButton.text = "相手のカード\nランダム3枚から選ぶ"

func _get_all_relics() -> Array:
	var relics = []
	var relic_files = ["cast_time_down", "cost_down", "mana_recover", "enemy_cost_up",
		"enemy_cast_up", "enemy_mana_down", "impact_boost", "remains_boost",
		"spark_boost", "mirrage_boost", "shield_boost", "hp_up", "max_mana_up",
		"phoenix", "reflect", "blood_pact", "ult_boost", "move_dice",
		"chaos_dice", "black_pact"]
	for file in relic_files:
		var relic = load("res://Relic/" + file + ".tres")
		if relic:
			relics.append(relic)
	return relics

func _on_enemy_card_button_pressed():
	GameData.reward_type = "enemy"
	get_tree().change_scene_to_file("res://card_select.tscn")

func _on_special_card_button_pressed():
	get_tree().change_scene_to_file("res://deck_builder.tscn")

func _on_relic_button_pressed():
	if reward_relic:
		GameData.player_relics.append(reward_relic)
	get_tree().change_scene_to_file("res://deck_builder.tscn")
