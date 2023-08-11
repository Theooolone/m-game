extends Node2D


func _ready():
	var easy_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_0.6", 0)
	$Control/VBoxContainer/EasyButton/Label.text = "Easy (Highscore: " + str(10*easy_highscore) + ")"
	var normal_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_1", 0)
	$Control/VBoxContainer/NormalButton/Label.text = "Normal (Highscore: " + str(10*normal_highscore) + ")"
	var hard_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_2", 0)
	$Control/VBoxContainer/HardButton/Label.text = "Hard (Highscore: " + str(10*hard_highscore) + ")"
	var pain_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_5", 0)
	$Control/VBoxContainer/PainButton/Label.text = "Pain (Highscore: " + str(10*pain_highscore) + ")"


func _on_easy_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", null, 0.6)


func _on_normal_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", null, 1)


func _on_hard_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", null, 2)


func _on_pain_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", null, 5)
