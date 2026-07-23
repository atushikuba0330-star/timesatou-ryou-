extends Control

const ABILITY_SLOT_START := 1
const ABILITY_SLOT_COUNT := 4
const NEUTRAL_SLOT_START := 5
const NEUTRAL_SLOT_COUNT := 3

const CARD_FONT := preload("res://irasto/Cinzel-VariableFont_wght.ttf")

@onready var deck_row: HBoxContainer = $Margin/VBox/DeckRow
@onready var pool_grid: GridContainer = $Margin/VBox/PoolScroll/PoolGrid
@onready var confirm_button: Button = $Margin/VBox/ConfirmButton
@onready var relic_grid: GridContainer = $Margin/VBox/RelicGrid

var selected_slot_index: int = -1  # 入れ替え対象として選択中のアビリティスロット(1〜4)

func _ready():
	confirm_button.pressed.connect(_on_confirm_pressed)
	refresh_all()

func refresh_all():
	_populate_deck_row()
	_populate_pool_grid()
	_populate_relic_row()

func _populate_deck_row():
	for child in deck_row.get_children():
		child.queue_free()

	for i in range(GameData.player_deck.size()):
		var card = GameData.player_deck[i]
		var btn = _make_card_display(card)
		var is_ability_slot = i >= ABILITY_SLOT_START and i < ABILITY_SLOT_START + ABILITY_SLOT_COUNT
		var is_neutral_slot = i >= NEUTRAL_SLOT_START and i < NEUTRAL_SLOT_START + NEUTRAL_SLOT_COUNT

		if is_ability_slot or is_neutral_slot:
			btn.pressed.connect(_on_ability_slot_pressed.bind(i))
			if i == selected_slot_index:
				btn.modulate = Color(1.0, 1.0, 0.5)  # 選択中をハイライト
		else:
			btn.disabled = true  # 基本攻撃カード・必殺技カードは固定
			btn.modulate = Color(0.7, 0.7, 0.7)

		deck_row.add_child(btn)

func _populate_pool_grid():
	for child in pool_grid.get_children():
		child.queue_free()

	for card in GameData.owned_cards:
		var btn = _make_card_display(card)
		btn.pressed.connect(_on_pool_card_pressed.bind(card))
		pool_grid.add_child(btn)

	if GameData.owned_cards.is_empty():
		var label = Label.new()
		label.text = "所持カードはまだありません"
		label.add_theme_font_override("font", CARD_FONT)
		pool_grid.add_child(label)

func _populate_relic_row():
	for child in relic_grid.get_children():
		child.queue_free()

	for relic in GameData.player_relics:
		var btn = _make_relic_display(relic)
		relic_grid.add_child(btn)

	if GameData.player_relics.is_empty():
		var label = Label.new()
		label.text = "お宝はまだありません"
		label.add_theme_font_override("font", CARD_FONT)
		relic_grid.add_child(label)

func _make_card_display(card: CardData) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(170, 230)
	btn.clip_contents = true

	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	btn.add_child(vbox)

	if card == null:
		var empty_label = Label.new()
		empty_label.text = "特殊カード\n(空き枠)"
		empty_label.add_theme_font_override("font", CARD_FONT)
		empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		empty_label.add_theme_font_size_override("font_size", 15)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(empty_label)
		return btn

	if card.icon:
		var icon = TextureRect.new()
		icon.texture = card.icon
		icon.custom_minimum_size = Vector2(0, 110)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(icon)

	var name_label = Label.new()
	name_label.text = card.name if card.name != "" else "(名称未設定)"
	name_label.add_theme_font_override("font", CARD_FONT)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)
	var stats_label = Label.new()
	stats_label.text = "コスト%d 威力%d 詠唱%d" % [card.cost, card.power, card.cast_time]
	stats_label.add_theme_font_override("font", CARD_FONT)
	stats_label.add_theme_color_override("font_color", Color.WHITE)
	stats_label.add_theme_font_size_override("font_size", 13)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	stats_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(stats_label)

	if card.ability != "":
		var ability_label = Label.new()
		ability_label.text = "%s %d" % [card.ability, card.ability_value]
		ability_label.add_theme_font_override("font", CARD_FONT)
		ability_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		ability_label.add_theme_font_size_override("font_size", 13)
		ability_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ability_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		ability_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(ability_label)

	return btn
func _make_relic_display(relic: RelicData) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(170, 100)

	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)

	if relic.icon:
		var icon = TextureRect.new()
		icon.texture = relic.icon
		icon.custom_minimum_size = Vector2(0, 110)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(icon)

	var name_label = Label.new()
	name_label.text = relic.name if relic.name != "" else "(名称未設定)"
	name_label.add_theme_font_override("font", CARD_FONT)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	return vbox

func _on_ability_slot_pressed(index: int):
	selected_slot_index = -1 if selected_slot_index == index else index
	refresh_all()

func _on_pool_card_pressed(card: CardData):
	if selected_slot_index == -1:
		print("先に入れ替えたいスロットを選んでください")
		return

	var is_neutral_slot = selected_slot_index >= NEUTRAL_SLOT_START and selected_slot_index < NEUTRAL_SLOT_START + NEUTRAL_SLOT_COUNT

	if is_neutral_slot and not card.is_instant:
		print("この枠には特殊(ニュートラル)カードしか置けません")
		return
	if not is_neutral_slot and card.is_instant:
		print("特殊(ニュートラル)カードは専用枠にしか置けません")
		return

	var old_card = GameData.player_deck[selected_slot_index]

	GameData.player_deck[selected_slot_index] = card
	GameData.owned_cards.erase(card)
	if old_card != null:
		GameData.owned_cards.append(old_card)
	selected_slot_index = -1
	refresh_all()

func _on_confirm_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
