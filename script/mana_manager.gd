extends Control

var player_mana :=0
var enemy_mana := 0

var max_mana := 10

func _ready():
	run()
	
func run():
	while true:
		await get_tree().create_timer(2.0).timeout
		
		player_mana = min(player_mana + 1,max_mana)
		enemy_mana = min(enemy_mana + 1,max_mana)
		
		print("playr:",player_mana,"enemy:",enemy_mana)
		
		get_tree().call_group("slots","progress_turn")
