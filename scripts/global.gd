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

func _ready():
	config.set_value("misc", "times_opened", times_opened)
	config.save(configpath)


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if Window.MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
