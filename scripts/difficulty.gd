extends Control


func _ready():
	var easy_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_0.6", 0)
	%EasyButton/Label.text = "Easy (" + str(10*easy_highscore) + ")"
	var normal_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_1", 0)
	%NormalButton/Label.text = "Normal (" + str(10*normal_highscore) + ")"
	
	var hard_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_2", 0)
	if normal_highscore >= 250:
		%HardButton/Label.text = "Hard (" + str(10*hard_highscore) + ")"
	else:
		%HardButton.disabled = true
		%HardButton/Label.text = "Difficulty Locked"
	
	var pain_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_5", 0)
	
	if hard_highscore >= 250:
		%PainButton/Label.text = "Pain (" + str(10*pain_highscore) + ")"
	else:
		%PainButton.disabled = true
		%PainButton/Label.text = "Difficulty Locked"


func _on_easy_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/beans_of_anxiety_easy.wav", 0.6)


func _on_normal_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/beans_of_anxiety.wav", 1)


func _on_hard_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/beans_of_anxiety.wav", 2)


func _on_pain_button_pressed():
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/beans_of_anxiety_pain.wav", 5)


func _on_back_button_pressed():
	Global.return_to_room()
