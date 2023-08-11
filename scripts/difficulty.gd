extends CanvasLayer


func _on_easy_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", null, 0.6)


func _on_normal_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", null, 1)


func _on_hard_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", null, 2)


func _on_pain_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", null, 5)
