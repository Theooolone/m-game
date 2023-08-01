extends Node2D

@onready var labelnode = $CanvasLayer/Label
@onready var catnode = $Cat

@onready var hunger_bar_node = $Hunger
@onready var thirst_bar_node = $Thirst
@onready var fun_bar_node = $Fun
@onready var human_tolerance_bar_node = $"Human Tolerance"

@onready var cat_node = $Cat

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

enum State {
	IDLE, # Cat will stay still
	IDLE_MOVE, # Cat is moving to a random position
	WALKING, # Cat will move towards object
	USING, # Cat will be at object
}

var target = null # used for State.WALKING and State.USING
var current_state = State.IDLE

const labeltext = "Hunger: %s\nThirst: %s\nFun: %s\nHuman Tolerance: %s\nAwakeness: %s\nCleanliness: %s"

func _ready():
	# set random initial seed for random functions
	randomize()
	$StatTick.wait_time = 1.5/stats.size()
	
	$Food/Button.button_down.connect(food)
	$Water/Button.button_down.connect(water)
	$Cat/Button.button_down.connect(pet)
	
	update_ui()

var idle_goal = Vector2.ZERO
var speed = 1.5 # Pixels

func _process(delta):
	match current_state:
		State.WALKING:
			if target:
				catnode.position = catnode.position.move_toward(target.position, speed*16*delta)
		State.IDLE_MOVE:
			catnode.position = catnode.position.move_toward(idle_goal, speed*16*delta)
			if catnode.position == idle_goal:
				change_state(State.IDLE)
				cat_idle_walk_node.start(randf_range(0.5, 4))


func update_ui():
	labelnode.text =  labeltext % [
		stats[StatType.HUNGER],
		stats[StatType.THIRST],
		stats[StatType.FUN],
		stats[StatType.HUMAN_TOLERANCE],
		stats[StatType.AWAKENESS],
		stats[StatType.CLEANLINESS]
	]
	
	hunger_bar_node.value = stats[StatType.HUNGER]
	thirst_bar_node.value = stats[StatType.THIRST]
	fun_bar_node.value = stats[StatType.FUN]
	human_tolerance_bar_node.value = stats[StatType.HUMAN_TOLERANCE]

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





# WHAT HAPPENS WHEN OBJECT CLICKED

func food():
	capadd(StatType.HUNGER, 8)
	capadd(StatType.THIRST, -4)
	update_ui()

func water():
	capadd(StatType.THIRST, 8)
	update_ui()

# As chaotic as possible while still being fair if you know what you're doing
func pet():
	if stats[StatType.HUMAN_TOLERANCE] >= 32:
		capadd(StatType.FUN, 8)
	elif stats[StatType.HUMAN_TOLERANCE] < 48:
		capadd(StatType.FUN, -8)
	
	
	var rand = 1 + randi() % 8
	if rand >= 7: rand *= 3 
	capadd(StatType.HUMAN_TOLERANCE, -rand)
	update_ui()

@onready var min_idle_range = $MinIdleRange.position
@onready var max_idle_range = $MaxIdleRange.position
@onready var cat_idle_walk_node = $CatIdleWalk

func _on_cat_idle_walk_timeout():
	idle_goal.x = randi_range(min_idle_range.x, max_idle_range.x)
	idle_goal.y = randi_range(min_idle_range.y, max_idle_range.y)
	change_state(State.IDLE_MOVE)

func change_state(state):
	current_state = state
	print("STATE CHANGED TO:" + str(state))
