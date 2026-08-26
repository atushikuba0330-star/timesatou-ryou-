extends Control

# プレイヤー現在マナ
var player_mana := 0

# 敵の最大マナ
var enemy_max_mana := 10

# 敵現在マナ
var enemy_mana := 0

# プレイヤー最大マナ
var max_mana := 10


# シーン開始時
func _ready():

	# ターン進行ループ開始
	run()


# 戦闘中ずっと繰り返されるメインループ
func run():

	# 無限ループ
	while true:

		# 3秒待機
		await get_tree().create_timer(3.0).timeout

		if get_tree().paused:
			continue

		# プレイヤーマナ回復
		# 上限(max_mana)を超えない
		player_mana = min(player_mana + 1, max_mana)

		# 敵マナ回復
		# 上限(enemy_max_mana)を超えない
		enemy_mana = min(enemy_mana + 1, enemy_max_mana)

		# プレイヤーのレリック処理
		for relic in GameData.player_relics:

			# 黒き契約レリック
			if relic.relic_type == "black_pact":

				print("黒き契約発動")

				# 3秒ごとに自傷ダメージ
				get_tree().current_scene.damage_player(relic.value)

		# 全スロットのターンを1進める
		get_tree().call_group("slots", "progress_turn")

		# 準備完了した飛翔体を発射
		BattleEffects.fire_completed_projectiles(get_tree())

		# ターン解決処理
		# ダメージ計算や効果発動など
		get_node("/root/Main/BattleManager").resolve_turn()
