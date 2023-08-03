extends Node2D

var empty_bowl_tex = preload("res://assets/textures/catsim/empty_bowl.png")
var food_bowl_tex = preload("res://assets/textures/catsim/food_bowl.png")
var water_bowl_tex = preload("res://assets/textures/catsim/water_bowl.png")

@onready var cat_node = $Cat

@onready var min_idle_range = $MinIdleRange.position
@onready var max_idle_range = $MaxIdleRange.position
@onready var cat_idle_walk_node = $CatIdleWalk

@onready var object_use_timer_node = $ObjectUseTimer

@onready var meow_node = $Meow
@onready var meow_timer_node = $MeowTimer


# Stat related functions

var stats = {}


func do_nothing(): pass


func new_stat(
		statname: String, # Identification
		bar: TextureProgressBar = null, # UI Bar
		object_node = null, # Object cat goes to (if applicable)
		start_use_func = do_nothing, # When cat starts using object
		end_use_func = do_nothing, # When cat stops using object
		click_func = do_nothing, # When object clicked
		start_value: int = 64,
		use_time: float = 1.0, # Time it takes for cat to use object
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
	if object_node:
		object_node.get_node("Button").button_down.connect(click_func)
	update_bar(statname)


# Three functions for reading and writing a stat's value

func get_value(stat) -> int:
	return stats[stat]["value"]


func set_value(stat, value) -> void:
	stats[stat]["value"] = clamp(value, 0, 64)
	update_bar(stat)


func change_value(stat, value) -> void:
	set_value(stat, get_value(stat)+value)


func update_bar(stat):
	stats[stat]["bar"].value = get_value(stat)


func filter_useable_stats():
	pass


func get_lowest_valued_stat(filtered_stats = stats):
	var smallest_value = 65
	var smallest_stat = null
	for stat in filtered_stats:
		var value = get_value(stat)
		if value < smallest_value:
			smallest_stat = stat
			smallest_value = value
	return smallest_stat


# Cat AI

enum State {
	IDLE, ## Will walk around doing nothing
	WALKING, ## Walking to an object
	USING, ## Using an object
}

var current_state: State = State.IDLE

func change_state(new_state: State):
	current_state = new_state


# Misc

# As chaotic as possible while still being fair if you know what you're doing
func pet():
	meow_node.play()
	if get_value("human_tolerance") >= 32:
		change_value("fun", 8)
	elif get_value("human_tolerance") < 48:
		change_value("fun", -8)
	
	var rand = randi_range(1,8)
	if rand >= 7: rand *= 3 
	change_value("human_tolerance", -rand)


func _ready():
	new_stat("hunger", $Hunger, $Food)
	new_stat("thirst", $Thirst, $Water)
	new_stat("fun", $Fun)
	new_stat("human_tolerance", $"Human Tolerance")
	
	$StatTick.wait_time = 1.5/stats.size()
	
	change_value("thirst", -8)
	print(get_lowest_valued_stat())
	$Cat/Button.button_down.connect(pet)


func _on_meow_timer_timeout():
	meow_node.play()
	meow_timer_node.start(randf_range(3,9))


func _on_leave_button_pressed():
		get_node("/root").add_child(load("res://scenes/room.tscn").instantiate())
		get_node("/root/Room/M").position = Vector2(120, 356)
		queue_free()


func _on_stat_tick_timeout():
	var stat_changed = stats.keys().pick_random()
	if stat_changed == "human_tolerance":
		change_value(stat_changed, 1)
	else:
		change_value(stat_changed, -1)
		
	for stat in stats.keys():
		if get_value(stat) <= 0:
			# Fail, with stat being the specific stat that caused the loss.
			pass


func _on_cat_idle_walk_timeout():
	pass
