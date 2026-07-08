extends HSlider

func _on_se_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(value / 100.0)
	)

	var config = ConfigFile.new()
	config.set_value("audio", "se_volume", value)
	config.save("user://settings.cfg")
