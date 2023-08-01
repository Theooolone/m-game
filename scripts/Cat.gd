extends Node2D

@onready var labelnode = $CanvasLayer/Label
@onready var catnode = $Cat

@onready var hunger_bar_node = $Hunger
@onready var thirst_bar_node = $Thirst
@onready var fun_bar_node = $Fun
@onready var human_tolerance_bar_node = $"Human Tolerance"

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

const labeltext = "Hunger: %s\nThirst: %s\nFun: %s\nHuman Tolerance: %s\nAwakeness: %s\nCleanliness: %s"

func _ready():
	# set random initial seed for random functions
	randomize()
	$StatTick.wait_time = 1.5/stats.size()
	
	$Food/Button.button_down.connect(food)
	$Water/Button.button_down.connect(water)
	$Cat/Button.button_down.connect(pet)
	
	update_ui()


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
	var stat_changed = stats.keys()[randi() % 6] # StatType.size()]
	if stat_changed == StatType.HUMAN_TOLERANCE:
		capadd(stat_changed, 1)
	else:
		capadd(stat_changed, -1)
		
	for i in stats.keys():
		if stats[i] <= 0:
			print(i)
			emit_signal("cat_obliteration",i)
	update_ui()





# WHAT HAPPENS WHEN OBJECT USED

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
