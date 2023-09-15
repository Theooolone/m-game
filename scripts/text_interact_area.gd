extends InteractArea


@export_multiline var textlist: Array[String] = ["Example Message 1", "Blep! Debug Text"]

func _ready():
	Global.textbox_hide.connect(func():
		interactable = true
	)

func _on_interact():
	if Global.textbox_visible or Global.textbox_on_cooldown:
		return
	interactable = false
	for text in textlist:
		Global.textlist.emit(text)
