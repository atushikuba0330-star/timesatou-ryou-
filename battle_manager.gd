extends Node

# ターン終了時の戦闘処理
func resolve_turn():

	# 戦闘可能状態のスロットを格納
	var battle_slots = []

	# 全スロットからREADY_TO_BATTLEのものを探す
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.state == slot.State.READY_TO_BATTLE:
			battle_slots.append(slot)

	# 二重処理防止用
	var processed = []

	# 戦闘可能なスロットを順番に処理
	for slot in battle_slots:

		# 既に戦闘済みならスキップ
		if slot in processed:
			continue

		# カードが無い場合はスキップ
		if slot.card == null:
			continue

		# ニュートラル即時カードなら戦闘せず効果だけ発動
		if slot.card.data.is_instant:

			# カード効果発動
			NeutralCardEffects.trigger(get_tree(), slot)

			# 使用後カード削除
			slot.destroy_card()

			# 処理済み登録
			processed.append(slot)
			continue

		# 対面の敵スロット取得
		var enemy = slot.enemy_slot

		# 相手も戦闘準備完了しており
		# 未処理かつシールドが無い場合
		if enemy in battle_slots \
		and enemy not in processed \
		and enemy.shield_value == 0:

			# カード同士の戦闘を実行
			CombatResolver.resolve_pair(
				self,
				slot,
				enemy
			)

			# 両者を処理済みにする
			processed.append(slot)
			processed.append(enemy)

		else:

			# 相手が詠唱中やシールド状態の場合
			# 一方的な攻撃を行う
			CombatResolver.resolve_vs_chanting(
				self,
				slot
			)

			# 処理済み登録
			processed.append(slot)
			processed.append(enemy)


# 戦闘終了後の共通処理
# 能力発動・勝利カウント・カード削除を行う
func finish_card_with_ability(
	slot,
	count_as_win: bool = true
):

	# カードが存在する場合のみ処理
	if slot.card:

		# プレイヤーの火属性カードが勝利した場合
		if count_as_win \
		and slot.card.data.element == "火" \
		and slot.is_player:

			# 火属性勝利数を加算
			GameData.fire_win_count += 1

			# 火属性で5勝するとアルティメット解放
			if GameData.fire_win_count >= 5:
				GameData.ultimate_unlocked = true

		# 基礎攻撃カードの場合
		# (能力なし・アルティメットでない・即時発動でない)
		if slot.card.data.ability == "" \
		and not slot.card.data.is_ultimate \
		and not slot.card.data.is_instant:

			# 味方側の封印を1つ解除
			NeutralCardEffects.release_seal(
				get_tree(),
				slot.is_player
			)

		# カード能力を発動
		activate_ability(slot)

		# カード消滅アニメーション
		await slot.card.play_zoom_out()

		# カード削除
		slot.destroy_card()


# 戦闘中断時のカード破壊処理
func destroy_card_interrupted(slot):

	# カードが無ければ終了
	if slot.card == null:
		return

	# カード破壊演出
	await slot.card.play_break_apart()

	# 強制削除
	slot.destroy_card(true)


# カード能力発動処理
func activate_ability(slot):

	# AbilityManager取得
	var ability_manager = get_node_or_null(
		"/root/Main/AbilityManager"
	)

	# AbilityManagerが存在しない場合は終了
	if ability_manager == null:
		return

	# デバッグ用ログ
	print(
		"activate_ability呼ばれた:",
		slot.card.data.ability
	)

	# AbilityManagerへ能力処理を渡す
	ability_manager.activate_ability(slot)
