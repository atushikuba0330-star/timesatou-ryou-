class_name CardCombat
extends RefCounted

# card_node.gd から戦闘力計算（レリック補正込み）だけを切り出したユーティリティ。
# card は CardNode(Control) のインスタンスを想定。

static func compute_power(card) -> int:
	if card.data == null:
		return 0

	var base_power = int(card.data.power * (float(card.chant_progress) / float(card.actual_cast_time)))

	for relic in GameData.player_relics:
		if relic.relic_type == "black_pact" and card.is_player_card():
			base_power = int(base_power * 1.2)
		if relic.relic_type == "blood_pact" and card.is_player_card():
			var scene = card.get_tree().current_scene
			var hp_lost = scene.max_hp - scene.player_hp
			var bonus = int(hp_lost / 100) * relic.value
			base_power = int(base_power * (1.0 + bonus / 100.0))
		if relic.relic_type == "ult_boost" and card.is_player_card() and card.data.is_ultimate:
			base_power = int(base_power * 1.5)

	return base_power
