extends Node

var player_deck: Array[CardData] = []
var owned_cards: Array[CardData] = []

func set_starter_deck(element: String):
	player_deck.clear()
	match element:
		"火":
			for i in range(1, 6):
				player_deck.append(load("res://card/fire" + str(i) + ".tres"))
		"水":
			for i in range(1, 6):
				player_deck.append(load("res://card/water" + str(i) + ".tres"))
		"雷":
			for i in range(1, 6):
				player_deck.append(load("res://card/thunder" + str(i) + ".tres"))
		"光":
			for i in range(1, 6):
				player_deck.append(load("res://card/holly" + str(i) + ".tres"))
		"闇":
			for i in range(1, 6):
				player_deck.append(load("res://card/dark" + str(i) + ".tres"))
