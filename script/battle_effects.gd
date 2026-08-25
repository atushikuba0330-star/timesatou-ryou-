class_name BattleEffects
extends RefCounted

# 詠唱が完了した瞬間に、飛び道具(projectile.tscn)を1つ画面に出して、
# 発射位置(from_position)から着地位置(to_position)へ飛ばすための関数。

static func spawn_projectile(tree, texture: Texture2D, from_position: Vector2, to_position: Vector2) -> void:
	var projectile_scene = preload("res://projectile.tscn")
	var projectile = projectile_scene.instantiate()
	tree.current_scene.add_child(projectile)
	projectile.global_position = from_position
	if texture:
		projectile.get_node("TextureRect").texture = texture
	projectile.fly_to(to_position)

# 全スロットの詠唱チェックが終わったあとに呼ばれる。
# 「自分と相手が両方同時に詠唱完了したか」を見て、
# 揃っていれば中間地点でぶつけ、揃っていなければ相手のスロットへ1本飛ばす。
static func fire_completed_projectiles(tree) -> void:
	var slots = tree.get_nodes_in_group("slots")
	var handled = []

	for slot in slots:
		if slot in handled:
			continue
		if not slot.just_completed:
			continue

		var enemy = slot.enemy_slot

		if enemy.just_completed:
			# 同時発動：中間地点でぶつける
			var midpoint = (slot.global_position + enemy.global_position) / 2
			spawn_projectile(tree, slot.card.data.projectile_icon, slot.global_position, midpoint)
			spawn_projectile(tree, enemy.card.data.projectile_icon, enemy.global_position, midpoint)
			handled.append(slot)
			handled.append(enemy)
		else:
			# 片方だけ：相手のスロットへ
			spawn_projectile(tree, slot.card.data.projectile_icon, slot.global_position, enemy.global_position)
			handled.append(slot)

	# 次の周期のために印をリセットする
	for slot in slots:
		slot.just_completed = false

# 必殺技専用の演出。属性ごとに違うパターンで魔法陣を配置し、
# それぞれの場所から相手のスロットへ同時に発射する。
# slot = 発動した本人のスロット、enemy = 相手のスロット。
static func fire_ultimate_burst(tree, card, slot, enemy) -> void:
	var element = card.data.element
	var points = _get_ultimate_points(element, slot, enemy)
	var target_scale = _get_ultimate_scale(element)
	var textures = card.data.magic_circles

	var stagger_interval = 0.12  # 出現の間隔
	var common_hold_after_last = 1.0  # 全部出そろってから消えるまでの時間
	var count = points.size()

	for i in range(count):
		var pos = points[i]
		var texture = null
		if textures.size() > 0:
			texture = textures[i % textures.size()]  # 画像の数より点が多い場合は使い回す

		# 全部が同時に消えるように、後から出てくるものほど表示時間を短くして帳尻を合わせる
		var hold_time = (count - 1 - i) * stagger_interval + common_hold_after_last

		_spawn_burst_circle(tree, texture, pos, target_scale, hold_time)
		spawn_projectile(tree, card.data.projectile_icon, pos, enemy.global_position)

		# 次の魔法陣を出すまで少し間を空ける(全部同時に出さず、次々と出現させる)
		await tree.create_timer(stagger_interval).timeout

# 1箇所に魔法陣を出現させて、hold_time秒間回転しながら表示されたあと消える
static func _spawn_burst_circle(tree, texture: Texture2D, pos: Vector2, target_scale: Vector2, hold_time: float) -> void:
	if texture == null:
		return
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.z_as_relative = false
	sprite.z_index = 100
	tree.current_scene.add_child(sprite)
	sprite.global_position = pos
	sprite.scale = Vector2(0.05, 0.05)

	var scale_up_time = 0.3

	# 拡大 → hold_time待つ → 消える
	var tween = sprite.create_tween()
	tween.tween_property(sprite, "scale", target_scale, scale_up_time)
	tween.tween_interval(hold_time)
	tween.tween_callback(sprite.queue_free)

	# 表示されている間、ずっと回転させ続ける(別のtweenで並行に動かす)
	var rotate_tween = sprite.create_tween()
	rotate_tween.set_trans(Tween.TRANS_LINEAR)
	rotate_tween.tween_property(sprite, "rotation", TAU * 3, scale_up_time + hold_time)

