# https://www.youtube.com/watch?v=QEHOiORnXIk
# https://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=3780

extends CanvasLayer

@export var textspeed = 20.0

enum State {
	READY,
	READING,
	FINISHED
}

@onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label
@onready var cooldown = $Cooldown

@onready var readtext_node = $readtext

var current_state = State.READY
var text_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.textlist.connect(_on_text_interact_area_interaction)
	hide_textbox()


func _process(_delta):
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("interact"):
				readtext_node.stop()
				end_symbol.show()
				label.visible_ratio = 1
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("interact"):
				change_state(State.READY)
				if text_queue.is_empty():
					hide_textbox()
					cooldown.start()
					Global.textbox_on_cooldown = true


func _on_text_interact_area_interaction(text: String):
	if cooldown.time_left == 0:
		queue_text(text)


func queue_text(next_text):
	text_queue.push_back(next_text)


func hide_textbox():
	hide()
	Global.textbox_hide.emit()
	Global.textbox_visible = false


func show_textbox():
	show()
	Global.textbox_show.emit()
	Global.textbox_visible = true


func clear_textbox():
	end_symbol.hide()
	label.text = ""
	label.visible_ratio = 0


func display_text():
	var next_text = text_queue.pop_front()
	change_state(State.READING)
	clear_textbox()
	show_textbox()
	label.text = next_text
	readtext_node.play("readtext",-1, textspeed/label.get_total_character_count())


func _on_readtext_animation_finished(_anim_name):
	change_state(State.FINISHED)
	end_symbol.show()


func change_state(next_state):
	current_state = next_state


func _on_cooldown_timeout():
	Global.textbox_on_cooldown = false
