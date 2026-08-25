extends Label

# ダメージ発生時にインスタンス化して使い捨てにするポップアップ。
# 生成した位置から上に浮かびながらフェードアウトし、自動的に消える。

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func start_float() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 1.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()
