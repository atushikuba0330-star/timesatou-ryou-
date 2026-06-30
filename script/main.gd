extends Node2D
var player_hp := 1000
var enemy_hp := 1000
var max_hp := 1000
var player_break_count := 0
var enemy_break_count := 0

@onready var mana_manager = $ManaManager
@onready var player_hp_bar = $PlayerHPBar
@onready var player_mp_bar = $PlayerMPBar
@onready var enemy_hp_bar = $EnemyHPBar
@onready var enemy_mp_bar = $EnemyMPBar
@onready var player_slots = $PlayerSlot.get_children()
@onready var enemy_slots = $EnemySlot.get_children()
@onready var deck_display = $DeckDisplay

func _ready():
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
		
	display_deck()

func damage_player(value):
	if not is_inside_tree():
		return
	
	player_hp -= value
	print("プレイヤーHP", player_hp)
	
	if player_hp <= 0:
		if not is_inside_tree():
			return
		mana_manager.set_process(false)
		await get_tree().process_frame
		if not is_inside_tree():
			return
		get_tree().change_scene_to_file("res://lose.tscn")

func damage_enemy(value):
	if not is_inside_tree():
		return
	
	enemy_hp -= value
	print("エネミーHP", enemy_hp)
	
	if enemy_hp <= 0:
		if not is_inside_tree():
			return
		mana_manager.set_process(false)
		await get_tree().process_frame
		if not is_inside_tree():
			return
		get_tree().change_scene_to_file("res://win.tscn")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _process(delta):
	$LabelPlayer_HP.text = "HP: " + str(player_hp)
	$LabelEnemy_HP.text = "Enemy HP: " + str(enemy_hp)
	$LabelPlayer_Mana.text = "Mana: " + str(mana_manager.player_mana)
	$LabelEnemy_Mana.text = "Enemy Mana: " + str(mana_manager.enemy_mana)
	
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
		var card = load("res://card_node.tscn").instantiate()
		card.data = GameData.player_deck[i]
		if i == 5:  # 6枚目は必殺技
			card.set_locked(true)
		deck_display.add_child(card)
