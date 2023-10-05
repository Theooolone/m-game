extends Sprite2D

var gol

var viewed_gol = false
@onready var explosion = get_node("../DeltaruneExplosion")

@onready var packedgol = preload("res://scenes/ui/conway_gol_title.tscn")

func _on_click_area_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("click") and not viewed_gol:
		gol = packedgol.instantiate()
		gol.global_position = $GolSpawn.global_position
		get_node("..").add_child(gol)
		get_node("..").move_child(gol ,1)
		hide()
		viewed_gol = true
		$ExplosionTimer.start()



func _on_explosion_timer_timeout():
	explosion.boom()
	await get_tree().create_timer(1).timeout
	gol.queue_free()
	await get_tree().create_timer(3).timeout
	show()
