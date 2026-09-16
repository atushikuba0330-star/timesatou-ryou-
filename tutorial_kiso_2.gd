extends Node2D

var lines = [
	{"name": "クロ", "text": "ここが戦いのフィールドだ"},
	{"name": "クロ", "text": "こっちが君のHPゲージで","pos": Vector2(0.85,0.85), "size": Vector2(0.08, 0.03)},
	{"name": "クロ", "text": "こっちが相手のHPゲージだ","pos": Vector2(0.85, 0.1), "size": Vector2(0.08, 0.03)},
	{"name": "クロ", "text": "勝負としては
	相手のHPゲージを削り切ったものが勝者という実に単純なものだ"},
	{"name": "クロ", "text": "もちろん君に素手やその辺の木の棒で戦ってもらうわけじゃない"},
	{"name": "クロ", "text": "君にはカードを使って魔法で戦ってもらう"},
	{"name": "クロ", "text": "これがカード","pos": Vector2(0.815,0.335), "size": Vector2(0.03, 0.07)},
	{"name": "クロ", "text": "正確に言うとこれはカードの型だな"},
	{"name": "クロ", "text": "マナを使ってカードを生成し","pos": Vector2(0.865,0.9), "size": Vector2(0.1, 0.01)},
	{"name": "クロ", "text": "このスロットに置くことで魔法を発動できる","pos": Vector2(0.437,0.725), "size": Vector2(0.02, 0.07)},
	{"name": "クロ", "text": "次はカードの説明だ"},
	{"name": "クロ", "text": "カードにカーソル合わせるとこのように拡大されたもの表示される","pos": Vector2(0.21,0.32), "size": Vector2(0.075, 0.223), "show_card_info": true},
	{"name": "クロ", "text": "詠唱数や二つあるパワーについては、このあとで説明するので","show_card_info": true, "hold_spotlight": true},
	{"name": "クロ", "text": "今はこの位置の数字がこういう名前ということを覚えてくれればいい","show_card_info": true, "hold_spotlight": true},
	{"name": "クロ", "text": "それから、
	この部分にはアビリティが入るんだがそれはまた今度教えよう","pos": Vector2(0.21,0.4), "size": Vector2(0.07, 0.04), "show_card_info": true},
	{"name": "クロ", "text": "ここからは戦闘について覚えてもらおうか"},
	{"name": "クロ", "text": "戦闘が始まるとマナがたまり始める","pos": Vector2(0.865,0.9), "size": Vector2(0.1, 0.01), "start_mana": true},
	{"name": "クロ", "text": "マナがたまったらスロットにカードをセットできる", "pos": Vector2(0.815,0.335), "size": Vector2(0.03, 0.07), "pos2": Vector2(0.437,0.725), "size2": Vector2(0.02, 0.07), "force_mana_full": true, "wait_for_card": true},
	{"name": "クロ", "text": "カードをスロットにセットすると詠唱が行われ魔法陣が出現する"},
	{"name": "クロ", "text": "詠唱はマナがたまるのと同時に進んで行き", "chant_step": true},
	{"name": "クロ", "text": "先ほどの右上の数字の数だけ出現する", "chant_step": true},
	{"name": "クロ", "text": "さて、それではあの的に向かって打ってもらおうか"},
	{"name": "クロ", "text": "","attack": true},
	{"name": "クロ", "text": "うむ、うまくいったみたいだな", "clear_after_attack": true},
	{"name": "クロ", "text": "これで君は戦い方の基礎を知ったことだと思う"},
	{"name": "クロ", "text": "あとは習うより慣れろだ"},
	{"name": "クロ", "text": "せいぜい私のためにも勝ってくれることを期待しているよ"},
]

var current_line := 0
var spotlight_tween: Tween = null
var placed_card = null

func _ready():
	$UI/ColorRect.material.set_shader_parameter("hole_size", Vector2(2.0, 2.0))
	$UI/EnemyHPBar.max_value = 100
	$UI/EnemyHPBar.value = 100
	$UI/PlayerHPBar.max_value = 100
	$UI/PlayerHPBar.value = 100
	show_line()

func _input(event):
	if event is InputEventMouseMotion and dragging_card:
		dragging_card.global_position = get_global_mouse_position() - dragging_card.size * dragging_card.scale / 2
		return

	if event is InputEventMouseButton:
		if lines[current_line].get("wait_for_card", false):
			if event.pressed:
				if dragging_card == null and $UI/blank_card.get_global_rect().has_point(event.position):
					dragging_card = $UI/blank_card.duplicate()
					$UI.add_child(dragging_card)
					dragging_card.global_position = get_global_mouse_position() - dragging_card.size * dragging_card.scale / 2
			else:
				if dragging_card:
					if $UI/slot.get_global_rect().has_point(event.position):
						_place_card()
					else:
						dragging_card.queue_free()
						dragging_card = null
			return
		if event.pressed:
			next_line()

func move_spotlight(target_pos: Vector2, target_size: Vector2):
	if spotlight_tween:
		spotlight_tween.kill()
	var mat = $UI/ColorRect.material
	mat.set_shader_parameter("hole2_size", Vector2.ZERO)
	spotlight_tween = create_tween()
	spotlight_tween.tween_property(mat, "shader_parameter/hole_size", Vector2(2.0, 2.0), 0.4)
	spotlight_tween.tween_callback(func(): mat.set_shader_parameter("hole_position", target_pos))
	spotlight_tween.tween_property(mat, "shader_parameter/hole_size", target_size, 0.6)

func move_spotlight_dual(pos1: Vector2, size1: Vector2, pos2: Vector2, size2: Vector2):
	if spotlight_tween:
		spotlight_tween.kill()
	var mat = $UI/ColorRect.material
	spotlight_tween = create_tween()
	spotlight_tween.set_parallel(true)
	spotlight_tween.tween_property(mat, "shader_parameter/hole_position", pos1, 0.4)
	spotlight_tween.tween_property(mat, "shader_parameter/hole_size", size1, 0.4)
	spotlight_tween.tween_property(mat, "shader_parameter/hole2_position", pos2, 0.4)
	spotlight_tween.tween_property(mat, "shader_parameter/hole2_size", size2, 0.4)

const CARD_SHOW_LINE := 6  # この行番号(0始まり)から表示する
const CARD_UP := 11
const Kakasi := 21
func show_line():
	$UI/name.text = lines[current_line]["name"]
	$UI/text.text = lines[current_line]["text"]

	if not lines[current_line].get("hold_spotlight", false):
		var pos = lines[current_line].get("pos", Vector2(0.5, 0.5))
		var size = lines[current_line].get("size", Vector2(2.0, 2.0))
		if lines[current_line].has("pos2"):
			var pos2 = lines[current_line]["pos2"]
			var size2 = lines[current_line].get("size2", Vector2(0.1, 0.1))
			move_spotlight_dual(pos, size, pos2, size2)
		else:
			move_spotlight(pos, size)

	if lines[current_line].get("force_mana_full", false):
		tutorial_mana = TUTORIAL_MAX_MANA
		update_mana_display()

	if lines[current_line].get("chant_step", false):
		add_chant_step()

	if lines[current_line].get("start_mana", false):
			mana_loop()
	
	if lines[current_line].get("wait_for_card", false) and guide_tween == null:
		start_guide_loop()
	if lines[current_line].get("attack", false):
		play_attack()
		
	if lines[current_line].get("clear_after_attack", false):
		apply_damage_and_cleanup()

	$UI/blank_card.visible = current_line >= CARD_SHOW_LINE
	$UI/slot.visible = current_line >= CARD_SHOW_LINE
	$UI/CardInfoPanel.visible = lines[current_line].get("show_card_info", false)
	$UI/cardUP.visible = current_line >= CARD_UP
	$UI/kakasi.visible = current_line >= Kakasi

func end_conversation():
	get_tree().change_scene_to_file("res://titole.tscn")

func next_line():
	current_line += 1
	if current_line >= lines.size():
		end_conversation()
		return
	show_line()
	
func _on_skip_button_pressed() -> void:
	end_conversation()
var tutorial_mana := 0
const TUTORIAL_MAX_MANA := 3

func update_mana_display():
	$UI/PlayerMPBar.value = tutorial_mana

func mana_loop():
	$UI/PlayerMPBar.max_value = TUTORIAL_MAX_MANA
	while tutorial_mana < TUTORIAL_MAX_MANA:
		await get_tree().create_timer(3.0).timeout
		tutorial_mana += 1
		update_mana_display()

var dragging_card = null
var guide_ghost = null
var guide_tween: Tween = null

func start_guide_loop():
	guide_ghost = $UI/blank_card.duplicate()
	guide_ghost.modulate.a = 0.5
	$UI.add_child(guide_ghost)
	var start_pos = $UI/blank_card.global_position
	var end_pos = $UI/slot.global_position
	guide_tween = create_tween()
	guide_tween.set_loops()
	guide_tween.tween_property(guide_ghost, "global_position", end_pos, 1.5)
	guide_tween.tween_interval(0.3)
	guide_tween.tween_callback(func(): guide_ghost.global_position = start_pos)
	guide_tween.tween_interval(0.3)

func _place_card():
	if guide_tween:
		guide_tween.kill()
	if guide_ghost:
		guide_ghost.queue_free()

	$UI.remove_child(dragging_card)
	$UI/slot.add_child(dragging_card)
	dragging_card.position = Vector2(-3.5,-13)
	placed_card = dragging_card
	dragging_card = null
	magic_circle_index = 0

	tutorial_mana = 0
	update_mana_display()
	add_magic_circle()
	next_line()

var magic_circle_index := 0
var magic_circles := []
var attack_swords := []
var attack_tweens := []

const MAGIC_CIRCLE_TEXTURES = [
	preload("res://irasto/Normal/Ma1b-line-light/ma1b-yellow.png"),
	preload("res://irasto/Normal/Ma1b-line-light/ma1b-purple.png"),
	preload("res://irasto/Normal/Ma1b-line-light/ma1b-blue.png"),
]
const MAGIC_CIRCLE_SCALES = [
	Vector2(0.23, 0.23),
	Vector2(0.23, 0.23),
	Vector2(0.35, 0.35),
]
const MAGIC_CIRCLE_POSITIONS = [
	Vector2(0, 80),
	Vector2(100, 20),
	Vector2(60, 80),
]

func add_magic_circle():
	if magic_circle_index >= MAGIC_CIRCLE_TEXTURES.size():
		return
	var circle = Sprite2D.new()
	circle.texture = MAGIC_CIRCLE_TEXTURES[magic_circle_index]
	circle.position = MAGIC_CIRCLE_POSITIONS[magic_circle_index]
	circle.scale = MAGIC_CIRCLE_SCALES[magic_circle_index]
	$UI/slot.add_child(circle)
	$UI/slot.move_child(circle, 1)
	magic_circles.append(circle)
	magic_circle_index += 1

func add_chant_step():
	tutorial_mana = min(tutorial_mana + 1, TUTORIAL_MAX_MANA)
	update_mana_display()
	add_magic_circle()

func _process(delta):
	for c in magic_circles:
		if is_instance_valid(c):
			c.rotation += delta

func play_attack():
	var target_pos = Vector2(1100, 200)  # kakasiの中心
	var start_pos = Vector2(1100, 1000)  # slotの中心
	var sword_texture = $UI/Eirinanamidanokenn.texture

	# 左の剣:左下で左に315度回転
	_attack_sword(sword_texture, start_pos + Vector2(-60, 0), target_pos + Vector2(-90, 70), -315)
	# 真ん中の剣:通り過ぎてから右に540度回転
	_attack_sword(sword_texture, start_pos, target_pos + Vector2(0, -90), 540)
	# 右の剣:右下で右に315度回転
	_attack_sword(sword_texture, start_pos + Vector2(60, 0), target_pos + Vector2(90, 70), 315)

func apply_damage_and_cleanup():
	$UI/EnemyHPBar.value -= 30

	for t in attack_tweens:
		if t and t.is_valid():
			t.kill()
	attack_tweens.clear()

	if placed_card:
		placed_card.queue_free()
		placed_card = null
	for c in magic_circles:
		if is_instance_valid(c):
			c.queue_free()
	magic_circles.clear()
	for s in attack_swords:
		if is_instance_valid(s):
			s.queue_free()
	attack_swords.clear()
func _attack_sword(texture, from_pos: Vector2, to_pos: Vector2, spin_degrees: float):
	var sword = Sprite2D.new()
	sword.texture = texture
	sword.scale = Vector2(0.15, 0.15)
	sword.rotation = -PI / 2
	$UI.add_child(sword)
	sword.global_position = from_pos
	attack_swords.append(sword)

	var tween = create_tween()
	attack_tweens.append(tween)
	tween.tween_property(sword, "global_position", to_pos, 1.0)
	tween.tween_interval(0.2)
	tween.tween_property(sword, "rotation", sword.rotation + deg_to_rad(spin_degrees), 0.8)
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		var facing = Vector2.RIGHT.rotated(sword.rotation)
		var pull_back_pos = sword.global_position - facing * 120
		var stab_tween = create_tween()
		stab_tween.tween_property(sword, "global_position", pull_back_pos, 0.3)
		stab_tween.tween_property(sword, "global_position", to_pos, 0.2)
	)
