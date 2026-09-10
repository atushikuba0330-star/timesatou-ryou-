extends Control

var temp_selected_element: String = ""

@onready var start_button = $Start_Button

var descriptions = {
	"火": "速攻火力\n素早く敵を焼き尽くす攻撃的なデッキ",
	"水": "大量展開\n多数のカードでスロットを埋め尽くす",
	"雷": "範囲攻撃\n隣接スロットを巻き込む電撃デッキ",
	"光": "シールド守り\n守りを固めて確実に勝利を掴む",
	"闇": "破壊利用\n破壊されたカードを糧に強くなる"
}

func _ready():
	start_button.disabled = true  # 最初は押せない
	pass

func select_character(element: String):
	temp_selected_element = element
	start_button.disabled = false

func _on_start_button_pressed():
	GameData.selected_element= temp_selected_element
	GameData.player_deck.clear()  # 新しいランは初期デッキから開始する
	SePlayer.play_se("res://SE (1).wav")
	get_tree().change_scene_to_file("res://Scenes/TutorialKeyWordFire .tscn")
	
func _on_fire_buttan_pressed():
	select_character("火試")
