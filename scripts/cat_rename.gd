extends CanvasLayer

var cat: Node2D = null

func show_menu(input_cat):
	cat = input_cat
	show()
	$CenterContainer/Control/LineEdit.text = ""
	get_tree().paused = true
	Global.pauseable = false


func _on_line_edit_focus_entered():
	Global.line_edit_focused = true


func _on_line_edit_focus_exited():
	Global.line_edit_focused = false


func _on_line_edit_text_submitted(new_text):
	hide()
	get_tree().paused = false
	Global.pauseable = true
	if new_text != "":
		cat.name = new_text
		Global.set_config_value("cat_sim", "cat_name_"+str(cat.id), new_text)
