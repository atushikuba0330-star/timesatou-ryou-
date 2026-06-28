extends Control
var player_mana := 0
var enemy_mana := 0
var max_mana := 10

func _ready():
	run()

func run():
	while true:
		await get_tree().create_timer(4.0).timeout

		player_mana = min(player_mana + 1, max_mana)
		enemy_mana = min(enemy_mana + 1, max_mana)

		# 全スロットのターンを進める
		get_tree().call_group("slots", "progress_turn")

		# ターン処理後にバトル解決
		get_node("/root/Main/BattleManager").resolve_turn()
