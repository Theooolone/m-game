extends Node2D


var cats = {
#	"Socks": {
#		"node": null, # the node which represents the cat.
#
#		"random_goal": Vector2.ZERO, # desired position cat will move towards when idle or running
#		"idle_walk_timer": null, # cat randomly changes random_goal on timeout
#
#		"current_state": State.IDLE,
#		"being_showered": false, # true if under the shower head
#		"speed": 1,
#
#		"stats": {}, # Contains per-cat values for each stat
#		"random_refill_timer": null, # cat tries to refill lowest useable stat on timeout
#		"stat_goal": null, # the string key in stats dict of the stat the cat is going towards/using
#		"use_duration_timer": null, # time it takes to use object
#		"sleeping": false, # true if in bed
#
#		"shower_cooldown_timer": null, # Time it takes to stop running after stopped being showered
#		"meow_timer": null, # Meows on timeout with some exceptions
#	}
}


var stats = {
#	"hunger": {
#		"object_node": null, # Node that cat will walk towards (add child named Target to offset)
#
#		# The cat will ignore any stats in it's AI calculation
#		# that don't have an object or have useable set to false
#
#		"start_use_func": null, # function called when cat begins using object
#		"end_use_func": null, # function called when cat finishes using object
#		"abort_func": null, # function called when cat is prematurely interupped while using object
#		"click_func": null, # function called when object clicked
#
#		"use_time": 1.5, # time it takes to use object
#		"useable": true, # if cats can use the object
#
#		"cats_using": [] # the string keys in cats dict of the cats that are currently using the object
#	}
}


func add_new_cat_timer(cat, timername, one_shot: bool = false, autostart: bool = false, wait_time: float = 1):
	cats[cat][timername] = Timer.new()
	cats[cat]["node"].add_child(cats[cat][timername])
	cats[cat][timername].wait_time = wait_time
	cats[cat][timername].one_shot = one_shot
	if autostart:
		cats[cat][timername].start()


func new_cat(
	catname: String,
	node: Node
):
	
	cats[catname] = {}
	cats[catname]["node"] = node
	cats[catname]["stats"] = {}
	
	cats[catname]["node"].position.x = randi_range(min_idle_range.x, max_idle_range.x)
	cats[catname]["node"].position.y = randi_range(min_idle_range.y, max_idle_range.y)
	cats[catname]["random_goal"] = cats[catname]["node"].position
	
	cats[catname]["current_state"] = State.IDLE
	
	cats[catname]["stat_goal"] = null
	cats[catname]["being_showered"] = false
	cats[catname]["speed"] = cat_speed_base
	cats[catname]["sleeping"] = false
	
	
	# Cursed lambda use
	# I was stuck on these signal connections for so long
	add_new_cat_timer(catname, "idle_walk_timer", true, true)
	cats[catname]["idle_walk_timer"].timeout.connect(func():_on_cat_idle_walk_timeout(catname))
	
	add_new_cat_timer(catname, "random_refill_timer", true, true, 8)
	
	add_new_cat_timer(catname, "use_duration_timer", true)
	
	cats[catname]["use_duration_timer"].timeout.connect(func(): _on_use_duration_timer_timeout(catname))
	
	add_new_cat_timer(catname, "shower_cooldown_timer", true, false, 3.5)
	cats[catname]["shower_cooldown_timer"].timeout.connect(func(): _on_shower_cooldown_timeout(catname))
	
	add_new_cat_timer(catname, "meow_timer", true, true)
	cats[catname]["meow_timer"].timeout.connect(func(): _on_meow_timer_timeout(catname))
	
	cats[catname]["node"].get_node("Button").button_down.connect(func(): pet(catname))
	
	var shower_detection_node: Area2D = cats[catname]["node"].get_node("ShowerDetection")
	shower_detection_node.area_entered.connect(func(area2D): _on_shower_detection_area_entered(catname,area2D))
	shower_detection_node.area_exited.connect(func(area2D): _on_shower_detection_area_exited(catname,area2D))
	
	


var score = 0

