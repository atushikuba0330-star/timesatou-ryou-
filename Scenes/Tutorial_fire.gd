extends Node

#宣言
@export var speed: float = 50.0
var st1 = false
var count = 0
@onready var Pnel = $TutorialPanel
@onready var Panel2 = $TutorialPanel2
@onready var label = $TutorialPanel2/TutorialText2
@onready var Buttan = $TutorialPanel2/NextButtan2
@onready var YRight = $TutorialPanel2/YubiMigi
@onready var YLeft = $TutorialPanel2/YubiHidari
@onready var Panel3 = $TutorialPanel3
@onready var Yubi = $TutorialPanel3/yubi3
@onready var St = $"../ManaManager"

#開幕の処理
func _ready() -> void:
	Pnel.visible = true
	Panel2.visible = false
	YLeft.visible = false
	YRight.visible = false
	Panel3.visible = false

func _on_next_buttan_pressed() -> void:
	Pnel.visible = false
	Panel3.visible = true
	get_tree().paused = true
	while  st1 == false:
		Yubi.position.x += speed
		await get_tree().create_timer(0.2).timeout
		Yubi.position.x -= speed
		Yubi.position.x -= speed
		await get_tree().create_timer(0.2).timeout
		Yubi.position.x += speed

#ステップ１の処理
func step1():
	await get_tree().create_timer(5.0).timeout
	#get_tree().paused = true
	Panel2.visible = true
	YRight.visible = true
	while  st1 == true:
		YRight.position.x += speed
		await get_tree().create_timer(0.2).timeout
		YRight.position.x -= speed
		YRight.position.x -= speed
		await get_tree().create_timer(0.2).timeout
		YRight.position.x += speed
	pass

#ステップ２の処理
func _on_next_buttan_2_pressed() -> void:
	count += 1
	st1 = false
	if count <= 1:
		label.text = "次にカードの情報を見てみましょう"
		YLeft.visible = true
		YRight.visible = false
		while count < 2:
			YLeft.position.x -= speed
			await get_tree().create_timer(0.2).timeout
			YLeft.position.x += speed
			YLeft.position.x += speed
			await get_tree().create_timer(0.2).timeout
			YLeft.position.x -= speed
	elif count == 2:
		label.text = "カードの威力80に対して与えたダメージは130となっています"
		YLeft.visible = false
		YRight.visible = false
	elif count == 3:
		label.text = "これはインパクトの効果によりインパクトの数値(1)×50だけダメージが上がった状態です"
	elif count == 4:
		label.text = "これがインパクトの効果です"
	elif count == 5:
		label.text = "カード毎のインパクトの有無と数値はここから確認できます"
		YLeft.visible = true
		while count < 6:
			YLeft.position.x -= speed
			await get_tree().create_timer(0.2).timeout
			YLeft.position.x += speed
			YLeft.position.x += speed
			await get_tree().create_timer(0.2).timeout
			YLeft.position.x -= speed
			Buttan.text = "終了する"
	else:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://TR.tscn")
		BgmPlayer.play_bgm("Home")


func _on_next_button_3_pressed() -> void:
	st1 = true
	Panel3.visible = false
	get_tree().paused = false
