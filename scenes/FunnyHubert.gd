extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = Time.get_ticks_msec()/1000.0
	self_modulate = Color.from_hsv(time/2,1,1)
	rotate(1.75476*delta)
	skew = sin(2*time)
	scale.x = 3+sin(time*1.654654)
	scale.y = 3+cos(time*1.654654)
