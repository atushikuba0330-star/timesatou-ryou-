extends Panel

func _ready():
	visible = false

func show_preview(card):
	visible = true
	$Labelname.text = card.data.name
	$Labelcost.text = str(card.data.cost)
	$Labelpower.text = str(card.data.power)
	$Labelcast.text = str(card.data.cast_time)
	$Labelability.text = str(card.data.ability) + str(card.data.ability_value)
	if card.data.icon:
		$PreviewIcon.texture = card.data.icon
	
	var current_power = card.get_current_power()
	var parent = card.get_parent()
	if parent and parent.has_method("can_place") and current_power > 0:
		$Labelcurrentpower.text = "現在パワー: " + str(current_power)
		$Labelcurrentpower.visible = true
	else:
		$Labelcurrentpower.visible = false

func hide_preview():
	visible = false
