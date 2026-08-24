extends Control

@onready var bgm_slider = $VBoxContainer/HSlider
@onready var se_slider = $VBoxContainer2/HSlider
@onready var bgm_toggle = $VBoxContainer/CheckBox
@onready var se_toggle = $VBoxContainer2/CheckBox


func _ready():
	# 設定ファイル読み込み
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	

	if err == OK:
		# 保存された値を読み込む（なければデフォルト100）
		var bgm_value = config.get_value("audio", "bgm_volume", 100)
		var se_value = config.get_value("audio", "se_volume", 100)
		
		bgm_slider.value = bgm_value
		se_slider.value = se_value
		
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(bgm_value / 100.0))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear_to_db(se_value / 100.0))

		bgm_slider.value_changed.connect(_on_bgm_slider_changed)
		se_slider.value_changed.connect(_on_se_slider_changed)



	# トグルの初期値
	bgm_toggle.button_pressed = not AudioServer.is_bus_mute(AudioServer.get_bus_index("Music"))
	se_toggle.button_pressed = not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX"))

	# スライダーとトグルの接続


	bgm_toggle.toggled.connect(_on_bgm_toggled)
	se_toggle.toggled.connect(_on_se_toggled)


func _on_bgm_slider_changed(value):
	var linear = clamp(value / 100.0, 0.05, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(linear))
	

	# 保存
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("audio", "bgm_volume", value)
	config.save("user://settings.cfg")

func _on_se_slider_changed(value):
	var linear = value / 100.0
	var boosted = linear * 3.0  # ← SE を2倍にする（1.0を超えないように clamp）
	boosted = clamp(boosted, 0.0, 1.0)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))

	# 保存
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("audio", "se_volume", value)
	config.save("user://settings.cfg")


func _on_bgm_toggled(pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not pressed)
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("audio", "bgm_toggle", pressed)
	config.save("user://settings.cfg")

func _on_se_toggled(pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), not pressed)
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("audio", "se_toggle", pressed)
	config.save("user://settings.cfg")
