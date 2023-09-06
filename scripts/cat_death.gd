extends CanvasLayer

# If these are too morbid for innocent kittens then please let me know
var death_messages: Dictionary = {
	"hunger": "%s died from the hungy",
	"thirst": "you didn't realse %s wasn't a cactus",
	"fun": "%s found you uninsteresting so they died",
	"human_tolerance": "%s died on the spot just to spite you",
	"energy": "%s collapsed from exhaustion",
	"cleanliness": "%s smelled too much like BO and just died"
}


# Called when the node enters the scene tree for the first time.
func _ready():
	var death_type = Global.scene_data[0]
	var cat_name = Global.scene_data[1]
	
	$Label.text = death_messages[death_type] % cat_name


func _on_scene_transition_timeout():
	Global.return_to_room()
