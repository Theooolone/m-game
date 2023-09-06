extends CanvasLayer


func _process(_delta):
	if Input.is_action_just_pressed("pause") and Global.pauseable:
		if visible:
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true
