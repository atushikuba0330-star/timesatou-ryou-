extends Node2D
var player_hp := 1000
var enemy_hp := 1000
var max_hp := 1000
var player_break_count := 0
var enemy_break_count := 0
var time_scale_steps = [1.0, 1.5, 2.0]
var time_scale_index = 0
var is_paused = false
var pre_pause_time_scale = 1.0

@onready var mana_manager = $ManaManager
@onready var player_hp_bar = $PlayerHPBar
@onready var player_mp_bar = $PlayerMPBar
@onready var enemy_hp_bar = $EnemyHPBar
@onready var enemy_mp_bar = $EnemyMPBar
@onready var player_slots = $PlayerSlot.get_children()
@onready var enemy_slots = $EnemySlot.get_children()
@onready var deck_display = $DeckDisplay

func _ready():
	GameData.reset_battle()
	GameData.ultimate_unlocked = true
	if GameData.player_deck.is_empty():
		GameData.set_starter_deck(GameData.selected_element)

	var elements = ["火", "水", "雷", "光", "闇"]
	GameData.set_enemy_deck(elements.pick_random())
	
	player_hp_bar.max_value = max_hp
	enemy_hp_bar.max_value = max_hp
	player_mp_bar.max_value = 10
	enemy_mp_bar.max_value = 10
	
	for i in range(player_slots.size()):
		player_slots[i].enemy_slot = enemy_slots[i]
		enemy_slots[i].enemy_slot = player_slots[i]
		player_slots[i].slot_index = i
		enemy_slots[i].slot_index = i

	$RelicManager.apply_relics()
	print("最大マナ:", $ManaManager.max_mana)
	display_deck()

func damage_player(value):
	BattleDamage.damage_player(self, value)

func damage_enemy(value):
	BattleDamage.damage_enemy(self, value)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			_toggle_pause()
		elif event.keycode == KEY_E:
			_change_speed(1)
		elif event.keycode == KEY_Q:
			_change_speed(-1)

func _toggle_pause():
	is_paused = not is_paused
	if is_paused:
		pre_pause_time_scale = Engine.time_scale
		Engine.time_scale = 0.0
	else:
		Engine.time_scale = pre_pause_time_scale

func _change_speed(direction: int):
	if is_paused:
		return
	time_scale_index = clamp(time_scale_index + direction, 0, time_scale_steps.size() - 1)
	Engine.time_scale = time_scale_steps[time_scale_index]

func _exit_tree():
	Engine.time_scale = 1.0

func _process(delta):
	$LabelPlayer_HP.text = "HP: " + str(player_hp)
	$LabelEnemy_HP.text = "Enemy HP: " + str(enemy_hp)
	$LabelPlayer_Mana.text = "Mana: " + str(mana_manager.player_mana)
	$LabelEnemy_Mana.text = "Enemy Mana: " + str(mana_manager.enemy_mana)
	
	var over_mana = mana_manager.player_mana - GameData.base_max_mana
	if over_mana > 0:
		$LabelOverMana.text = "+" + str(over_mana)
		$LabelOverMana.visible = true
	else:
		$LabelOverMana.visible = false
	
	# ゲージを更新
	player_hp_bar.value = player_hp
	enemy_hp_bar.value = enemy_hp
	player_mp_bar.value = mana_manager.player_mana
	enemy_mp_bar.value = mana_manager.enemy_mana

	if GameData.ultimate_unlocked:  # ← 追加
		for card in deck_display.get_children():
			if card.locked:
				card.set_locked(false)

func display_deck():
	print("デッキ枚数:", GameData.player_deck.size())
	for i in range(GameData.player_deck.size()):
		var data = GameData.player_deck[i]
		if data == null:  # ニュートラル専用枠が空きの場合は表示しない
			continue
		var card = load("res://card_node.tscn").instantiate()
		card.data = data
		if data.is_ultimate:
			card.set_locked(true)
		deck_display.add_child(card)
