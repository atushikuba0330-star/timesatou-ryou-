extends HSlider

func _on_bgm_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(value / 100.0)
	)

	var config = ConfigFile.new()
	config.set_value("audio", "bgm_volume", value)
	config.save("user://settings.cfg")
