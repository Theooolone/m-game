extends Node

signal textlist
signal id_interaction


signal textbox_show
signal textbox_hide

var textbox_visible = false

var textbox_on_cooldown = false

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if Window.MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
