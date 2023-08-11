extends CanvasLayer



func _ready():
	
	if Global.config.has_section("audio"):
		for key in Global.config.get_section_keys("audio"):
			var value = Global.config.get_value("audio", key)
			var slider_node = $Panel/MarginContainer/HBoxContainer.get_node(key)
			slider_node.get_node("VSlider").value = value
			if value == 69:
				slider_node.get_node("Value").text = "69% :)"
			
	get_node("/root/Main/Music").play()

func _process(_delta):
	if Input.is_action_just_pressed("audio_settings"):
		if not visible:
			show()
		else:
			hide()

func _on_drag_ended(slider, value, default):
	if value == default:
		Global.remove_config_value("audio", slider)
	else:
		Global.set_config_value("audio", slider, value)
	Global.save_config()
