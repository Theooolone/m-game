extends Node2D


# Stat related functions

@onready var cats: Array 

var stats: Dictionary = {}

var score = 0

func new_stat(
		statname: String, # Identification
		bar: TextureProgressBar = null, # UI Bar
		object_node = null, # Object cat goes to (if applicable)
		click_func = null, # When object clicked
		use_time: float = 1.5, # Time it takes for cat to use object
		useable: bool = true, # If cat can use object
):
	stats[statname] = {}
	stats[statname]["object_node"] = object_node
	stats[statname]["bar"] = bar
	stats[statname]["use_time"] = use_time
	stats[statname]["useable"] = useable
	if object_node and click_func:
		object_node.get_node("Area2D").input_event.connect(func(_viewport, _event, _shape_idx):
			if Input.is_action_just_pressed("click"):
				click_func.call()
		)


# Three functions for reading and writing a stat's value

func set_useable(stat, value: bool) -> void:
	stats[stat]["useable"] = value


func get_useable(stat) -> bool:
	return stats[stat]["useable"]


func get_obj_node(stat) -> Node2D:
	return stats[stat]["object_node"]


@onready var score_text_node = $Score
@onready var highscore_text_node = $Highscore

func change_score(value):
	var highscore = Global.get_config_value("cat_sim_highscores", "difficulty_"+difficulty_save_id, 0)
	score += value
	score_text_node.text = str(10*score)
	if score > highscore:
		Global.set_config_value("cat_sim_highscores", "difficulty_"+difficulty_save_id, score)
		highscore_text_node.text = str(10*score)


# Cat AI

func debug(debug_cat):
	var lowest_useable_stat = debug_cat.get_lowest_valued_useable_stat()
	
	if not $Debug.visible:
		return

	var stat_goal_text = debug_cat.stat_goal if debug_cat.stat_goal else "Null"
	var lowest_useable_stat_text = str(0.1875*debug_cat.get_value(lowest_useable_stat)-4) \
		if lowest_useable_stat else "Null"
	var random_refill_text = str(0.1*round(10*(8-debug_cat.random_refill_timer_node.time_left))) \
		if debug_cat.current_state == debug_cat.State.IDLE else "Null"

	$Debug.text = "State: " + debug_cat.State.keys()[debug_cat.current_state] \
		+ "\nUsing: " + stat_goal_text \
		+ "\nRandom Refill: " + random_refill_text \
		+ "\nRandom Refill Max: " + lowest_useable_stat_text \
		+ "\nElapsed Time: " + str(seconds_elapsed) \
		+ "\nStat Tick Time: " + str(0.001*round(1000*($StatTickTimer.wait_time)))


var msec_start
var msec_elapsed
var seconds_elapsed


func _process(_delta):
	
	# Debug
	if Input.is_action_pressed("up") and OS.is_debug_build():
		Engine.time_scale = 5
	else:
		Engine.time_scale = 1
	
	
	msec_elapsed = (Time.get_ticks_msec()-msec_start)*Engine.time_scale
	seconds_elapsed = msec_elapsed/1000.0
	
	# Magic formula
	$StatTickTimer.wait_time = 600/(seconds_elapsed+150)
	$StatTickTimer.wait_time /= stats.size()
	
	$StatTickTimer.wait_time /= difficulty
	
	
	if Input.is_action_just_pressed("debug_menu"):
		$Debug.visible = not $Debug.visible
	
	
	
	if debug_cat: debug(debug_cat)


# Misc

var highlighted_statbar_set: Node

var debug_cat

var difficulty_save_id = "debug"
@export var difficulty: float = 1
@export_range(1,8) var cat_amount = 1
@export var red_tint: bool = false

func _ready():
	#Engine.time_scale = 0.5
	
	if Global.scene_data:
		difficulty_save_id = Global.scene_data[0]
		difficulty = Global.scene_data[1]
		cat_amount = Global.scene_data[2]
		red_tint = Global.scene_data[3]
	
	if red_tint:
		$RedTint.show()
		RenderingServer.set_default_clear_color(Color("332626"))
	
	
	var scroll_bar = %ScrollContainer.get_v_scroll_bar()
	scroll_bar.scale = Vector2.ONE/2
	scroll_bar.custom_minimum_size.y = scroll_bar.size.y*2
	
	if cat_amount > 1:
		$Statbars.hide()
		for i in cat_amount:
			var cat = load("res://scenes/catsim/cat.tscn").instantiate()
			cat.name = "Cat" + str(i+1)
			add_child(cat)
			var statbar_set = load("res://scenes/catsim/statbar_set.tscn").instantiate()
			statbar_set.name = "StatbarSet" + str(i+1)
			%ScrollContainer/VBoxContainer.add_child(statbar_set)
			cat.statbar_set = statbar_set
			if i == 0:
				debug_cat = cat
	else:
		var cat = load("res://scenes/catsim/cat.tscn").instantiate()
		cat.name = "Cat"
		add_child(cat)
		debug_cat = cat
	
	cats = get_tree().get_nodes_in_group("cats")
	
	msec_start = Time.get_ticks_msec()
	
	new_stat("hunger", $Statbars/Hunger, $Food, fill_food_bowl, 3)
	new_stat("thirst", $Statbars/Thirst, $Water, fill_water_bowl)
	new_stat("fun", $Statbars/Fun)
	new_stat("human_tolerance", $Statbars/"Human Tolerance")
	new_stat("energy", $Statbars/Energy, $Bed, on_bed_clicked, 10)
	new_stat("cleanliness", $Statbars/Cleanliness)
	
	highscore_text_node.text = str(10*Global.get_config_value("cat_sim_highscores", "difficulty_"+str(difficulty), 0))
	
	if OS.is_debug_build():
		$Debug.show()

var food_bowl_tex = preload("res://assets/textures/catsim/food_bowl.png")
var water_bowl_tex = preload("res://assets/textures/catsim/water_bowl.png")


func on_bed_clicked():
	for cat in cats:
		if cat.sleeping:
			cat.meow_node.play()
			cat.change_value("human_tolerance", -12)
			cat.abort_object()
			return


func fill_food_bowl():
	get_obj_node("hunger").texture = food_bowl_tex
	set_useable("hunger", true)


func fill_water_bowl():
	get_obj_node("thirst").texture = water_bowl_tex
	set_useable("thirst", true)


func _on_leave_button_pressed():
	Global.return_to_room()


@onready var camera_move_anim = $CameraMove

func _on_other_menu_button_pressed():
	camera_move_anim.play("CameraMoveAnim")


func _on_back_button_pressed():
	camera_move_anim.play("CameraMoveBack")