# 属性ごとの魔法陣の大きさ
static func _get_ultimate_scale(element: String) -> Vector2:
	match element:
		"火":
			return Vector2(0.3, 0.3)
		"水":
			return Vector2(0.12, 0.12)
		"雷":
			return Vector2(0.28, 0.28)
		"光":
			return Vector2(0.5, 0.5)
		"闇":
			return Vector2(0.45, 0.45)
	return Vector2(0.3, 0.3)

# 属性ごとの出現位置パターン
static func _get_ultimate_points(element: String, slot, enemy) -> Array:
	match element:
		"火":
			# 自分側の5スロット、それぞれの真上に1つずつ
			return _own_side_slot_positions(slot)
		"水":
			# 相手側の列全体を、下向きに垂れ下がる弧で囲むように小さいものを大量に
			return _water_points(slot)
		"雷":
			# 相手のスロット周辺に中型のものを3箇所
			return [
				enemy.global_position + Vector2(-150, -80),
				enemy.global_position + Vector2(150, -80),
				enemy.global_position + Vector2(0, 120),
			]
		"光":
			# 相手のスロットに大型のものを展開
			return [
				enemy.global_position + Vector2(-100, 0),
				enemy.global_position + Vector2(100, 0),
			]
		"闇":
			# 自分の側から大きな斜め一列
			return _line_points(slot.global_position, 5, 150, Vector2(1, 1).normalized())
	return [slot.global_position]

# 発動したスロットと同じ側(is_playerが同じ)の全スロットの位置を、
# slot_index順に並べて返す(火で使用)
static func _own_side_slot_positions(slot) -> Array:
	var all_slots = slot.get_tree().get_nodes_in_group("slots")
	var same_side = all_slots.filter(func(s): return s.is_player == slot.is_player)
	same_side.sort_custom(func(a, b): return a.slot_index < b.slot_index)

	var positions = []
	for s in same_side:
		positions.append(s.global_position)
	return positions

# 中心位置から、指定した方向に沿って等間隔にcount個の点を並べる(闇で使用)
static func _line_points(center: Vector2, count: int, spacing: float, direction: Vector2) -> Array:
	var points = []
	var start_offset = -(count - 1) / 2.0
	for i in range(count):
		points.append(center + direction * (start_offset + i) * spacing)
	return points

# 発動したスロットの「相手側」の全スロットの位置を、slot_index順に並べて返す
static func _opposite_side_slot_positions(slot) -> Array:
	var all_slots = slot.get_tree().get_nodes_in_group("slots")
	var opposite_side = all_slots.filter(func(s): return s.is_player != slot.is_player)
	opposite_side.sort_custom(func(a, b): return a.slot_index < b.slot_index)

	var positions = []
	for s in opposite_side:
		positions.append(s.global_position)
	return positions

# 相手側の列の左端〜右端の間に、浅い弧(外側)と深い弧(内側)を
# 互い違いにずらして重ねる(水で使用)
static func _water_points(slot) -> Array:
	var opponent_row = _opposite_side_slot_positions(slot)
	if opponent_row.size() == 0:
		return []

	var left = opponent_row[0].x
	var right = opponent_row[opponent_row.size() - 1].x
	var base_y = opponent_row[0].y

	# 自分側の列のY座標との間を、弧が垂れ下がる範囲にする
	var own_row = _own_side_slot_positions(slot)
	var own_y = base_y
	if own_row.size() > 0:
		own_y = own_row[0].y
	var gap = own_y - base_y

	var points = []

	# 外側の弧：浅め(敵側に近い)。7箇所
	var outer_count = 7
	for i in range(outer_count):
		var t = float(i) / float(outer_count - 1)
		var x = lerp(left, right, t)
		var y = base_y + gap * 0.35 * sin(PI * t)
		points.append(Vector2(x, y))

	# 内側の弧：深め(自分側に近い)。外側の隙間を埋めるように半分ずらす。6箇所
	var inner_count = outer_count - 1
	for i in range(inner_count):
		var t = (float(i) + 0.5) / float(outer_count - 1)
		var x = lerp(left, right, t)
		var y = base_y + gap * 0.65 * sin(PI * t)
		points.append(Vector2(x, y))

	return points
