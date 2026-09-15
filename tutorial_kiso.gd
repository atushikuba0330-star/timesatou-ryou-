extends Node2D

var lines = [
	{"name": "？？", "text": "ようこそ、我々の世界へ。とでも言っておこうか"},
	{"name": "？？", "text": "自己紹介をしたいところだが、あいにくここは匿名性でね"},
	{"name": "クロ", "text": "ひとまずは、クロとでも呼んでくれ"},
	{"name": "クロ", "text": "君は自らの意志でこの戦いに参加し、競走馬になることを選んだと思うのだが"},
	{"name": "クロ", "text": "私は君に最も多くチップを賭けた、スポンサーといったところだ"},
	{"name": "クロ", "text": "なので君に勝ってもらいたいわけだ。"},
	{"name": "クロ", "text": "ということでまずは基礎から覚えてもらおうと思う"},
]

var current_line := 0
var auto_mode := false

func _ready():
	show_line()

func show_line():
	$CanvasLayer/caraname.text = lines[current_line]["name"]
	$CanvasLayer/texte.text = lines[current_line]["text"]

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		next_line()

func end_conversation():
	print("会話終了")
	$Timer.stop()

func next_line():
	current_line += 1
	if current_line >= lines.size():
		end_conversation()
		return
	show_line()

func _on_skip_button_pressed() -> void:
	end_conversation()


func _on_auto_button_pressed() -> void:
	auto_mode = !auto_mode
	if auto_mode:
		$Timer.start()
	else:
		$Timer.stop()


func _on_timer_timeout() -> void:
	next_line()
