extends Control

var temp_selected_element: String = ""

@onready var right_panel_title = $RightPanel/Label
@onready var right_panel_desc = $RightPanel/DescLabel
@onready var start_button = $StartButton

var descriptions = {
	"火": "速攻火力\n素早く敵を焼き尽くす攻撃的なデッキ",
	"水": "大量展開\n多数のカードでスロットを埋め尽くす",
	"雷": "範囲攻撃\n隣接スロットを巻き込む電撃デッキ",
	"光": "シールド守り\n守りを固めて確実に勝利を掴む",
	"闇": "破壊利用\n破壊されたカードを糧に強くなる"
}

func _ready():
	start_button.disabled = true  # 最初は押せない

func select_character(element: String):
	temp_selected_element = element
	right_panel_title.text = element + "属性"
	right_panel_desc.text = descriptions[element]
	start_button.disabled = false

func _on_start_button_pressed():
	GameData.selected_element = temp_selected_element
	get_tree().change_scene_to_file("res://main.tscn")

func _on_fire_button_pressed():
	select_character("火")

func _on_water_button_pressed():
	select_character("水")

func _on_thunder_button_pressed():
	select_character("雷")

func _on_holly_button_pressed():
	select_character("光")

func _on_dark_button_pressed():
	select_character("闇")
