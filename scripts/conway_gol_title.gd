extends Node2D


@onready var GridNode: TileMap = $Grid

var pos: Vector2i
var size: Vector2i


func _ready():
	update_rect()
	tick()


func update_rect():
	var used_rect = GridNode.get_used_rect()
	pos = used_rect.position
	size = used_rect.size


#func _process(delta):
#	if Input.is_action_just_pressed("click"):
#		tick()


func _on_tick_timeout():
	tick()


func _on_const_tick_time_decrease_timeout():
	$Tick.wait_time *= 0.98


func tick():
	for y in range(pos.y-1, pos.y+size.y+2):
		for x in range(pos.x-1, pos.x+size.x+2):
			update_cell(x,y)
	swap()
	update_rect()


func update_cell(x,y):
	if y > 60 or y < -20: 
		make_dead(x,y)
		return
	
	var neighbours = 0
	for y1 in [-1,0,1]:
		for x1 in [-1,0,1]:
			neighbours += int(is_alive(x+x1,y+y1))
	neighbours -= int(is_alive(x,y))
	match neighbours:
		0,1:
			make_dead(x,y)
		2:
			if is_alive(x,y): make_alive(x,y)
		3:
			make_alive(x,y)
		4,5,6,7,8:
			make_dead(x,y)


func swap():
	GridNode.move_layer(2,1)
	GridNode.clear_layer(2)


func is_alive(x,y) -> bool:
	return GridNode.get_cell_source_id(1,Vector2i(x,y)) == 1


func make_alive(x,y):
	GridNode.set_cell(0, Vector2i(x,y), 0, Vector2i(0,0))
	GridNode.set_cell(2, Vector2i(x,y), 1, Vector2i(0,0))


func make_dead(x,y):
	GridNode.erase_cell(0, Vector2i(x,y))
	GridNode.erase_cell(2, Vector2i(x,y))
