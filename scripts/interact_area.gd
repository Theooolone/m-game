class_name InteractArea
extends Area2D



enum _alert {
	EXCLAMATION_MARK,
	QUESTION_MARK,
	NONE
}


## Node of the alert sprite
var alert_node: Sprite2D
var _alert_node_preload = preload("res://scenes/alert.tscn")

## Either CollisionShape2D or CollisionPolygon2D
@export var hitbox: CollisionShape2D = null
@export var interactable: bool = true
## Used in code
@export var id = 0
## Sound that plays on interaction
@export var interaction_sound: AudioStreamPlayer = null


@export_subgroup("Alert Settings")
## Texture
@export var alert_type: _alert = _alert.NONE
## Position relative to origin
@export var alert_offset: Vector2 = Vector2(0,-20)

var _exclamation_alert_tex = preload("res://assets/textures/alerts/exclamation_mark.png")
var _question_alert_tex = preload("res://assets/textures/alerts/question_mark.png")

## Returns true if M is within the Area2D
var inrange = false

func _init():
	alert_node = _alert_node_preload.instantiate()
	add_child(alert_node)
	alert_node.hide()
	
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)


func _process(_delta):
	if (
		interactable
		and Input.is_action_just_pressed("interact")
		and inrange
	):
		Global.id_interaction.emit(id)
		if interaction_sound: interaction_sound.play()
		_on_interact()


## When player interacts with the interact area
func _on_interact():
	pass


func _on_body_entered(body):
	if body.name != "M":
		return
	inrange = true
	alert_node.position = alert_offset
	if alert_type != _alert.NONE:
		alert_node.show()
	match alert_type:
		_alert.EXCLAMATION_MARK:
			alert_node.texture = _exclamation_alert_tex
		_alert.QUESTION_MARK:
			alert_node.texture = _question_alert_tex


func _on_body_exited(body):
	if body.name != "M":
		return
	inrange = false
	alert_node.hide()
