extends Control


func transfer_score_if_needed(old_save_id, new_save_id):
	old_save_id = "difficulty_" + old_save_id
	new_save_id = "difficulty_" + new_save_id
	
	var old_score_exists = Global.config_value_exists("cat_sim_highscores", old_save_id)
	var new_score = Global.get_config_value("cat_sim_highscores", new_save_id, 0)
	
	if old_score_exists and new_score == 0:
		var old_score = Global.get_config_value("cat_sim_highscores", old_save_id, 0)
		Global.set_config_value("cat_sim_highscores", new_save_id, old_score)


func _ready():
	# transer scores from v1.1.0
	transfer_score_if_needed("0.6", "easy") # Easy
	transfer_score_if_needed("1", "normal") # Normal
	transfer_score_if_needed("2", "200_1") # Hard
	transfer_score_if_needed("5", "500_1") # Pain
	
	# Easy and Normal difficulty buttons
	var easy_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_easy", 0)
	%EasyButton/Highscore.text = str(10*easy_highscore)
	var normal_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_normal", 0)
	%NormalButton/Highscore.text = str(10*normal_highscore)
	
	# Hard difficulty button
	var hard_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_hard", 0)
	
	if normal_highscore >= 350:
		%HardButton/Highscore.text = str(10*hard_highscore)
	else:
		%HardButton.disabled = true
		%HardButton/Difficulty.text = "Locked"
		%HardButton/Highscore.hide()
		%HardButton/Difficulty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		%HardButton.tooltip_text = "3500 points in Normal to unlock"
	
	# Pain difficulty button
	var pain_highscore = Global.get_config_value("cat_sim_highscores", "difficulty_pain", 0)
	
	if hard_highscore >= 350:
		%PainButton/Highscore.text = str(10*pain_highscore)
	else:
		%PainButton.disabled = true
		%PainButton.modulate = Color.WHITE
		%PainButton.self_modulate = Color.WHITE
		%PainButton/Difficulty.text = "Locked"
		%PainButton/Highscore.hide()
		%PainButton/Difficulty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if normal_highscore >= 350:
			%PainButton.tooltip_text = "3500 points in Hard to unlock"
	
	
	if min(easy_highscore,normal_highscore,hard_highscore,pain_highscore) < 450:
		%CustomButton.modulate = Color.WHITE
		%CustomButton.disabled = true
		%CustomButton/Difficulty.text = "Locked"
		%CustomButton.tooltip_text = "4500 points in every difficulty to unlock"
	

func enter_minigame(music, gameinfo):
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/"+music, gameinfo)


func _on_easy_button_pressed():
	enter_minigame("beans_of_anxiety_easy.wav", ["easy", 0.6, 1, false])


func _on_normal_button_pressed():
	enter_minigame("beans_of_anxiety.wav", ["normal", 1, 1, false])


func _on_hard_button_pressed():
	enter_minigame("beans_of_anxiety.wav", ["hard", 2, 2, false])


func _on_pain_button_pressed():
	enter_minigame("beans_of_anxiety_pain.wav", ["pain", 3, 3, true])


func _on_custom_button_pressed():
	Global.change_scene("res://scenes/catsim/custom_difficulty.tscn")


func _on_back_button_pressed():
	Global.return_to_room()
