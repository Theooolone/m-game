extends Node

signal textlist
signal id_interaction


signal textbox_show
signal textbox_hide

var textbox_visible = false

var textbox_on_cooldown = false

var configpath = "user://usersettings.cfg"

var config = ConfigFile.new()
var configerr = config.load(configpath)

var times_opened = config.get_value("misc","times_opened",0)+1

var main_node
var scene_node

func _ready():
	if get_node("/root/Main"):
		main_node = get_node("/root/Main")
		if main_node.get_node("Room"):
			scene_node = main_node.get_node("Room")
	
	config.set_value("misc", "times_opened", times_opened)
	config.save(configpath)
	
	if OS.is_debug_build(): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if get_window().mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func change_scene(scene_path, music_path = null):
	if not main_node: return
	if scene_node:
		scene_node.queue_free()
	var scene_instance = load(scene_path).instantiate()
	main_node.add_child(scene_instance)
	if music_path:
		var music_asset = load(music_path)
		main_node.get_node("Music").stream = music_asset