func new_stat(
		statname: String, # Identification
		bar: TextureProgressBar = null, # UI Bar
		object_node = null, # Object cat goes to (if applicable)
		start_use_func = null, # When cat starts using object
		end_use_func = null, # When cat stops using object
		abort_func = null, # When cat prematurely kicked out of using object
		click_func = null, # When object clicked
		start_value: int = 64,
		use_time: float = 1.5, # Time it takes for cat to use object
		useable: bool = true, # If cat can use object
):
	stats[statname] = {}
	stats[statname]["object_node"] = object_node
	stats[statname]["use_time"] = use_time
	stats[statname]["use_time"] = use_time
	stats[statname]["useable"] = useable
	stats[statname]["start_use_func"] = start_use_func
	stats[statname]["end_use_func"] = end_use_func
	stats[statname]["abort_func"] = abort_func
	
	
	if object_node and click_func:
		object_node.get_node("Button").button_down.connect(click_func)
	
	for cat in cats:
		cats[cat]["stats"][statname] = {}
		cats[cat]["stats"][statname]["value"] = start_value
		cats[cat]["stats"][statname]["bar"] = bar
		update_bar(cat, statname)


# Three functions for reading and writing a stat's value

func set_useable(stat, value: bool) -> void:
	stats[stat]["useable"] = value


func get_useable(stat) -> bool:
	return stats[stat]["useable"]


func get_value(cat, stat) -> int:
	return cats[cat]["stats"][stat]["value"]


func get_obj_node(stat) -> Node2D:
	return stats[stat]["object_node"]

@onready var score_text_node = $Score
@onready var highscore_text_node = $Highscore

func change_score(value):
	var highscore = Global.get_config_value("cat_sim_highscores", "difficulty_"+str(difficulty), 0)
	score += value
	score_text_node.text = str(10*score)
	if score > highscore:
		# Highscore saving temp disabled
		#Global.set_config_value("cat_sim_highscores", "difficulty_"+str(difficulty), score)
		highscore_text_node.text = str(10*score)


func set_value(cat, stat, value, add_score = true) -> void:
	if add_score:
		change_score(max(0, clamp(value, 0, 64)-get_value(cat, stat)))
	cats[cat]["stats"][stat]["value"] = clamp(value, 0, 64)
	update_bar(cat, stat)


func change_value(cat, stat, value, add_score = true) -> void:
	set_value(cat, stat, get_value(cat, stat)+value, add_score)


func update_bar(cat, stat):
	cats[cat]["stats"][stat]["bar"].value = get_value(cat, stat)


func get_stat_bar_node(stat) -> Node:
	return stats[stat]["object_node"]


func filter_useable_stats():
	var filtered_stats = stats.duplicate()
	for stat in stats.keys():
		if not (stats[stat]["object_node"] and stats[stat]["useable"]):
			filtered_stats.erase(stat)
	return filtered_stats


func get_lowest_valued_stat(cat, filtered_stats = stats):
	var smallest_value = 65
	var smallest_stat = null
	for stat in filtered_stats:
		var value = get_value(cat, stat)
		if value < smallest_value:
			smallest_stat = stat
			smallest_value = value
	return smallest_stat


func get_lowest_valued_useable_stat(cat):
	return get_lowest_valued_stat(cat, filter_useable_stats())


# Cat AI

func get_cat_node(cat) -> Node:
	return cats[cat]["node"]


func get_stat_goal(cat):
	return cats[cat]["stat_goal"]


func get_random_refill_timer(cat) -> Timer:
	return cats[cat]["random_refill_timer"]


func get_idle_walk_timer(cat) -> Timer:
	return cats[cat]["idle_walk_timer"]


func get_shower_cooldown_timer(cat) -> Timer:
	return cats[cat]["shower_cooldown_timer"]


func get_use_duration_timer(cat) -> Timer:
	return cats[cat]["use_duration_timer"]


func get_meow_timer(cat) -> Timer:
	return cats[cat]["meow_timer"]


func get_random_goal(cat):
	return cats[cat]["random_goal"]


func set_random_goal(cat, value):
	cats[cat]["random_goal"] = value


