extends Node2D


# Parent Node
@onready var MAIN: Node2D = get_node("..")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var statbar_set: Node
var highlighted: bool = false

var stats = {}

func new_stat(
		statname: String, # Identification
		bar_name: String, # Name of the bar node inside statbar
		start_use_func = null, # When cat starts using object
		end_use_func = null, # When cat stops using object
		abort_func = null, # When cat prematurely kicked out of using object
		start_value: int = 64
):
	stats[statname] = {}
	stats[statname]["bar_name"] = bar_name
	stats[statname]["start_use_func"] = start_use_func
	stats[statname]["end_use_func"] = end_use_func
	stats[statname]["abort_func"] = abort_func
	stats[statname]["value"] = start_value


func get_value(stat) -> int:
	return stats[stat]["value"]


func set_value(stat, value, add_score = true) -> void:
	if add_score:
		MAIN.change_score(max(0, clamp(value, 0, 64)-stats[stat]["value"]))
	stats[stat]["value"] = clamp(value, 0, 64)
	update_bar(stat)


func change_value(stat, value, add_score = true) -> void:
	set_value(stat, get_value(stat)+value, add_score)

func update_bar(stat):
	if statbar_set:
		statbar_set.get_node(stats[stat]["bar_name"]).value = get_value(stat)
	else:
		MAIN.stats[stat]["bar"].value = get_value(stat)


func filter_useable_stats():
	var filtered_stats = stats.duplicate()
	for stat in stats.keys():
		if not (MAIN.stats[stat]["object_node"] and MAIN.stats[stat]["useable"]):
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


enum State {
	IDLE, ## Will walk around doing nothing
	RUNNING, ## Running away from shower head
	WALKING, ## Walking to an object
	USING, ## Using an object
}

var current_state: State = State.IDLE

func change_state(new_state: State, force = false):
	# Only change state if cat isn't running or force is true
	if not (current_state != State.RUNNING or force):
		return
	
	current_state = new_state
	if new_state == State.RUNNING:
		sprite.speed_scale = 2.5
		cat_speed = 2.5*cat_speed_base
	else:
		sprite.speed_scale = 1
		cat_speed = cat_speed_base
		
	if new_state == State.WALKING:
		sprite.play("default")

func abort_object(reset_random_refill: bool = true):
	if not stat_goal:
		return
	if not current_state == State.USING:
		return
	if stats[stat_goal]["abort_func"]:
		stats[stat_goal]["abort_func"].call()
	change_state(State.IDLE)
	use_duration_timer_node.stop()
	stat_goal = null
	if reset_random_refill:
		random_refill_timer_node.start()

var sleeping = false

var stat_goal

var cat_speed_base = 2.25
@onready var cat_speed = cat_speed_base

func refill_stat(stat):
	if not (MAIN.stats[stat]["object_node"] and MAIN.stats[stat]["useable"]):
		return
	stat_goal = stat
	change_state(State.WALKING)


@onready var idle_walk_timer = $IdleWalkTimer

@onready var random_goal = position

func move_towards(pos, delta):
	if position != pos:
		if (pos - position).x > 0:
			scale = Vector2(-1,1)
		else:
			scale = Vector2(1,1)
	position = position.move_toward(pos, cat_speed*16*delta)
	return position == pos


func idle_process(delta):
	if move_towards(random_goal, delta):
		sprite.stop()

var min_idle_range: Vector2
var max_idle_range: Vector2

func move_random_goal():
	@warning_ignore("narrowing_conversion")
	random_goal.x = randi_range(min_idle_range.x, max_idle_range.x)
	@warning_ignore("narrowing_conversion")
	random_goal.y = randi_range(min_idle_range.y, max_idle_range.y)
	idle_walk_timer.start(randf_range(4,8))
	sprite.play("default")


func random_teleport():
	@warning_ignore("narrowing_conversion")
	random_goal.x = randi_range(min_idle_range.x, max_idle_range.x)
	@warning_ignore("narrowing_conversion")
	random_goal.y = randi_range(min_idle_range.y, max_idle_range.y)


func _on_cat_idle_walk_timeout():
	
	if current_state == State.RUNNING: return
	move_random_goal()
	idle_walk_timer.start(randf_range(4,8))

@onready var stat_tick_timer = MAIN.get_node("StatTickTimer")

@onready var shower_detection_node = $ShowerDetection
@onready var shower_cooldown_timer = $ShowerCooldownTimer
@onready var shower_tick_timer = MAIN.get_node("ShowerTickTimer")

func running_process(delta):
	if move_towards(random_goal, delta):
		move_random_goal()


var getting_showered = false

func _on_shower_detection_area_entered(area2D):
	if area2D.name == "ShowerHeadHitbox":
		getting_showered = true
		shower_cooldown_timer.stop()
		abort_object(false)
		change_state(State.RUNNING)


func _on_shower_detection_area_exited(area2D):
	if area2D.name == "ShowerHeadHitbox":
		getting_showered = false
		shower_cooldown_timer.start()


func _on_shower_cooldown_timeout():
	random_refill_timer_node.start()
	change_state(State.IDLE, true)


func _on_shower_tick_timeout():
	if getting_showered:
		change_value("cleanliness", 1)
		change_value("human_tolerance", -1)


