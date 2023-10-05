extends AnimatedSprite2D

@export var play_on_load = false
@export var delete_on_finished = true

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	frame = 0
	if play_on_load:
		boom()


func boom():
	show()
	play("default")
	$Boom.play()


func _on_animation_finished():
	if delete_on_finished:
		queue_free()
		return
	hide()
