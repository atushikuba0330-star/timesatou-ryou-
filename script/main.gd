extends Node2D

# プレイヤーと敵の現在HP
var player_hp := 1000
var enemy_hp := 1000

# HPの最大値
var max_hp := 1000

# ブレイク回数（将来的な状態異常やシールド破壊用）
var player_break_count := 0
var enemy_break_count := 0

# ゲーム速度の切り替え候補
# 1倍 → 1.5倍 → 2倍
var time_scale_steps = [1.0, 1.5, 2.0]

# 現在選択中の速度インデックス
var time_scale_index = 0

# 一時停止中かどうか
var is_paused = false

# 一時停止前の速度を保存
var pre_pause_time_scale = 1.0


# ノード取得
@onready var mana_manager = $ManaManager

# HPバー
@onready var player_hp_bar = $PlayerHPBar
@onready var enemy_hp_bar = $EnemyHPBar

# MPバー
@onready var player_mp_bar = $PlayerMPBar
@onready var enemy_mp_bar = $EnemyMPBar

# プレイヤー・敵の配置スロット一覧を取得
@onready var player_slots = $PlayerSlot.get_children()
@onready var enemy_slots = $EnemySlot.get_children()

# デッキ表示エリア
@onready var deck_display = $DeckDisplay


# シーン開始時に実行
func _ready():
	BgmPlayer.play_bgm("battle")

	GameData.reset_battle()

	# デバッグ用：最初からアルティメット解放
	GameData.ultimate_unlocked = true

	# デッキ未設定ならスターターデッキ生成
	if GameData.player_deck.is_empty():
		GameData.set_starter_deck(GameData.selected_element)

	# 敵属性をランダム選択
	var elements = ["火", "水", "雷", "光", "闇"]
	GameData.set_enemy_deck(elements.pick_random())

	# HPバー最大値設定
	player_hp_bar.max_value = max_hp
	enemy_hp_bar.max_value = max_hp

	# MPバー最大値設定
	player_mp_bar.max_value = 10
	enemy_mp_bar.max_value = 10

	# プレイヤースロットと敵スロットを対応付け
	for i in range(player_slots.size()):

		# お互いの対面スロットをセット
		player_slots[i].enemy_slot = enemy_slots[i]
		enemy_slots[i].enemy_slot = player_slots[i]

		# スロット番号保存
		player_slots[i].slot_index = i
		enemy_slots[i].slot_index = i

	# レリック効果適用
	$RelicManager.apply_relics()

	print("最大マナ:", $ManaManager.max_mana)

	# デッキ表示
	display_deck()


# プレイヤーへダメージ
func damage_player(value):
	BattleDamage.damage_player(self, value)


# 敵へダメージ
func damage_enemy(value):
	BattleDamage.damage_enemy(self, value)


# キーボード入力処理
func _input(event):

	if event is InputEventKey and event.pressed:

		# Spaceでポーズ
		if event.keycode == KEY_SPACE:
			_toggle_pause()

		# Eで速度アップ
		elif event.keycode == KEY_E:
			_change_speed(1)

		# Qで速度ダウン
		elif event.keycode == KEY_Q:
			_change_speed(-1)


# 一時停止切り替え
func _toggle_pause():

	is_paused = not is_paused

	if is_paused:

		# 現在速度を保存
		pre_pause_time_scale = Engine.time_scale

		# 完全停止
		Engine.time_scale = 0.0

	else:

		# 停止前の速度に戻す
		Engine.time_scale = pre_pause_time_scale


# 戦闘速度変更
func _change_speed(direction: int):

	# ポーズ中は変更不可
	if is_paused:
		return

	# インデックス範囲制限
	time_scale_index = clamp(
		time_scale_index + direction,
		0,
		time_scale_steps.size() - 1
	)

	# 新しい速度適用
	Engine.time_scale = time_scale_steps[time_scale_index]


# シーン終了時
func _exit_tree():

	# 倍速が他シーンへ影響しないよう戻す
	Engine.time_scale = 1.0


# 毎フレーム実行
func _process(delta):

	# テキスト更新
	$LabelPlayer_HP.text = "HP: " + str(player_hp)
	$LabelEnemy_HP.text = "Enemy HP: " + str(enemy_hp)

	$LabelPlayer_Mana.text = "Mana: " + str(mana_manager.player_mana)
	$LabelEnemy_Mana.text = "Enemy Mana: " + str(mana_manager.enemy_mana)

	# 基本上限を超えたマナ量
	var over_mana = mana_manager.player_mana - GameData.base_max_mana

	# オーバーマナ表示
	if over_mana > 0:
		$LabelOverMana.text = "+" + str(over_mana)
		$LabelOverMana.visible = true
	else:
		$LabelOverMana.visible = false

	# HPゲージ更新
	player_hp_bar.value = player_hp
	enemy_hp_bar.value = enemy_hp

	# MPゲージ更新
	player_mp_bar.value = mana_manager.player_mana
	enemy_mp_bar.value = mana_manager.enemy_mana

	# アルティメット解放時
	if GameData.ultimate_unlocked:

		# ロック中カードを解放
		for card in deck_display.get_children():

			if card.locked:
				card.set_locked(false)


# デッキ一覧を画面表示
func display_deck():

	print("デッキ枚数:", GameData.player_deck.size())

	# デッキ内のカードを順番に表示
	for i in range(GameData.player_deck.size()):

		var data = GameData.player_deck[i]

		# 空データなら表示しない
		if data == null:
			continue

		# カードシーン生成
		var card = load("res://card_node.tscn").instantiate()

		# カードデータ設定
		card.data = data

		# アルティメットカードは最初ロック
		if data.is_ultimate:
			card.set_locked(true)

		# デッキ表示欄へ追加
		deck_display.add_child(card)
