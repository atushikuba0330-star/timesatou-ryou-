extends Node

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		var se_value = config.get_value("audio", "se_volume", 100)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(se_value / 100.0))
		var bgm_value = config.get_value("audio", "bgm_volume", 100)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(bgm_value / 100.0))
