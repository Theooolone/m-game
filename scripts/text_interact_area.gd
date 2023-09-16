extends InteractArea

var in_dialogue = false

@export_file("*.dtl") var timeline_file: String = "res://assets/dialogic_text/test_timeline.dtl"

func _ready():
	Dialogic.timeline_ended.connect(func():
		if in_dialogue:
			in_dialogue = false
			interactable = true
	)

func _on_interact():
	if Global.textbox_visible or Global.textbox_on_cooldown:
		return
	in_dialogue = true
	interactable = false
	Dialogic.start(timeline_file)
