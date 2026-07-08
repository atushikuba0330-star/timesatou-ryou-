extends Control

# ==================
# 変数
# ==================
@export var enemy_slot: Control
@export var is_player: bool = true
@onready var shield_overlay = $ShieldOverlay
var card = null
var slot_index: int = 0
var shield_value: int = 0
enum State { EMPTY, CHANTING, COMPLETE, READY_TO_BATTLE }
var state = State.EMPTY

# ==================
# 基本関数
# ==================
func _ready():
	add_to_group("slots")

func _process(delta):
	if shield_overlay:
		shield_overlay.visible = shield_value > 0

func can_place():
	return card == null

# ==================
# カード配置
# ==================
func place(c, free: bool = false):
	var mana_manager = get_node("/root/Main/ManaManager")
	
	# コスト計算（軽業師の手袋）
	var cost_reduction = 0
	for relic in GameData.player_relics:
		if relic.relic_type == "cost_down" and is_player:
			cost_reduction += relic.value
	
	if not free:
		if is_player:
			var actual_cost = max(c.data.cost - cost_reduction, 0)
			if mana_manager.player_mana < actual_cost:
				print("マナ不足")
				c.queue_free()
				return
			mana_manager.player_mana -= actual_cost
		else:
			var actual_enemy_cost = c.data.cost + GameData.enemy_cost_penalty
			if mana_manager.enemy_mana < actual_enemy_cost:
				c.queue_free()
				return
			mana_manager.enemy_mana -= actual_enemy_cost
	
	card = c
	c.get_parent().remove_child(c)
	add_child(c)
	c.position = $Panel.position
	
	# 詠唱数計算（詠唱の書・移動のダイス・封印の鎖）
	var cast_reduction = 0
	for relic in GameData.player_relics:
		if relic.relic_type == "cast_time_down" and is_player:
			cast_reduction += relic.value
		if relic.relic_type == "move_dice" and is_player:
			cast_reduction -= 1
		if relic.relic_type == "enemy_cast_up" and not is_player:
			cast_reduction -= relic.value
	
	card.actual_cast_time = max(card.data.cast_time - cast_reduction, 1)
	card.chant_progress = 1
	card.update_magic_circle()
	state = State.CHANTING

# ==================
# カード破壊
# ==================
func destroy_card(is_break: bool = false):
	if card:
		if is_break:
			if is_player:
				get_tree().current_scene.player_break_count += 1
			else:
				get_tree().current_scene.enemy_break_count += 1
			
			var total = get_tree().current_scene.player_break_count + get_tree().current_scene.enemy_break_count
			if total >= 15:
				GameData.ultimate_unlocked = true
		card.queue_free()
		card = null
	state = State.EMPTY

# ==================
# ターン進行
# ==================
func progress_turn():
	if card == null or state == State.EMPTY:
		return
	
	if state == State.CHANTING:
		print("詠唱進捗:", card.chant_progress, "/", card.actual_cast_time, " slot:", name)
		card.chant_progress += 1
		card.update_magic_circle()
		
		# 移動のダイス：詠唱完了のタイミングで移動
		if is_player:
			for relic in GameData.player_relics:
				if relic.relic_type == "move_dice":
					if card.chant_progress == card.actual_cast_time:
						print("移動のダイス発動")
						_move_to_random_slot()
						return
		
		# 詠唱完了チェック
		if card.chant_progress >= card.actual_cast_time:
			state = State.COMPLETE
			print("詠唱完了:", name)
			
			# 賢者の指輪
			if is_player:
				for relic in GameData.player_relics:
					if relic.relic_type == "mana_recover":
						var mana_manager = get_node("/root/Main/ManaManager")
						mana_manager.player_mana = min(mana_manager.player_mana + relic.value, mana_manager.max_mana)
	
	elif state == State.COMPLETE:
		state = State.READY_TO_BATTLE
		print("バトル準備完了:", name)

# ==================
# 移動のダイス
# ==================
func _move_to_random_slot():
	var all_slots = get_tree().get_nodes_in_group("slots")
	var empty_slots = all_slots.filter(func(s): return s.is_player and s.can_place())
	if empty_slots.size() == 0:
		return
	
	var target = empty_slots.pick_random()
	var c = card
	var saved_actual_cast_time = c.actual_cast_time
	var saved_chant_progress = c.chant_progress
	card = null
	state = State.EMPTY
	
	c.get_parent().remove_child(c)
	target.add_child(c)
	c.position = target.get_node("Panel").position
	c.actual_cast_time = saved_actual_cast_time
	c.chant_progress = saved_chant_progress
	target.card = c
	target.state = State.CHANTING
