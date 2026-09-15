extends Node

const THREAT_DAMAGE_THRESHOLD := 200

var reserved_card: CardData = null
var reacted_slots := {}  # 既に迎撃判定を済ませたプレイヤースロットの記録

func _ready():
	reserve_next_card()
	run()

# ==================
# 迎撃判定(プレイヤーのカード配置に反応)
# ==================
func _process(_delta):
	var player_slots = get_tree().get_nodes_in_group("slots").filter(func(s): return s.is_player)
	for pslot in player_slots:
		if pslot.card != null and not reacted_slots.has(pslot):
			reacted_slots[pslot] = true
			_react_to_threat(pslot)
		elif pslot.card == null and reacted_slots.has(pslot):
			reacted_slots.erase(pslot)

func _react_to_threat(pslot):
	if _estimate_damage(pslot.card.data) <= THREAT_DAMAGE_THRESHOLD:
		return

	var enemy_mirror = pslot.enemy_slot
	if enemy_mirror == null or not enemy_mirror.can_place():
		return

	var mana_manager = get_node("/root/Main/ManaManager")
	var candidates = GameData.enemy_deck.filter(func(c):
		return c.cast_time <= pslot.card.data.cast_time and mana_manager.enemy_mana >= max(c.cost + GameData.enemy_cost_penalty, 0))
	if candidates.is_empty():
		return

	var chosen: CardData = candidates.pick_random()
	var actual_cost = max(chosen.cost + GameData.enemy_cost_penalty, 0)
	mana_manager.enemy_mana -= actual_cost
	var card_scene = load("res://card_node.tscn")
	var new_card = card_scene.instantiate()
	new_card.data = chosen
	get_tree().root.add_child(new_card)
	if not GameData.enemy_used_cards.has(chosen):
		GameData.enemy_used_cards.append(chosen)
	enemy_mirror.place(new_card, true)

# 威力に加えて、インパクト/残骸/ミラージュによる追加の想定ダメージを合算する
func _estimate_damage(data: CardData) -> int:
	var total = data.power
	match data.ability:
		"インパクト":
			total += data.ability_value * 50
		"残骸":
			var scene = get_tree().current_scene
			var break_count = scene.player_break_count if "player_break_count" in scene else 0
			total += data.ability_value * break_count * 30
		"ミラージュ":
			total += data.ability_value * 70  # 水の基礎カード(water1)の威力1枚分
	return total

func reserve_next_card():
	if GameData.enemy_deck.size() == 0:
		return
	reserved_card = GameData.enemy_deck.pick_random()

func run():
	while true:
		await get_tree().create_timer(2.0).timeout

		if get_tree().paused:
			continue

		try_play_card()

func try_play_card():
	if reserved_card == null:
		reserve_next_card()
		return

	var mana_manager = get_node("/root/Main/ManaManager")
	var actual_cost = max(reserved_card.cost + GameData.enemy_cost_penalty, 0)
	if mana_manager.enemy_mana < actual_cost:
		return

	var enemy_slots = get_tree().get_nodes_in_group("slots").filter(func(s): return not s.is_player)
	var empty_slots = enemy_slots.filter(func(s): return s.can_place())

	if empty_slots.size() == 0:
		return

	var target_slot = empty_slots.pick_random()

	mana_manager.enemy_mana -= actual_cost
	var card_scene = load("res://card_node.tscn")
	var new_card = card_scene.instantiate()
	new_card.data = reserved_card
	get_tree().root.add_child(new_card)
	if not GameData.enemy_used_cards.has(reserved_card):
		GameData.enemy_used_cards.append(reserved_card)
	target_slot.place(new_card, true)

	reserve_next_card()
