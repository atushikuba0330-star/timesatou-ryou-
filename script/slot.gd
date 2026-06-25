extends Control
var card = null
@export var enemy_slot: Control
@export var is_player: bool = true
signal chant_finished(slot)

# 状態管理
enum State { EMPTY, CHANTING, COMPLETE, READY_TO_BATTLE }
var state = State.EMPTY

func can_place():
	return card == null

func place(c):
	var mana_manager = get_node("/root/Main/ManaManager")

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
	c.position = Vector2.ZERO

	card.chant_progress = 1
	card.update_magic_circle()
	state = State.CHANTING

func destroy_card():
	if card:
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
