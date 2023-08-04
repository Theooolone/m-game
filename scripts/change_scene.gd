class_name SceneChangeInteractArea
extends Area2D

enum alert {
	EXCLAMATION_MARK,
	QUESTION_MARK,
	NONE
}

@onready var alert_node = $Alert

@export var alert_type: alert = alert.QUESTION_MARK
@export_file("*.tscn") var scene_path

var exclamation_alert_tex = preload("res://assets/textures/alerts/exclamation_mark.png")
var question_alert_tex = preload("res://assets/textures/alerts/question_mark.png")

var inrange = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if inrange and Input.is_action_just_pressed("interact"):
		Global.change_scene(scene_path)
		#var scene_instance = load(scene_path).instantiate()
		#get_node("/root").add_child(scene_instance)
		#get_parent().queue_free()



func _on_body_entered(body):
	if body.name != "M":
		return
	inrange = true
	if alert_type != alert.NONE:
		alert_node.show()
	match alert_type:
		alert.EXCLAMATION_MARK:
			alert_node.texture = exclamation_alert_tex
		alert.QUESTION_MARK:
			alert_node.texture = question_alert_tex


func _on_body_exited(body):
	if body.name != "M":
		return
	inrange = false
	alert_node.hide()
