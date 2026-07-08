extends Control
var player_mana := 0
var enemy_max_mana := 10
var enemy_mana := 0
var max_mana := 10

func _ready():
	run()

func run():
	while true:
		await get_tree().create_timer(3.0).timeout

		player_mana = min(player_mana + 1, max_mana)
		enemy_mana = min(enemy_mana + 1, enemy_max_mana)
		
		for relic in GameData.player_relics:
			if relic.relic_type == "black_pact":
				print("黒き契約発動")
				get_tree().current_scene.damage_player(relic.value)

		get_tree().call_group("slots", "progress_turn")
		get_node("/root/Main/BattleManager").resolve_turn()
