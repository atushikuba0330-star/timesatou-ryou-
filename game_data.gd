extends Node

var player_deck: Array[CardData] = []
var owned_cards: Array[CardData] = []

var base_max_mana: int = 10
var fire_win_count: int = 0
var mirrage_count: int = 0      # ミラージュ生成枚数（水）
var spark_break_count: int = 0  # スパークブレイク枚数（雷）
var shield_cut_total: int = 0   # シールドカットダメージ合計（光）
var ultimate_unlocked: bool = false  # 必殺解放フラグ
var selected_element: String = "火"

var player_relics: Array[RelicData] = []
var phoenix_used: bool = false
var enemy_cost_penalty: int = 0
var enemy_cast_penalty: int = 0
var reward_type: String = ""
var enemy_used_cards: Array[CardData] = []

func set_starter_deck(element: String):
	player_deck.clear()
	match element:
		"火":
			for i in range(1, 6):
				player_deck.append(load("res://card/fire" + str(i) + ".tres"))
			player_deck.append(load("res://card/fireEX.tres"))  # ← 追加
		"水":
			for i in range(1, 6):
				player_deck.append(load("res://card/water" + str(i) + ".tres"))
			player_deck.append(load("res://card/waterEX.tres"))  # ← 追加
		"雷":
			for i in range(1, 6):
				player_deck.append(load("res://card/thunder" + str(i) + ".tres"))
			player_deck.append(load("res://card/thunderEX.tres"))  # ← 追加
		"光":
			for i in range(1, 6):
				player_deck.append(load("res://card/holly" + str(i) + ".tres"))
			player_deck.append(load("res://card/hollyEX.tres"))  # ← 追加
		"闇":
			for i in range(1, 6):
				player_deck.append(load("res://card/dark" + str(i) + ".tres"))
			player_deck.append(load("res://card/darkEX.tres"))  # ← 追加

var enemy_deck: Array[CardData] = []

func set_enemy_deck(element: String):
	enemy_deck.clear()
	match element:
		"火":
			for i in range(1, 6):
				enemy_deck.append(load("res://card/fire" + str(i) + ".tres"))
		"水":
			for i in range(1, 6):
				enemy_deck.append(load("res://card/water" + str(i) + ".tres"))
		"雷":
			for i in range(1, 6):
				enemy_deck.append(load("res://card/thunder" + str(i) + ".tres"))
		"光":
			for i in range(1, 6):
				enemy_deck.append(load("res://card/holly" + str(i) + ".tres"))
		"闇":
			for i in range(1, 6):
				enemy_deck.append(load("res://card/dark" + str(i) + ".tres"))

func reset_battle():
	fire_win_count = 0
	mirrage_count = 0
	spark_break_count = 0
	shield_cut_total = 0
	ultimate_unlocked = false
	enemy_deck.clear()
	phoenix_used = false
	enemy_used_cards.clear()
	enemy_cost_penalty = 0
	enemy_cast_penalty = 0
