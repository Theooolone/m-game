extends Node2D

@onready var labelnode = $CanvasLayer/Label

# lower is worse
@export_range(0,100) var hunger = 100
@export_range(0,100) var thirst = 100
@export_range(0,100) var fun = 100
@export_range(0,100) var human_tolerance = 100
@export_range(0,100) var awakeness = 100
@export_range(0,100) var cleanliness = 100

var labeltext = "Hunger: %s\nThirst: %s\nFun: %s\nHuman Tolerance: %s\nAwakeness: %s\nCleanliness: %s"

func _ready():
	randomize() # set random initial seed for random functions

func _process(delta):
	labelnode.text =  labeltext % [hunger,thirst,fun,human_tolerance,awakeness,cleanliness]


func _on_timer_timeout():
	match randi() % 6:
		0:  if hunger > 0: hunger -= 1
		1: if thirst > 0: thirst -= 1
		2: if fun > 0: fun -= 1
		3: if human_tolerance > 0: human_tolerance -= 1
		4: if awakeness > 0: awakeness -= 1
		5: if cleanliness > 0: cleanliness -= 1
