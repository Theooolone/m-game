extends LineEdit


func _on_focus_entered():
	Global.line_edit_focused = true


func _on_focus_exited():
	Global.line_edit_focused = false
