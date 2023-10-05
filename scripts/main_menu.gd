extends Node2D


func _on_play_button_pressed():
	Global.return_to_room()


func _on_settings_button_pressed():
	pass # Replace with function body.

@onready var background = $TileMap

func _process(delta):
	background.position = background.position.move_toward(Vector2(-1088,1104), 8*delta)
	if background.position == Vector2(-1088,1104):
		background.position = Vector2.ZERO
