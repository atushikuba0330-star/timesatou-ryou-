extends Node

func apply_relics():
	for relic in GameData.player_relics:
		apply_relic(relic)

func apply_relic(relic: RelicData):
	match relic.relic_type:
		"hp_up":
			get_tree().current_scene.max_hp += relic.value
			get_tree().current_scene.player_hp += relic.value
		"max_mana_up":
			get_node("/root/Main/ManaManager").max_mana += relic.value
		"enemy_mana_down":
			get_node("/root/Main/ManaManager").enemy_mana = max(
				get_node("/root/Main/ManaManager").enemy_mana,
				get_node("/root/Main/ManaManager").max_mana - relic.value
			)
			get_node("/root/Main/ManaManager").max_mana -= relic.value
		"enemy_mana_down":
			var mana_manager = get_node("/root/Main/ManaManager")
			mana_manager.enemy_max_mana -= relic.value
			mana_manager.enemy_mana = min(mana_manager.enemy_mana, mana_manager.enemy_max_mana)
		"max_mana_up":
			var mana_manager = get_node("/root/Main/ManaManager")
			mana_manager.max_mana += relic.value
		"move_dice":
			pass
		"enemy_cost_up":
	# 呪いの印：敵カードのコストを+1（EnemyAIのplace時に処理）
			GameData.enemy_cost_penalty += relic.value

		"enemy_cast_up":
	# 封印の鎖：敵カードの詠唱数+1（Slot.gdのplace時に処理）
			GameData.enemy_cast_penalty += relic.value
