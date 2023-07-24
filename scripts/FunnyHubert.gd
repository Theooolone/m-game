extends Sprite2D

@onready var startcoords = self.position

@onready var PulseSprite = $Pulse

func playtween():
	var pulse = get_tree().create_tween()
	PulseSprite.scale = Vector2.ONE
	PulseSprite.self_modulate = Color(1,1,1,0.5)
	pulse.set_parallel(true)
	pulse.tween_property(PulseSprite, "scale", Vector2.ONE*1.5, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pulse.tween_property(PulseSprite, "self_modulate", Color.TRANSPARENT, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


var time

func _process(delta):
	time = Time.get_ticks_msec()/1000.0
	self_modulate = Color.from_hsv(time/2,1,1)
	rotate(1.7547*delta)
	skew = sin(2*time)
	scale.x = 3+sin(time*2.6546)
	scale.y = 3+cos(time*1.6546)
	position.x = startcoords.x+24*sin(time*0.9543)
	position.y = startcoords.y+24*sin(time*0.6538)


func _on_pulse_timer_timeout():
	playtween()
