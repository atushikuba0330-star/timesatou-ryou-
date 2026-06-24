extends Node2D

var player_hp := 20
var enemy_hp := 20
var player_mana := 0
var enemy_mana := 0

func damage_player(value):
	player_hp -= value
	print("プレイヤーHP",player_hp)
	
func damage_enemy(value):
	enemy_hp -= value
	print("エネミーHP",enemy_hp)
	

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
			
func _process(delta):
	var mana_manager = $ManaManager
	
	$LabelPlayer_HP.text = "HP: " + str(player_hp)
	$LabelEnemy_HP.text = "Enemy HP: " + str(enemy_hp)
	
	$LabelPlayer_Mana.text = "Mana: " + str(mana_manager.player_mana)
	$LabelEnemy_Mana.text = "Enemy Mana: " + str(mana_manager.enemy_mana)

func _ready():
	for slot in get_tree().get_nodes_in_group("slots"):
		slot.connect("chant_finished", $BattleManager.resolve)
