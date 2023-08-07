extends Node2D

@onready var particles = $GPUParticles2D

@onready var start_pos = global_position
var selected = false


func _on_grab_hitbox_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true
		particles.emitting = true


func _process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 8*delta)
	else:
		global_position = lerp(global_position, start_pos, 8*delta)
	if Input.is_action_just_released("click"):
		selected = false
		particles.emitting = false
