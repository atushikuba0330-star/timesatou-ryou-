extends Node

@onready var bgm_player = $AudioStreamPlayer

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	if err == OK:
		var bgm_value = config.get_value("audio", "bgm_volume", 100)
		var bgm_toggle = config.get_value("audio", "bgm_toggle", true)

		var linear = bgm_value / 100.0

		# 音量反映
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(linear))

		# ミュート反映
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not bgm_toggle)

		# 再生するかどうか
		if bgm_toggle and linear > 0.0:
			$AudioStreamPlayer.play()

@onready var player = $AudioStreamPlayer

var bgm_list = {
	"title": preload("res://BGM (1).mp3"),
	"Home":preload("res://BGM (1).mp3"),
	"battle": preload("res://audiostock_20548.mp3")
}

func play_bgm(bgm_name):
	if not bgm_list.has(bgm_name):
		return

	player.stop()
	player.stream = bgm_list[bgm_name]

	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	if err == OK:
		var bgm_value = config.get_value("audio", "bgm_volume", 100)
		var toggle = config.get_value("audio", "bgm_toggle", true)
		var linear = bgm_value / 100.0

		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(linear))
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not toggle)

		if toggle and linear > 0.0:
			player.play()


func fade_to_bgm(GM_name, duration := 1.5):
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -40, duration)
	tween.tween_callback(Callable(self, "_switch_bgm").bind(GM_name))
	tween.tween_property(player, "volume_db", 0, duration)

func _switch_bgm(B_name):
	play_bgm(B_name)
