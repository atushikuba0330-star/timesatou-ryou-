extends Node

var reserved_card: CardData = null

func _ready():
	reserve_next_card()
	run()

func reserve_next_card():
	if GameData.enemy_deck.size() == 0:
		return
	reserved_card = GameData.enemy_deck.pick_random()

func run():
	while true:
		await get_tree().create_timer(2.0).timeout
		try_play_card()

func try_play_card():
	if reserved_card == null:
		reserve_next_card()
		return
	
	var mana_manager = get_node("/root/Main/ManaManager")
	if mana_manager.enemy_mana < reserved_card.cost:
		return
	
	var enemy_slots = get_tree().get_nodes_in_group("slots").filter(func(s): return not s.is_player)
	var empty_slots = enemy_slots.filter(func(s): return s.can_place())
	
	if empty_slots.size() == 0:
		return
	
	var target_slot = empty_slots.pick_random()
	
	mana_manager.enemy_mana -= reserved_card.cost
	var card_scene = load("res://card_node.tscn")
	var new_card = card_scene.instantiate()
	new_card.data = reserved_card
	get_tree().root.add_child(new_card)
	target_slot.place(new_card, true)
	
	reserve_next_card()
