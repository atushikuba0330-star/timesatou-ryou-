extends Node

@onready var bgm_player = $AudioStreamPlayer

#func _ready():
	#var config = ConfigFile.new()
	#var err = config.load("user://settings.cfg")
#
	#if err == OK:
		#var bgm_value = config.get_value("audio", "bgm_volume", 100)
		#var linear = bgm_value / 100.0
#
		## 音量反映
		#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(linear))
#
		## 音量が0ならミュート
		#AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), linear == 0)
#
		## 音量が0でない場合のみ再生
		#if linear > 0.0:
			#bgm_player.play()



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
