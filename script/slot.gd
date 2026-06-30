extends Control

@export var enemy_slot: Control
@export var is_player: bool = true

var card = null
enum State { EMPTY, CHANTING, COMPLETE, READY_TO_BATTLE }
var state = State.EMPTY
var slot_index: int = 0
var shield_value: int = 0

func can_place():
	return card == null

func place(c, free: bool = false):
	var mana_manager = get_node("/root/Main/ManaManager")
	if not free:
		if is_player:
			if mana_manager.player_mana < c.data.cost:
				print("マナ不足")
				c.queue_free()
				return
			mana_manager.player_mana -= c.data.cost
		else:
			if mana_manager.enemy_mana < c.data.cost:
				c.queue_free()
				return
			mana_manager.enemy_mana -= c.data.cost
	
	card = c
	c.get_parent().remove_child(c)
	add_child(c)
	c.position = $Panel.position
	card.chant_progress = 1
	card.update_magic_circle()
	state = State.CHANTING

func destroy_card(is_break: bool = false):
	if card:
		if is_break:
			if is_player:
				get_tree().current_scene.player_break_count += 1
			else:
				get_tree().current_scene.enemy_break_count += 1
		
			var total = get_tree().current_scene.player_break_count + get_tree().current_scene.enemy_break_count
			print("ブレイク合計:", total)
			if total >= 15:
				GameData.ultimate_unlocked = true
		card.queue_free()
		card = null
	state = State.EMPTY

func progress_turn():
	if card == null or state == State.EMPTY:
		return

	if state == State.CHANTING:
		card.chant_progress += 1
		card.update_magic_circle()
		if card.chant_progress >= card.data.cast_time:
			state = State.COMPLETE
			print("詠唱完了:", name)

	elif state == State.COMPLETE:
		# 詠唱完了から1ターン待った → バトル可能に
		state = State.READY_TO_BATTLE
		print("バトル準備完了:", name)

func _ready():
	add_to_group("slots")
