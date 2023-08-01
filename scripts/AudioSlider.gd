extends VBoxContainer

@export var title: String = "ChannelTitle"
@export var audio_bus_name: String = "Master"
@export_range(0,100) var default_value = 100

@onready var title_node = $Title
@onready var value_node = $Value
@onready var slider_node = $VSlider

var bus_id

signal drag_ended

func _ready():
	bus_id = AudioServer.get_bus_index(audio_bus_name)
	if bus_id == -1:
		push_error("Invalid Bus name!")
		return
	title_node.text = title
	if default_value == 100:
		return
	slider_node.value = default_value
	value_node.text = str(default_value) + "%"
	if slider_node.value == 69: value_node.text += " :)"
	var new_db = max(-60, 20*log(default_value)/log(10)-40)
	AudioServer.set_bus_volume_db(bus_id, new_db)

func _on_v_slider_value_changed(value):
	if not bus_id: return
	var new_db = max(-60, 20*log(value)/log(10)-40)
	AudioServer.set_bus_volume_db(bus_id, new_db)
	value_node.text = str(value) + "%"

func _on_v_slider_drag_ended(value_changed):
	if slider_node.value == 69:
		value_node.text += " :)" # hehe
	if value_changed:
		drag_ended.emit(audio_bus_name, slider_node.value, default_value)

