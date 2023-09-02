extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.times_opened == 1:
		show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("show_controls") and not Global.line_edit_focused:
		if not visible:
			show()
		else:
			hide()
