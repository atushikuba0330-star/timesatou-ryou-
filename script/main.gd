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
	GameData.set_starter_deck("水")
	player_hp_bar.max_value = max_hp
	enemy_hp_bar.max_value = max_hp
	player_mp_bar.max_value = 10
	enemy_mp_bar.max_value = 10
	
	for i in range(player_slots.size()):
		player_slots[i].enemy_slot = enemy_slots[i]
		enemy_slots[i].enemy_slot = player_slots[i]
		player_slots[i].slot_index = i  # ← 追加
		enemy_slots[i].slot_index = i
		
	display_deck()

func damage_player(value):
	player_hp -= value
	print("プレイヤーHP", player_hp)

func damage_enemy(value):
	enemy_hp -= value
	print("エネミーHP", enemy_hp)

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

func display_deck():
	for card_data in GameData.player_deck:
		var card = load("res://card_node.tscn").instantiate()
		card.data = card_data
		deck_display.add_child(card)
