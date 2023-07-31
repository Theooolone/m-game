extends Node2D

@onready var labelnode = $CanvasLayer/Label

enum StatType {
	HUNGER,
	THIRST,
	FUN,
	HUMAN_TOLERANCE,
	AWAKENESS,
	CLEANLINESS
}

# lower is worse
@export_group("Stats")
@export var stats = {
	StatType.HUNGER: 100,
	StatType.THIRST: 100,
	#StatType.FUN: 100,
	#StatType.HUMAN_TOLERANCE: 100,
	#StatType.AWAKENESS: 100,
	#StatType.CLEANLINESS: 100,
}

var labeltext = "Hunger: %s\nThirst: %s\nFun: %s\nHuman Tolerance: %s\nAwakeness: %s\nCleanliness: %s"

func _ready():
	# set random initial seed for random functions
	randomize()
	$StatTick.wait_time = 1.0/stats.size()
	
	$Food/Button.button_down.connect(food)
	$Water/Button.button_down.connect(water)


func _process(_delta):
	labelnode.text =  labeltext % [
		stats[StatType.HUNGER],
		stats[StatType.THIRST],
		"NaN", "NaN", "NaN", "NaN"
		#stats[StatType.FUN],
		#stats[StatType.HUMAN_TOLERANCE],
		#stats[StatType.AWAKENESS],
		#stats[StatType.CLEANLINESS]
	]


func _on_stat_tick_timeout():
	var stat_changed = stats.keys()[randi() % 2] # StatType.size()]
	if stats[stat_changed] > 0:
		stats[stat_changed] -= 1

func food():
	stats[StatType.HUNGER] += 10

func water():
	stats[StatType.THIRST] += 10