func is_being_showered(cat) -> bool:
	return cats[cat]["being_showered"]


func set_being_showered(cat, value):
	cats[cat]["being_showered"] = value


func is_sleeping(cat) -> bool:
	return cats[cat]["sleeping"]


func set_sleeping(cat, value):
	cats[cat]["sleeping"] = value


func set_speed(cat, value):
	cats[cat]["speed"] = value


enum State {
	IDLE, ## Will walk around doing nothing
	RUNNING, ## Running away from shower head
	WALKING, ## Walking to an object
	USING, ## Using an object
}


func get_current_state(cat) -> State:
	return cats[cat]["current_state"]


func set_current_state(cat, new_state: State, force = false):
	# Only change state if cat isn't running or force is true
	if not (get_current_state(cat) != State.RUNNING or force):
		return
	
	cats[cat]["current_state"] = new_state
	if new_state == State.RUNNING:
		get_cat_node(cat).speed_scale = 2.5
		set_speed(cat, 2.5*cat_speed_base)
	else:
		get_cat_node(cat).speed_scale = 1
		set_speed(cat, cat_speed_base)
		
	if new_state == State.WALKING:
		get_cat_node(cat).play("default")


func abort_object_use(cat, reset_random_refill: bool = true):
	var stat_goal = get_stat_goal(cat)
	if not stat_goal:
		return
	if stats[stat_goal]["abort_func"]:
		stats[stat_goal]["abort_func"].call(cat)
	
	set_current_state(cat, State.IDLE)
	get_use_duration_timer(cat).stop()
	stat_goal = null
	if reset_random_refill:
		get_random_refill_timer(cat).start()


var cat_speed_base = 2.25


func refill_stat(cat, stat):
	if not (stats[stat]["object_node"] and stats[stat]["useable"]):
		return
	cats[cat]["stat_goal"] = stat
	set_current_state(cat, State.WALKING)


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


@onready var min_idle_range = $MinIdleRange.position
@onready var max_idle_range = $MaxIdleRange.position



func move_towards(cat, pos, delta):
	var cat_node = get_cat_node(cat)
	if cat_node.position != pos:
		if (pos - cat_node.position).x > 0:
			cat_node.scale = Vector2(-1,1)
		else:
			cat_node.scale = Vector2(1,1)
	cat_node.position = cat_node.position.move_toward(pos, cats[cat]["speed"]*16*delta)
	return cat_node.position == pos


func idle_process(cat, delta):
	if move_towards(cat, get_random_goal(cat), delta):
		get_cat_node(cat).stop()


func move_random_goal(cat):
	var random_goal = get_random_goal(cat)
	random_goal.x = randi_range(min_idle_range.x, max_idle_range.x)
	random_goal.y = randi_range(min_idle_range.y, max_idle_range.y)
	set_random_goal(cat, random_goal)
	get_idle_walk_timer(cat).start(randf_range(4,8))
	get_cat_node(cat).play("default")


func _on_cat_idle_walk_timeout(cat):
	if get_current_state(cat) == State.RUNNING: return
	move_random_goal(cat)


func running_process(cat, delta):
	if move_towards(cat, get_random_goal(cat), delta):
		move_random_goal(cat)


func _on_shower_detection_area_entered(cat, area2D):
	if area2D.name == "ShowerHeadHitbox":
		shower_tick_timer.start()
		set_being_showered(cat, true)
		#shower_tick_timer.stop()
		abort_object_use(cat, false)
		set_current_state(cat, State.RUNNING)
		change_value(cat, "human_tolerance", -2)


func _on_shower_detection_area_exited(cat, area2D):
	if area2D.name == "ShowerHeadHitbox":
		set_being_showered(cat, false)
		get_shower_cooldown_timer(cat).start()
		shower_tick_timer.stop()


func _on_shower_cooldown_timeout(cat):
	get_random_refill_timer(cat).start()
	set_current_state(cat, State.IDLE, true)


func _on_shower_tick_timeout():
	for cat in cats:
		if is_being_showered(cat):
			change_value(cat, "cleanliness", 1)
			change_value(cat, "human_tolerance", -1)


