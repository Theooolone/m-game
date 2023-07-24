extends StaticBody2D

var interactedids = []

func _ready():
	Global.id_interaction.connect(_on_id_interaction)

func contains(id):
	return interactedids.find(id) != -1

func _on_id_interaction(id):
	if not contains(id):
		interactedids.append(id)
	if contains(1) and contains(2) and contains(3):
		queue_free()
