extends Node2D


# Stat related functions

@onready var cats: Array = get_tree().get_nodes_in_group("cats")
@onready var statbar_sets: Array = get_tree().get_nodes_in_group("statbar_sets")

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
		object_node.get_node("Button").button_down.connect(click_func)


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
	var highscore = Global.get_config_value("cat_sim_highscores", "difficulty_"+str(difficulty), 0)
	score += value
	score_text_node.text = str(10*score)
	if score > highscore:
		Global.set_config_value("cat_sim_highscores", "difficulty_"+str(difficulty), score)
		highscore_text_node.text = str(10*score)


# Cat AI

#func debug(lowest_useable_stat):
#	if not $Debug.visible:
#		return
#
#	var stat_goal_text = stat_goal if stat_goal else "Null"
#	var lowest_useable_stat_text = str(0.1875*get_value(lowest_useable_stat)-4) \
#		if lowest_useable_stat else "Null"
#	var random_refill_text = str(0.1*round(10*(8-random_refill_timer_node.time_left))) \
#		if current_state == State.IDLE else "Null"
#
#	$Debug.text = "State: " + State.keys()[current_state] \
#		+ "\nUsing: " + stat_goal_text \
#		+ "\nRandom Refill: " + random_refill_text \
#		+ "\nRandom Refill Max: " + lowest_useable_stat_text \
#		+ "\nElapsed Time: " + str(seconds_elapsed) \
#		+ "\nStat Tick Time: " + str(0.001*round(1000*($StatTickTimer.wait_time)))


var msec_start
var msec_elapsed
var seconds_elapsed

@export var difficulty: float = 1

func _process(_delta):
	msec_elapsed = (Time.get_ticks_msec()-msec_start)*Engine.time_scale
	seconds_elapsed = msec_elapsed/1000.0
	
	# Magic formula
	$StatTickTimer.wait_time = 600/(seconds_elapsed+150)
	$StatTickTimer.wait_time /= stats.size()
	
	$StatTickTimer.wait_time /= difficulty
	
	
	if Input.is_action_just_pressed("debug_menu"):
		$Debug.visible = not $Debug.visible
	
	#debug(get_lowest_valued_useable_stat())


# Misc

@onready var bed_node = $Bed

func _ready():
	
	var statbar_sets_left = statbar_sets.duplicate()
	for cat in cats:
		cat.statbar_set = statbar_sets_left.pop_front()
	
	if Global.scene_data:
		difficulty = Global.scene_data
	
	if difficulty == 5:
		RenderingServer.set_default_clear_color(Color("332626"))
		$RedTint.show()
	
	
	msec_start = Time.get_ticks_msec()
	
	new_stat("hunger", $Hunger, $Food, fill_food_bowl, 3)
	new_stat("thirst", $Thirst, $Water, fill_water_bowl)
	new_stat("fun", $Fun)
	new_stat("human_tolerance", $"Human Tolerance")
	new_stat("energy", $Energy, bed_node, on_bed_clicked, 10)
	new_stat("cleanliness", $Cleanliness)
	
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
