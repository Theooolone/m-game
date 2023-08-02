extends Node2D

@onready var catnode = $Cat

@onready var hunger_bar_node = $Hunger
@onready var thirst_bar_node = $Thirst
@onready var fun_bar_node = $Fun
@onready var human_tolerance_bar_node = $"Human Tolerance"

@onready var cat_node = $Cat

@onready var min_idle_range = $MinIdleRange.position
@onready var max_idle_range = $MaxIdleRange.position
@onready var cat_idle_walk_node = $CatIdleWalk

@onready var meow_node = $Meow
@onready var meow_timer_node = $MeowTimer

@onready var object_use_timer_node = $ObjectUseTimer

var target = null # used for State.WALKING and State.USING
var current_state = State.IDLE

var idle_goal = Vector2.ZERO
@export var speed = 1.5 # Pixels

signal cat_obliteration # emmited when game lost

enum StatType {
	HUNGER,
	THIRST,
	FUN,
	HUMAN_TOLERANCE,
	AWAKENESS,
	CLEANLINESS
}

# Lower is worse
var stats = {
	StatType.HUNGER: 64,
	StatType.THIRST: 64,
	StatType.FUN: 64,
	StatType.HUMAN_TOLERANCE: 64,
	StatType.AWAKENESS: 64,
	StatType.CLEANLINESS: 64,
}

@onready var stat_nodes = {
	StatType.HUNGER: $Food,
	StatType.THIRST: $Water,
	StatType.FUN: null,
	StatType.HUMAN_TOLERANCE: null,
	StatType.AWAKENESS: null,
	StatType.CLEANLINESS: null,
}

var stat_use_times = {
	StatType.HUNGER: 1.5,
	StatType.THIRST: 1,
	StatType.FUN: 1,
	StatType.HUMAN_TOLERANCE: 1,
	StatType.AWAKENESS: 1,
	StatType.CLEANLINESS: 1,
}

enum State {
	IDLE, # Cat will stay still
	IDLE_MOVE, # Cat is moving to a random position
	WALKING, # Cat will move towards object
	USING, # Cat will be at object
}


func _on_cat_idle_walk_timeout():
	idle_goal.x = randi_range(min_idle_range.x, max_idle_range.x)
	idle_goal.y = randi_range(min_idle_range.y, max_idle_range.y)
	change_state(State.IDLE_MOVE)

func change_state(state):
	current_state = state
	$Label.text = State.keys()[state]

func _ready():
	# set random initial seed for random functions
	randomize()
	$StatTick.wait_time = 1.5/stats.size()
	
	$Food/Button.button_down.connect(food)
	$Water/Button.button_down.connect(water)
	$Cat/Button.button_down.connect(pet)
	
	update_ui()


func update_ui():
	hunger_bar_node.value = stats[StatType.HUNGER]
	thirst_bar_node.value = stats[StatType.THIRST]
	fun_bar_node.value = stats[StatType.FUN]
	human_tolerance_bar_node.value = stats[StatType.HUMAN_TOLERANCE]

var lowest_object_stat

func _process(delta):
	match current_state:
		State.WALKING:
			if target:
				catnode.position = catnode.position.move_toward(target.position, speed*16*delta)
				if catnode.position == target.position:
					change_state(State.USING)
					object_use_timer_node.start()
			else: change_state(State.IDLE_MOVE)
		State.IDLE_MOVE:
			catnode.position = catnode.position.move_toward(idle_goal, speed*16*delta)
			if catnode.position == idle_goal:
				change_state(State.IDLE)
				cat_idle_walk_node.start(randf_range(0.5, 4))
	
	if not State.USING:
		lowest_object_stat = get_lowest_object_stat()
		var urgent = stats[lowest_object_stat] <= 32
		if urgent:
			target = stat_nodes[lowest_object_stat]
			change_state(State.WALKING)

func _on_object_use_timer_timeout():
	_on_cat_idle_walk_timeout()
	match lowest_object_stat:
		StatType.HUNGER: food()
		StatType.THIRST: water()

func _on_meow_timer_timeout():
	meow_node.play()
	meow_timer_node.start(randf_range(3,9))

# returns the stat with the lowest number
func get_lowest_stat():
	var lowest_stat
	var lowest_stat_num = 64
	for stat in stats.keys():
		if stats[stat] < lowest_stat_num:
			lowest_stat = stat
			lowest_stat_num = stats[stat]
	return lowest_stat

# returns the stat with the lowest number out of the stats that have an accompying object
func get_lowest_object_stat():
	var lowest_stat
	var lowest_stat_num = 65
	for stat in stats.keys():
		if stats[stat] < lowest_stat_num and stat_nodes[stat]:
			lowest_stat = stat
			lowest_stat_num = stats[stat]
	return lowest_stat

# adds a number to the stat while still respecting the maximum and minimum values
func capadd(stat, add): stats[stat] = max(min(stats[stat]+add, 64),0)

func _on_stat_tick_timeout():
	var stat_changed = stats.keys()[randi_range(0, StatType.size()-1) % 6]
	if stat_changed == StatType.HUMAN_TOLERANCE:
		capadd(stat_changed, 1)
	else:
		capadd(stat_changed, -1)
		
	for i in stats.keys():
		if stats[i] <= 0:
			emit_signal("cat_obliteration",i)
	update_ui()


# WHAT HAPPENS WHEN OBJECT USED

func food():
	capadd(StatType.HUNGER, 16)
	capadd(StatType.THIRST, -8)
	update_ui()

func water():
	capadd(StatType.THIRST, 16)
	update_ui()


# As chaotic as possible while still being fair if you know what you're doing
func pet():
	meow_node.play()
	if stats[StatType.HUMAN_TOLERANCE] >= 32:
		capadd(StatType.FUN, 8)
	elif stats[StatType.HUMAN_TOLERANCE] < 48:
		capadd(StatType.FUN, -8)
	
	var rand = 1 + randi() % 8
	if rand >= 7: rand *= 3 
	capadd(StatType.HUMAN_TOLERANCE, -rand)
	update_ui()
