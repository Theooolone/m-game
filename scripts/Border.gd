extends StaticBody2D

var interactedids = []

func _ready():
	if Global.config.get_value("misc", "barrier_passed"):
		queue_free()
	Global.id_interaction.connect(_on_id_interaction)
	

func contains(id):
	return interactedids.find(id) != -1

func _on_id_interaction(id):
	if not contains(id):
		interactedids.append(id)
	if contains(1) and contains(2) and contains(3):
		Global.config.set_value("misc", "barrier_passed", true)
		Global.config.save(Global.configpath)
		queue_free()
