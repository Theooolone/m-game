extends InteractArea

var in_dialogue = false

@export_file("*.dtl") var timeline_file: String = "res://dialogic_text/test_timeline.dtl"

func _ready():
	Dialogic.timeline_ended.connect(func():
		if in_dialogue:
			in_dialogue = false
			interactable = true
	)

func _on_interact():
	if Dialogic.has_active_layout_node() or Global.textbox_on_cooldown:
		return
	in_dialogue = true
	interactable = false
	Dialogic.start(timeline_file)
