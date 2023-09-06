extends Control


func _on_back_button_pressed():
	Global.change_scene("res://scenes/catsim/difficulty.tscn")


var difficulty_save_id = "normal"

var difficulty = 100
var cat_num = 1
var music = 1
var tinted = false

@onready var preset_option = $PresetOption
@onready var music_option = $MusicOption
@onready var tinted_button = $TintedButton
@onready var difficulty_slider = $Difficulty/HSlider
@onready var cat_num_slider = $CatNum/HSlider

@onready var difficulty_label = $DifficultyLabel
@onready var cat_num_label = $CatNumLabel


func _ready():
	update_highscore()


func match_default_difficulty():
	match [difficulty, cat_num, music, tinted]:
		[60, 1, 0, false]:
			return "easy"
		[100, 1, 1, false]:
			return "normal"
		[200, 2, 1, false]:
			return "hard"
		[300, 3, 2, true]:
			return "pain"
		[200, 1, 1, false]:
			return "hard_old"
		[500, 1, 2, true]:
			return "pain_old"
		_:
			return


func soft_match_default_difficulty():
	match [difficulty, cat_num]:
		[60, 1]:
			return "easy"
		[100, 1]:
			return "normal"
		[200, 2]:
			return "hard"
		[300, 3]:
			return "pain"
		_:
			return



func update_highscore():
	var smdd = soft_match_default_difficulty()
	if smdd:
		difficulty_save_id = smdd
	else:
		difficulty_save_id = str(difficulty)+"_"+str(cat_num)
	
	$PlayButton/Highscore.text = str(
		10*Global.get_config_value("cat_sim_highscores", "difficulty_"+difficulty_save_id, 0)
	)


func _on_setting_changed():
	update_highscore()
	match match_default_difficulty():
		"easy":
			preset_option.selected = 0
		"normal":
			preset_option.selected = 1
		"hard":
			preset_option.selected = 2
		"pain":
			preset_option.selected = 3
		"hard_old":
			preset_option.selected = 4
		"pain_old":
			preset_option.selected = 5
		_:
			preset_option.selected = -1


func _on_preset_option_item_selected(index):
	match index:
		0: # Easy
			set_settings(0.6,1,0,false)
		1: # Normal
			set_settings(1,1,1,false)
		2: # Hard
			set_settings(1.5,2,1,false)
		3: # Pain
			set_settings(3,3,2,true)
		4: # Hard (Old ver.)
			set_settings(2,1,1,false)
		5: # Pain (Old ver.)
			set_settings(5,1,2,true)
	preset_option.selected = index


func set_settings(difficulty_val: float, cat_num_val: int, music_val: int, tinted_val: bool):
	difficulty = int(100*difficulty_val)
	difficulty_slider.value = difficulty_val
	difficulty_label.text = str(difficulty_val)
	
	cat_num = cat_num_val
	cat_num_slider.value = cat_num_val
	cat_num_label.text = str(cat_num_val)
	
	tinted = tinted_val
	tinted_button.button_pressed = tinted_val
	music = music_val
	music_option.selected = music_val


func _on_tinted_button_toggled(button_pressed):
	tinted = button_pressed
	_on_setting_changed()


func _on_music_option_item_selected(index):
	music = index
	_on_setting_changed()


func _on_difficulty_value_changed(value):
	if value == 0:
		value = 0.05
		difficulty_slider.value = 0.05
	difficulty = int(100*value)
	difficulty_label.text = str(difficulty/100.0)
	_on_setting_changed()


func _on_cat_num_value_changed(value):
	cat_num = int(value)
	cat_num_label.text = str(cat_num)
	_on_setting_changed()



func _on_play_button_pressed():
	match music:
		0:
			music = "beans_of_anxiety_easy.wav"
		1:
			music = "beans_of_anxiety.wav"
		2:
			music = "beans_of_anxiety_pain.wav"
		3:
			music = "void_resonance.wav"
	
	var gameinfo = [difficulty_save_id, 0.01*difficulty, cat_num, tinted]
	Global.change_scene("res://scenes/catsim/cat_sim.tscn", "res://assets/music/"+music, gameinfo)
