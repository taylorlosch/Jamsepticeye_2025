extends Area2D

var float_speed: float = 30.0
var wobble_amount: float = 15.0
var wobble_speed: float = 0.008
var wobble_offset: float = 0.0

func _ready() -> void:
	float_speed = randf_range(25.0, 40.0)
	wobble_amount = randf_range(10.0, 20.0)
	wobble_speed = randf_range(0.006, 0.012)
	wobble_offset = randf_range(0.0, TAU)

func _process(delta: float) -> void:
	global_position.y -= float_speed * delta
	var wobble = sin(Time.get_ticks_msec() * wobble_speed + wobble_offset) * wobble_amount
	position.x += wobble * delta
	
	if global_position.y < -10:
		GameManager.add_spirits(1) 
		queue_free()