@onready var use_duration_timer_node = $UseDurationTimer

func walking_process(delta):
	var object_node: Node2D  = MAIN.get_obj_node(stat_goal)
	var target_node: Node2D = object_node.get_node_or_null("Target")
	var goal_position: Vector2
	
	if target_node:
		goal_position = target_node.global_position
	else:
		goal_position = object_node.global_position
	
	# Returns true when at destination
	if move_towards(goal_position, delta):
		if not MAIN.get_useable(stat_goal):
			random_refill_timer_node.start()
			change_state(State.IDLE)
			return
		use_duration_timer_node.start(MAIN.stats[stat_goal]["use_time"])
		if stats[stat_goal]["start_use_func"]:
			stats[stat_goal]["start_use_func"].call()
		sprite.stop()
		change_state(State.USING)


func _on_use_duration_timer_timeout():
	if stats[stat_goal]["end_use_func"]:
		stats[stat_goal]["end_use_func"].call()
		stat_goal = null
	random_refill_timer_node.start()
	change_state(State.IDLE)
	sprite.play("default")


@onready var random_refill_timer_node = $RandomRefillTimer

func _process(delta):
	
	var _sleeping_multiplier = 2 if sleeping else 1
	
	if statbar_set:
		statbar_set.get_node("Title").text = name
	
	match current_state:
		State.IDLE:
			idle_process(delta)
		State.RUNNING:
			running_process(delta)
		State.WALKING:
			walking_process(delta)
	#	State.USING:
	#		using_process(delta)
	
	if get_value(get_lowest_valued_stat()) == 0:
		Global.return_to_room()
	
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


# Misc

func _ready():

	stat_tick_timer.timeout.connect(_on_stat_tick_timer_timeout)
	shower_tick_timer.timeout.connect(_on_shower_tick_timeout)
	
	min_idle_range = MAIN.get_node("MinIdleRange").position
	max_idle_range = MAIN.get_node("MaxIdleRange").position
	
	shower_detection_node.area_entered.connect(_on_shower_detection_area_entered)
	shower_detection_node.area_exited.connect(_on_shower_detection_area_exited)
	
	MAIN.get_node("Bed").get_node("Area2D").mouse_entered.connect(_on_bed_mouse_entered)
	
	new_stat("hunger", "Hunger", start_eat, eat, null)
	new_stat("thirst", "Thirst", null, drink, null,)
	new_stat("fun", "Fun")
	new_stat("human_tolerance", "Human Tolerance")
	new_stat("energy", "Energy", sleep_start, sleep_end, sleep_abort)
	new_stat("cleanliness", "Cleanliness")
	
	move_random_goal()
	position = random_goal
	meow_timer_node.start(randf_range(10,25))


func start_highlight():
	highlighted = true
	modulate = Color(1.2, 1.2, 1.6)
	if sleeping:
		MAIN.get_node("Bed").modulate = Color(1.2, 1.2, 1.6)
	MAIN.change_highlighted_statbar_set(statbar_set)


func end_highlight():
	highlighted = false
	modulate = Color.WHITE
	if sleeping:
		MAIN.get_node("Bed").modulate = Color.WHITE


func start_eat():
	change_value("human_tolerance", 20)


var empty_bowl_tex = preload("res://assets/textures/catsim/empty_bowl.png")

func eat():
	MAIN.get_obj_node("hunger").texture = empty_bowl_tex
	change_value("hunger", 12)
	change_value("thirst", -4)
	MAIN.set_useable("hunger", false)


func drink():
	MAIN.get_obj_node("thirst").texture = empty_bowl_tex
	change_value("thirst", 8)
	MAIN.set_useable("thirst", false)


func sleep_start():
	sleeping = true
	hide()
	MAIN.get_obj_node("energy").play("sleeping")
	MAIN.set_useable("energy", false)
	if highlighted:
		MAIN.get_node("Bed").modulate = Color(1.2, 1.2, 1.6)


func sleep_end():
	set_value("energy", 64)
	meow_node.play()
	sleeping = false
	show()
	MAIN.get_obj_node("energy").play("empty")
	MAIN.set_useable("energy", true)
	MAIN.get_node("Bed").modulate = Color.WHITE


func sleep_abort():
	meow_node.play()
	sleeping = false
	change_value("human_tolerance", -12)
	show()
	MAIN.get_obj_node("energy").play("empty")
	MAIN.set_useable("energy", true)
	MAIN.get_node("Bed").modulate = Color.WHITE


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
	if not sleeping:
		meow_node.play()
	meow_timer_node.start(randf_range(10,25))


func _on_stat_tick_timer_timeout():
	var stat_changed = stats.keys().pick_random()
	match stat_changed:
		"human_tolerance":
			change_value(stat_changed, 1, false)
		"energy":
			if not sleeping:
				change_value(stat_changed, -1)
		"cleanliness":
			if not getting_showered:
				change_value(stat_changed, -1)
		_:
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


func _on_click_detection_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("click"):
		pet()


func _on_shower_detection_mouse_entered():
	MAIN.change_highlighted_statbar_set(statbar_set)


func _on_bed_mouse_entered():
	if not sleeping:
		return
	_on_shower_detection_mouse_entered()
