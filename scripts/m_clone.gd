extends CharacterBody2D

@onready var AnimatedSprite = $AnimatedSprite2D
@onready var StepAudio = $StepAudio

@export var speed = 4*16

var movevector = Vector2.ZERO


func vector_to_4way_direction(vector: Vector2) -> Vector2:
	if vector == Vector2.ZERO:
		return Vector2.ZERO
	
	var dir = int(rad_to_deg(vector.angle()))
	
	if -45 <= dir and dir <= 45:
		return Vector2.RIGHT
	if 45 < dir and dir < 135:
		return Vector2.DOWN
	if 135 <= dir or dir <= -135:
		return Vector2.LEFT
	if -135 < dir and dir < -45:
		return Vector2.UP
	return Vector2.ZERO

func _physics_process(_delta):
	movevector = -1 * Input.get_vector("left", "right", "up", "down")
	# velocity is a variable in CharacterBody2D used by functions like move_and_slide()
	velocity = movevector * speed
	move_and_slide()


func  _process(_delta):
	updateanim()


func updateanim():
	var dir = vector_to_4way_direction(movevector)
	AnimatedSprite.speed_scale = movevector.length()
	match dir:
		Vector2.UP:
			AnimatedSprite.play("up")
		Vector2.DOWN:
			AnimatedSprite.play("down")
		Vector2.LEFT:
			AnimatedSprite.play("left")
		Vector2.RIGHT:
			AnimatedSprite.play("right")
		_:
			AnimatedSprite.stop()

var framecount = 0

func _on_animated_sprite_2d_frame_changed():
	framecount -= 1
	if framecount <= 0:
		StepAudio.play()
		framecount = 2
