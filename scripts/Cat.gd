extends Node2D


# Stat related functions

var stats = {}


func new_stat(
		statname: String, # Identification
		bar: TextureProgressBar = null, # UI Bar
		object_node = null, # Object cat goes to (if applicable)
		start_use_func = null, # When cat starts using object
		end_use_func = null, # When cat stops using object
		click_func = null, # When object clicked
		start_value: int = 64,
		use_time: float = 1.5, # Time it takes for cat to use object
		useable: bool = true, # If cat can use object
):
	stats[statname] = {}
	stats[statname]["object_node"] = object_node
	stats[statname]["bar"] = bar
	stats[statname]["value"] = start_value
	stats[statname]["use_time"] = use_time
	stats[statname]["useable"] = useable
	stats[statname]["start_use_func"] = start_use_func
	stats[statname]["end_use_func"] = end_use_func
	if object_node and click_func:
		object_node.get_node("Button").button_down.connect(click_func)
	update_bar(statname)


# Three functions for reading and writing a stat's value

func set_useable(stat, value: bool) -> void:
	stats[stat]["useable"] = value

func get_value(stat) -> int:
	return stats[stat]["value"]


func set_value(stat, value) -> void:
	stats[stat]["value"] = clamp(value, 0, 64)
	update_bar(stat)


func change_value(stat, value) -> void:
	set_value(stat, get_value(stat)+value)


func update_bar(stat):
	stats[stat]["bar"].value = get_value(stat)

func nodeof(stat) -> Node:
	return stats[stat]["object_node"]


func filter_useable_stats():
	var filtered_stats = stats.duplicate()
	for stat in stats.keys():
		if not (stats[stat]["object_node"] and stats[stat]["useable"]):
			filtered_stats.erase(stat)
	return filtered_stats


func get_lowest_valued_stat(filtered_stats = stats):
	var smallest_value = 65
	var smallest_stat = null
	for stat in filtered_stats:
		var value = get_value(stat)
		if value < smallest_value:
			smallest_stat = stat
			smallest_value = value
	return smallest_stat


func get_lowest_valued_useable_stat():
	return get_lowest_valued_stat(filter_useable_stats())


# Cat AI

@onready var cat_node = $Cat

enum State {
	IDLE, ## Will walk around doing nothing
	WALKING, ## Walking to an object
	USING, ## Using an object
}

var current_state: State = State.IDLE

func change_state(new_state: State):
	current_state = new_state


var stat_goal

@export var cat_speed = 1.5

func refill_stat(stat):
	if not (stats[stat]["object_node"] and stats[stat]["useable"]):
		return
	stat_goal = stat
	change_state(State.WALKING)


func debug(lowest_useable_stat):
	var stat_goal_text = stat_goal if stat_goal else "Null"
	var lowest_useable_stat_text = str(0.1875*get_value(lowest_useable_stat)-4) \
		if lowest_useable_stat else "Null"
	
	$Debug.text = State.keys()[current_state] \
		+ "\n" + stat_goal_text \
		+ "\n" + str(0.1*round(10*(8-random_refill_timer_node.time_left))) \
		+ "\n" + lowest_useable_stat_text \
		+ "\n" + str(seconds_elapsed) \
		+ "\n" + str(0.001*round(1000*(160/(seconds_elapsed+70))))
	
	if Input.is_action_just_pressed("debug_menu"):
		if not $Debug.visible:
			$Debug.show()
		else:
			$Debug.hide()

@onready var min_idle_range = $MinIdleRange.position
@onready var max_idle_range = $MaxIdleRange.position
@onready var cat_idle_walk_timer = $CatIdleWalkTimer

@onready var idle_goal = cat_node.position

func move_towards(pos, delta):
	if cat_node.position != pos:
		if (pos - cat_node.position).x > 0:
			cat_node.scale = Vector2(-1,1)
		else:
			cat_node.scale = Vector2(1,1)
	cat_node.position = cat_node.position.move_toward(pos, cat_speed*16*delta)
	return cat_node.position == pos

func idle_process(delta):
	move_towards(idle_goal, delta)


func _on_cat_idle_walk_timeout():
	idle_goal.x = randi_range(min_idle_range.x, max_idle_range.x)
	idle_goal.y = randi_range(min_idle_range.y, max_idle_range.y)
	cat_idle_walk_timer.start(randf_range(4,8))


@onready var use_duration_timer_node = $UseDurationTimer

func walking_process(delta):
	# Returns true when at destination
	if move_towards(stats[stat_goal]["object_node"].position, delta):
		use_duration_timer_node.start(stats[stat_goal]["use_time"])
		if stats[stat_goal]["start_use_func"]:
			stats[stat_goal]["start_use_func"].call()
		change_state(State.USING)


