extends CanvasLayer

var config = ConfigFile.new()

func _ready():
	var err = config.load("user://usersettings.cfg")
	
	if err != OK: return
	
	for key in config.get_section_keys("audio"):
		var value = config.get_value("audio", key)
		$Panel/MarginContainer/HBoxContainer.get_node(key).get_node("VSlider").value = value

func _process(_delta):
	if Input.is_action_just_pressed("audio_settings"):
		if not visible:
			show()
		else:
			hide()

func _on_drag_ended(slider, value, default):
	if value == default:
		config.erase_section_key("audio", slider)
	else:
		config.set_value("audio", slider, value)
	config.save("user://usersettings.cfg")
