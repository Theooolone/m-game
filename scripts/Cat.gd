extends Node2D

@onready var labelnode = $CanvasLayer/Label
@onready var catnode = $Cat

@onready var hunger_bar_node = $Hunger
@onready var thirst_bar_node = $Thirst
@onready var fun_bar_node = $Hunger
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
	
	print("-")
	print(hunger_bar_node.value)
	print(thirst_bar_node.value)
	print(fun_bar_node.value)
	print(human_tolerance_bar_node.value)


func _on_stat_tick_timeout():
	var stat_changed = stats.keys()[randi() % 6] # StatType.size()]
	if stat_changed == StatType.HUMAN_TOLERANCE:
		if stats[stat_changed] < 64:
			stats[stat_changed] += 1
	else:
		if stats[stat_changed] > 0:
			stats[stat_changed] -= 1
	
	for i in stats.keys():
		if stats[i] <= 0:
			emit_signal("cat_obliteration")
	update_ui()


# WHAT HAPPENS WHEN OBJECT USED

func food():
	stats[StatType.HUNGER] += 10
	update_ui()

func water():
	stats[StatType.THIRST] += 10
	update_ui()

# As chaotic as possible while still being fair if you know what you're doing
func pet():
	if stats[StatType.HUMAN_TOLERANCE] >= 32:
		stats[StatType.FUN] += 10
	elif stats[StatType.HUMAN_TOLERANCE] < 48:
		stats[StatType.FUN] -= 10
	
	# 80% chance of being random number 1-5, 20% chance of being 10
	var rand = 1 + randi() % 5
	if rand >= 5: rand = 10
	stats[StatType.HUMAN_TOLERANCE] -= rand
	update_ui()