func walking_process(cat, delta):
	var stat_goal = get_stat_goal(cat)
	
	var object_node: Node2D = get_obj_node(stat_goal)
	var target_node: Node2D = object_node.get_node_or_null("Target")
	var goal_position: Vector2
	
	if target_node:
		goal_position = target_node.global_position
	else:
		goal_position = object_node.global_position
	
	if not get_useable(stat_goal):
		set_current_state(cat, State.IDLE)
		stat_goal = null
	
	# Returns true when at destination
	if move_towards(cat, goal_position, delta):
		get_use_duration_timer(cat).start(stats[stat_goal]["use_time"])
		if stats[stat_goal]["start_use_func"]:
			stats[stat_goal]["start_use_func"].call(cat)
		get_cat_node(cat).stop()
		set_current_state(cat, State.USING)


func _on_use_duration_timer_timeout(cat):
	var stat_goal = get_stat_goal(cat)
	
	if stats[stat_goal]["end_use_func"]:
		stats[stat_goal]["end_use_func"].call(cat)
	stat_goal = null
	get_random_refill_timer(cat).start()
	set_current_state(cat, State.IDLE)
	get_cat_node(cat).play("default")


var msec_start
var msec_elapsed
var seconds_elapsed

@export var difficulty: float = 1

@onready var stat_tick_timer: Timer = $StatTickTimer


func cat_process(cat, delta):
	var current_state = get_current_state(cat)
	
	match current_state:
		State.IDLE:
			idle_process(cat, delta)
		State.RUNNING:
			running_process(cat, delta)
		State.WALKING:
			walking_process(cat, delta)
	#	State.USING:
	#		using_process(cat, delta)
	
	if current_state == State.IDLE:
		# Cat will look for valid objects to use more often the lower the lowest stat is
		# https://www.desmos.com/calculator/ksgmxn8uwa
		var lowest_useable_stat = get_lowest_valued_useable_stat(cat)
		if (
				lowest_useable_stat
				and get_value(cat, lowest_useable_stat) > 32
				and 8-get_random_refill_timer(cat).time_left >= 0.1875*get_value(cat, lowest_useable_stat)-4
				
			):
			get_random_refill_timer(cat).stop()
			refill_stat(cat, lowest_useable_stat)


func _process(delta):
	msec_elapsed = (Time.get_ticks_msec()-msec_start)*Engine.time_scale
	seconds_elapsed = msec_elapsed/1000.0
	
	# Magic formula
	stat_tick_timer.wait_time = 600/(seconds_elapsed+150)
	stat_tick_timer.wait_time /= stats.size()
	
	stat_tick_timer.wait_time /= difficulty
	
	for cat in cats:
		cat_process(cat, delta)
	
	if Input.is_action_just_pressed("debug_menu"):
		$Debug.visible = not $Debug.visible
	
	#debug(get_lowest_valued_useable_stat())


# Misc

@onready var bed_node = $Bed

@onready var shower_tick_timer = $ShowerTickTimer

func _ready():
	#Engine.time_scale = 10
	
	if Global.scene_data:
		difficulty = Global.scene_data
	
	if difficulty == 5:
		RenderingServer.set_default_clear_color(Color("332626"))
		$RedTint.show()
	
	shower_tick_timer.wait_time = 0.1
	
	msec_start = Time.get_ticks_msec()
	
	new_cat("Socks", $Cat)
	new_cat("Penny", $Cat2)
	
	new_stat("hunger", $Hunger, $Food, start_eat, eat, null, fill_food_bowl, 64, 3)
	new_stat("thirst", $Thirst, $Water, null, drink, null, fill_water_bowl)
	new_stat("fun", $Fun)
	new_stat("human_tolerance", $"Human Tolerance")
	new_stat("awakeness", $Awakeness, bed_node, sleep_start, sleep_end, sleep_abort, on_bed_clicked, 64, 10)
	new_stat("cleanliness", $Cleanliness)
	
	highscore_text_node.text = str(10*Global.get_config_value("cat_sim_highscores", "difficulty_"+str(difficulty), 0))
	
	if OS.is_debug_build():
		$Debug.show()


