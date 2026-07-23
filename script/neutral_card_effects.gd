class_name NeutralCardEffects
extends RefCounted

# 属性を持たないニュートラルカード(is_instant)専用の効果集。
# battle_manager.gd の resolve_turn() から、戦闘を介さずに直接呼ばれる。
# slot = 発動した本人のスロット、slot.enemy_slot = 正面の相手スロット。
# is_playerを見て両陣営で対称に動くようにしてある。

static func trigger(tree, slot) -> void:
	var effect = slot.card.data.ability
	var value = slot.card.data.ability_value
	var enemy = slot.enemy_slot

	match effect:
		"促進":
			_haste(slot, value)
		"決壊":
			_break_enemy(tree, enemy)
		"収奪":
			_drain_mana(slot, value)
		"略奪":
			_steal_card(slot, enemy, value)
		"回復":
			_heal(tree, slot, value)
		"封印":
			_seal(enemy)
		"遅延":
			_delay(enemy, value)
		"送還":
			_send_back(slot, enemy, value)
		"献身":
			_sacrifice(tree, slot, value)
		"増援":
			_reinforce(slot, value)

# ==================
# 1. 促進: 隣接する自分の詠唱中カードをvalue枚、詠唱+1進める
# ==================
static func _haste(slot, value: int) -> void:
	var targets = _adjacent_own_slots(slot, value)
	for t in targets:
		if t.card != null and not t.sealed:
			t.card.chant_progress = min(t.card.chant_progress + 1, t.card.actual_cast_time)
			t.card.update_magic_circle()

# ==================
# 2. 決壊: 相手正面の詠唱中カードを、戦闘を介さず直接破壊する(ダメージ無し)
# ==================
static func _break_enemy(tree, enemy) -> void:
	if enemy.card == null:
		return
	var battle_manager = tree.get_node("/root/Main/BattleManager")
	battle_manager.destroy_card_interrupted(enemy)

# ==================
# 3. 収奪: 相手のマナをvalue奪い、自分のマナに加える
# ==================
static func _drain_mana(slot, value: int) -> void:
	var mana_manager = slot.get_node("/root/Main/ManaManager")
	if slot.is_player:
		var taken = min(value, mana_manager.enemy_mana)
		mana_manager.enemy_mana -= taken
		mana_manager.player_mana = min(mana_manager.player_mana + taken, mana_manager.max_mana)
	else:
		var taken = min(value, mana_manager.player_mana)
		mana_manager.player_mana -= taken
		mana_manager.enemy_mana = min(mana_manager.enemy_mana + taken, mana_manager.enemy_max_mana)

# ==================
# 4. 略奪: 相手正面の詠唱中カードを、自分の空きスロットへ奪い取る。奪取後、詠唱進捗をvalue追加で進める
# ==================
static func _steal_card(slot, enemy, value: int) -> void:
	if enemy.card == null:
		return
	var own_slots = slot.get_tree().get_nodes_in_group("slots").filter(
		func(s): return s.is_player == slot.is_player and s.can_place()
	)
	if own_slots.is_empty():
		return

	var dest = own_slots[0]
	var stolen = enemy.card
	var saved_cast_time = stolen.actual_cast_time
	var saved_progress = min(stolen.chant_progress + value, saved_cast_time)

	enemy.card = null
	enemy.state = enemy.State.EMPTY
	enemy.sealed = false

	stolen.get_parent().remove_child(stolen)
	dest.add_child(stolen)
	stolen.position = dest.get_node("Panel").position
	stolen.actual_cast_time = saved_cast_time
	stolen.chant_progress = saved_progress
	stolen.update_magic_circle()

	dest.card = stolen
	dest.state = dest.State.CHANTING

# ==================
# 5. 回復: 自分のHPをvalue×50回復する
# ==================
static func _heal(tree, slot, value: int) -> void:
	var main = tree.current_scene
	var amount = value * 50
	if slot.is_player:
		main.player_hp = min(main.player_hp + amount, main.max_hp)
	else:
		main.enemy_hp = min(main.enemy_hp + amount, main.max_hp)

