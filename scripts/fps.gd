extends CanvasLayer


func _ready():
	if OS.is_debug_build():
		show()


func _process(delta):
	if Input.is_action_just_pressed("debug_menu"):
		visible = not visible
	if visible:
		$Label.text = "FPS: "+str(0.1*round(10/delta))
