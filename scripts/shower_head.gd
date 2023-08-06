extends Sprite2D
# https://youtu.be/iSpWZzL2i1o

@onready var start_pos = global_position
var selected = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true


func _process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 8*delta)
	else:
		global_position = lerp(global_position, start_pos, 8*delta)
	if Input.is_action_just_released("click"):
		selected = false