func _on_use_duration_timer_timeout():
	if stats[stat_goal]["end_use_func"]:
		stats[stat_goal]["end_use_func"].call()
		stat_goal = null
	random_refill_timer_node.start()
	change_state(State.IDLE)


@onready var random_refill_timer_node = $RandomRefillTimer

var msec_start
var msec_elapsed
var seconds_elapsed

func _process(delta):
	msec_elapsed = (Time.get_ticks_msec()-msec_start)*Engine.time_scale
	seconds_elapsed = msec_elapsed/1000.0
	
	match current_state:
		State.IDLE:
			idle_process(delta)
		State.WALKING:
			walking_process(delta)
	#	State.USING:
	#		using_process(delta)
	
	$StatTickTimer.wait_time = 160/(seconds_elapsed+70) * 1/stats.size()
	
	if current_state == State.IDLE:
		# Cat will look for valid objects to use more often the lower the lowest stat is
		# https://www.desmos.com/calculator/ksgmxn8uwa
		var lowest_useable_stat = get_lowest_valued_useable_stat()
		if (
				lowest_useable_stat
				and get_value(lowest_useable_stat) > 32
				and 8-random_refill_timer_node.time_left >= 0.1875*get_value(lowest_useable_stat)-4
				
			):
			random_refill_timer_node.stop()
			refill_stat(lowest_useable_stat)
	
	
	debug(get_lowest_valued_useable_stat())


# Misc

func _ready():
	
	msec_start = Time.get_ticks_msec()
	
	new_stat("hunger", $Hunger, $Food, null, eat, fill_food_bowl)
	new_stat("thirst", $Thirst, $Water, null, drink, fill_water_bowl)
	new_stat("fun", $Fun)
	new_stat("human_tolerance", $"Human Tolerance")
	new_stat("awakeness", $Awakeness, $Bed, null, sleep, null, 64, 10)
	new_stat("cleanliness", $Cleanliness)
	
	if OS.is_debug_build():
		$Debug.show()
	
	$Cat/Button.button_down.connect(pet)


var empty_bowl_tex = preload("res://assets/textures/catsim/empty_bowl.png")
var food_bowl_tex = preload("res://assets/textures/catsim/food_bowl.png")
var water_bowl_tex = preload("res://assets/textures/catsim/water_bowl.png")

func eat():
	nodeof("hunger").texture = empty_bowl_tex
	change_value("hunger", 12)
	change_value("thirst", -4)
	set_useable("hunger", false)


func drink():
	nodeof("thirst").texture = empty_bowl_tex
	change_value("thirst", 8)
	set_useable("thirst", false)


func sleep():
	set_value("awakeness", 64)


func fill_food_bowl():
	nodeof("hunger").texture = food_bowl_tex
	set_useable("hunger", true)


func fill_water_bowl():
	nodeof("thirst").texture = water_bowl_tex
	set_useable("thirst", true)


@onready var meow_node = $Meow
@onready var meow_timer_node = $MeowTimer


# When cat clicked
# As chaotic as possible while still being fair if you know what you're doing
func pet():
	meow_node.play()
	if get_value("human_tolerance") >= 48:
		change_value("fun", 8)
	elif get_value("human_tolerance") < 32:
		change_value("fun", -8)
	
	var rand = randi_range(1,8)
	if rand >= 7: rand *= 3 
	change_value("human_tolerance", -rand)


# Random meowing
func _on_meow_timer_timeout():
	meow_node.play()
	meow_timer_node.start(randf_range(10,25))
func _on_leave_button_pressed():
		get_node("/root").add_child(load("res://scenes/room.tscn").instantiate())
		get_node("/root/Room/M").position = Vector2(120, 356)
		queue_free()


func _on_stat_tick_timer_timeout():
	var stat_changed = stats.keys().pick_random()
	if stat_changed == "human_tolerance":
		change_value(stat_changed, 1)
	else:
		change_value(stat_changed, -1)
		
	for stat in stats.keys():
		if get_value(stat) <= 0:
			# Fail, with stat being the specific stat that caused the loss.
			pass
	
	var lowest_useable_stat = get_lowest_valued_useable_stat()
	if (
			current_state == State.IDLE
			and lowest_useable_stat
			and get_value(lowest_useable_stat) <= 32
	):
		refill_stat(lowest_useable_stat)

@onready var camera_move_anim = $CameraMove

func _on_other_menu_button_pressed():
	camera_move_anim.play("CameraMoveAnim")


func _on_back_button_pressed():
	camera_move_anim.play("CameraMoveBack")
