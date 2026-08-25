extends Control

var cards_to_show: Array[CardData] = []

func _ready():
	setup_cards()

func setup_cards():
	var source: Array[CardData] = []
	# 相手のカードと特殊カードを1つの選択肢に統合し、所持していない全カードからランダムに選ばせる
	var neutral_pool = _get_neutral_cards().filter(func(c):
		return c not in GameData.player_deck and c not in GameData.owned_cards)
	var enemy_pool = GameData.enemy_deck.filter(func(c):
		return c.ability != "" and not c.is_ultimate and c not in GameData.player_deck and c not in GameData.owned_cards)
	source = neutral_pool + enemy_pool

	source.shuffle()
	var count = randi_range(1, min(3, source.size()))
	cards_to_show = source.slice(0, count)
	
	var buttons = $HBoxContainer.get_children()
	for i in range(buttons.size()):
		if i < cards_to_show.size():
			var card = cards_to_show[i]
			var btn = buttons[i]
			btn.visible = true
			if card.icon:
				btn.get_node("Panel/TextureRect").texture = card.icon
			btn.get_node("Panel/Labelname").text = card.name
			btn.get_node("Panel/Labelcost").text = str(card.cost)
			btn.get_node("Panel/Labelpower").text = str(card.power)
			btn.get_node("Panel/Labelcast").text = str(card.cast_time)
			btn.get_node("Panel/Labelability").text = card.ability + " " + str(card.ability_value)
		else:
			buttons[i].visible = false

func _on_button_pressed():
	select_card(0)

func _on_button_2_pressed():
	select_card(1)

func _on_button_3_pressed():
	select_card(2)

func select_card(index: int):
	if index < cards_to_show.size():
		GameData.owned_cards.append(cards_to_show[index])
	get_tree().change_scene_to_file("res://deck_builder.tscn")

func _get_neutral_cards() -> Array[CardData]:
	var names = ["haste", "break", "drain", "steal", "heal", "seal", "delay", "sendback", "sacrifice", "reinforce"]
	var cards: Array[CardData] = []
	for n in names:
		var card = load("res://card/neutral_" + n + ".tres")
		if card:
			cards.append(card)
	return cards