func start_eat(cat):
	change_value(cat, "human_tolerance", 20)


var empty_bowl_tex = preload("res://assets/textures/catsim/empty_bowl.png")
var food_bowl_tex = preload("res://assets/textures/catsim/food_bowl.png")
var water_bowl_tex = preload("res://assets/textures/catsim/water_bowl.png")

func eat(cat):
	get_stat_bar_node("hunger").texture = empty_bowl_tex
	change_value(cat, "hunger", 12)
	change_value(cat, "thirst", -4)
	set_useable("hunger", false)


func drink(cat):
	get_stat_bar_node("thirst").texture = empty_bowl_tex
	change_value(cat, "thirst", 8)
	set_useable("thirst", false)


func sleep_start(cat):
	set_sleeping(cat, true)
	get_cat_node(cat).hide()
	bed_node.play("sleeping")
	set_useable("awakeness", false)


func sleep_end(cat):
	set_value(cat, "awakeness", 64)
	meow_node.play()
	set_sleeping(cat, false)
	get_cat_node(cat).show()
	bed_node.play("empty")
	set_useable("awakeness", true)


func sleep_abort(cat):
	meow_node.play()
	set_sleeping(cat, false)
	change_value(cat, "human_tolerance", -12)
	get_cat_node(cat).show()
	bed_node.play("empty")


func on_bed_clicked():
	for cat in cats:
		if is_sleeping(cat):
			meow_node.play()
			change_value(cat, "human_tolerance", -12)
			abort_object_use(cat)
			return


func fill_food_bowl():
	get_stat_bar_node("hunger").texture = food_bowl_tex
	set_useable("hunger", true)


func fill_water_bowl():
	get_stat_bar_node("thirst").texture = water_bowl_tex
	set_useable("thirst", true)


@onready var meow_node = $Meow

# When cat clicked
# As chaotic as possible while still being fair if you know what you're doing
func pet(cat):
	meow_node.play()
	
	var human_tolerance_value = get_value(cat, "human_tolerance")
	
	if human_tolerance_value >= 48:
		change_value(cat, "fun", 8)
	elif human_tolerance_value < 32:
		change_value(cat, "fun", -8)
	
	var rand = randi_range(1,8)
	if rand >= 7: rand *= 3 
	change_value(cat, "human_tolerance", -rand)


# Random meowing
func _on_meow_timer_timeout(cat):
	if not is_sleeping(cat):
		meow_node.play()
	get_meow_timer(cat).start(randf_range(10,25))


func _on_leave_button_pressed():
	Global.return_to_room()


var sleeping_skip_tick: bool = false

func _on_stat_tick_timer_timeout():
	
	sleeping_skip_tick = not sleeping_skip_tick
	
	for cat in cats:
		# Skip every other tick if sleeping
		if sleeping_skip_tick and is_sleeping(cat):
			continue
		
		var stat_changed = stats.keys().pick_random()
		match stat_changed:
			"human_tolerance":
				change_value(cat, stat_changed, 1, false)
			"awakeness":
				if not is_sleeping(cat):
					change_value(cat, stat_changed, -1)
			"cleanliness":
				if not is_being_showered(cat):
					change_value(cat, stat_changed, -1)
			_:
				change_value(cat, stat_changed, -1)
	
		for stat in stats.keys():
			if get_value(cat, stat) <= 0:
				# Fail, with stat being the specific stat that caused the loss.
				_on_leave_button_pressed()
		
		var lowest_useable_stat = get_lowest_valued_useable_stat(cat)
		if (
				get_current_state(cat) == State.IDLE
				and lowest_useable_stat
				and get_value(cat, lowest_useable_stat) <= 32
		):
			refill_stat(cat, lowest_useable_stat)


@onready var camera_move_anim = $CameraMove

func _on_other_menu_button_pressed():
	camera_move_anim.play("CameraMoveAnim")


func _on_back_button_pressed():
	camera_move_anim.play("CameraMoveBack")