# ==================
# 6. 封印: 相手正面のスロットを封印する(空でも埋まっていても配置不可・詠唱停止)
# ==================
static func _seal(enemy) -> void:
	enemy.sealed = true

# ==================
# 7. 遅延: 相手正面の詠唱進捗をvalue減らす(最低0)
# ==================
static func _delay(enemy, value: int) -> void:
	if enemy.card != null:
		enemy.card.chant_progress = max(enemy.card.chant_progress - value, 0)
		enemy.card.update_magic_circle()

# ==================
# 8. 送還: 相手正面のカードを除去し、コスト分のマナを相手に返す。自分もvalue分マナを得る
# ==================
static func _send_back(slot, enemy, value: int) -> void:
	if enemy.card == null:
		return
	var mana_manager = slot.get_node("/root/Main/ManaManager")
	var refund = enemy.card.data.cost

	if enemy.is_player:
		mana_manager.player_mana = min(mana_manager.player_mana + refund, mana_manager.max_mana)
	else:
		mana_manager.enemy_mana = min(mana_manager.enemy_mana + refund, mana_manager.enemy_max_mana)

	enemy.card.queue_free()
	enemy.card = null
	enemy.state = enemy.State.EMPTY
	enemy.sealed = false

	if slot.is_player:
		mana_manager.player_mana = min(mana_manager.player_mana + value, mana_manager.max_mana)
	else:
		mana_manager.enemy_mana = min(mana_manager.enemy_mana + value, mana_manager.enemy_max_mana)

# ==================
# 9. 献身: 自分のHPをvalue×20消費して、value分のマナを得る
# ==================
static func _sacrifice(tree, slot, value: int) -> void:
	var main = tree.current_scene
	var mana_manager = slot.get_node("/root/Main/ManaManager")
	var cost = value * 20

	if slot.is_player:
		main.player_hp = max(main.player_hp - cost, 1)
		mana_manager.player_mana = min(mana_manager.player_mana + value, mana_manager.max_mana)
	else:
		main.enemy_hp = max(main.enemy_hp - cost, 1)
		mana_manager.enemy_mana = min(mana_manager.enemy_mana + value, mana_manager.enemy_max_mana)

# ==================
# 10. 増援: 自分のデッキ(必殺技を除く)からvalue枚をランダムに、隣接する空きスロットへコスト無しで配置する
# ==================
static func _reinforce(slot, value: int) -> void:
	var source_deck: Array = GameData.player_deck if slot.is_player else GameData.enemy_deck
	var pool = source_deck.filter(func(c): return c != null and not c.is_ultimate and not c.is_instant)
	if pool.is_empty():
		return

	var targets = _adjacent_own_slots(slot, value).filter(func(s): return s.can_place())
	var card_scene = load("res://card_node.tscn")

	for t in targets:
		var picked = pool.pick_random()
		var new_card = card_scene.instantiate()
		new_card.data = picked
		t.get_tree().root.add_child(new_card)
		t.place(new_card, true)

# ==================
# 共通ヘルパー
# ==================

# slotと同じ側の隣接スロットを、近い順にcount個まで返す
static func _adjacent_own_slots(slot, count: int) -> Array:
	var result = []
	var parent = slot.get_parent()
	var all_slots = parent.get_children()
	var center = slot.slot_index

	var offsets = [-1, 1, -2, 2, -3, 3, -4, 4]
	for offset in offsets:
		if result.size() >= count:
			break
		var idx = center + offset
		if idx >= 0 and idx < all_slots.size():
			result.append(all_slots[idx])
	return result

# 基礎攻撃カードが通常解決したときに呼ばれる。is_player側の封印を1つ解除する
static func release_seal(tree, is_player_side: bool) -> void:
	var sealed_slots = tree.get_nodes_in_group("slots").filter(
		func(s): return s.is_player == is_player_side and s.sealed
	)
	if sealed_slots.size() > 0:
		sealed_slots[0].sealed = false
