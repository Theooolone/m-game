extends Control


func _ready():
	var easy_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_0.6", 0)
	%EasyButton/Label.text = "Easy (" + str(10*easy_highscore) + ")"
	var normal_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_1", 0)
	%NormalButton/Label.text = "Normal (" + str(10*normal_highscore) + ")"
	var hard_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_2", 0)
	%HardButton/Label.text = "Hard (" + str(10*hard_highscore) + ")"
	var pain_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_5", 0)
	%PainButton/Label.text = "Pain (" + str(10*pain_highscore) + ")"


func _on_easy_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/beans_of_anxiety.wav", 0.6)


func _on_normal_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/beans_of_anxiety.wav", 1)


func _on_hard_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/beans_of_anxiety.wav", 2)


func _on_pain_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/beans_of_anxiety.wav", 5)
