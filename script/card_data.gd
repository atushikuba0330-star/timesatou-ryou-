class_name CardData
extends Resource

@export var name: String
@export var element: String
@export var cost: int
@export var power: int
@export var cast_time: int
@export var ability: String
@export var ability_value: int

# 追加
@export var preview_font_size: int = 24
# フレーバーテキスト
@export_multiline var flavor_text: String = ""

@export var is_ultimate: bool = false
@export var is_instant: bool = false
@export var projectile_icon: PackedScene
@export var magic_circles: Array[Texture2D]
@export var magic_positions: Array[Vector2]
@export var icon: Texture2D
@export var card_se: AudioStream
