extends Node

signal id_interaction

var line_edit_focused = false

var textbox_on_cooldown = false

var pauseable = true

var configpath = "user://usersettings.cfg"

var config: ConfigFile = ConfigFile.new()
var configerr = config.load(configpath)

var main_node
var scene_node

var autosave_timer = Timer.new()

var times_opened

var default_clear_color: Color

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	default_clear_color = RenderingServer.get_default_clear_color()
	
	get_tree().set_auto_accept_quit(false)
	
	times_opened = change_config_value("misc", "times_opened", 1, 0, true)
	
	add_child(autosave_timer)
	
	autosave_timer.timeout.connect(save_config)
	autosave_timer.wait_time = 5*60 # 5 Minutes
	autosave_timer.start()
	
	main_node = get_node_or_null("/root/Main")
	if main_node:
		scene_node = main_node.get_node_or_null("Room")
	
	if OS.is_debug_build(): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	var text_cooldown_timer = Timer.new()
	add_child(text_cooldown_timer)
	autosave_timer.wait_time = 0.2
	autosave_timer.one_shot = true
	
	Dialogic.timeline_ended.connect(func():
		textbox_on_cooldown = true
		autosave_timer.start()
	)
	autosave_timer.timeout.connect(func():
		textbox_on_cooldown = false
	)


func config_value_exists(section: String, key: String):
	return config.has_section_key(section, key)


func get_config_value(section: String, key: String, default = null):
	return config.get_value(section, key, default)


func set_config_value(section: String, key: String, value, important = false):
	config.set_value(section, key, value)
	if important:
		save_config()


func change_config_value(section: String, key: String, value, default = null, important = false):
	var current_value = config.get_value(section, key, default)
	set_config_value(section, key, current_value+value, important)
	return current_value+value


func remove_config_value(section: String, key: String):
	if config.has_section_key(section, key):
		config.erase_section_key(section, key)


func save_config():
	print("Saving...")
	config.save(configpath)
	print("Config Saved...")


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()


func quit():
	save_config()
	get_tree().quit()

var pause_hold_timer = 0

func _process(delta):
	if Input.is_action_pressed("pause"):
		pause_hold_timer += delta
	else:
		pause_hold_timer = 0
	
	if pause_hold_timer > 1.2:
		quit()
	
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if get_window().mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


var m_position = Vector2.ZERO

func return_to_room():
	change_scene("res://scenes/room.tscn", "res://assets/music/void_resonance.wav")

var scene_data = null

func change_scene(scene_path, music_path = null, data = null):
	if not main_node:
		push_error("Main node not found. (Cannot change scene if project not ran from main scene)")
		return
	
	scene_data = data
	
	RenderingServer.set_default_clear_color(default_clear_color)
	
	if scene_node:
		if scene_node.name == "Room":
			m_position = scene_node.get_node("M").position
		scene_node.queue_free()
	var scene_instance = load(scene_path).instantiate()
	main_node.add_child(scene_instance)
	scene_node = scene_instance
	
	if scene_node.name == "Room":
		scene_node.get_node("M").position = m_position
	
	if music_path:
		var music_node = main_node.get_node("Music")
		var music_asset = load(music_path)
		if music_asset != music_node.stream:
			music_node.stop()
			music_node.stream = music_asset
			music_node.play()
