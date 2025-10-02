extends Area2D

var spirit_scene = preload("res://scenes/spirit.tscn")
var target_position: Vector2 = Vector2.ZERO
var speed: float = 50.0
var spirit_worth: int = 1

var bob_speed: float = 0.0 
var bob_amount: float = 0.0  
var bob_offset: float = 0.0  

func _ready() -> void:
	bob_speed = randf_range(0.01, 0.02) 
	bob_amount = randf_range(1.5, 3.0)  
	bob_offset = randf_range(0.0, TAU)  
	
	# Optional: Random color tint
	$AnimatedSprite2D.modulate = Color(
		randf_range(0.8, 1.0),
		randf_range(0.8, 1.0), 
		randf_range(0.8, 1.0)
	)

func _process(delta: float) -> void:
	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta
	var bob = sin(Time.get_ticks_msec() * bob_speed + bob_offset) * bob_amount
	$AnimatedSprite2D.position.y = bob
	
	if global_position.distance_to(target_position) < 10.0:
		die()

func die() -> void:
	set_process(false)
	$AnimatedSprite2D.visible = false
	await get_tree().create_timer(0.5).timeout
	
	for i in spirit_worth:
		var spirit = spirit_scene.instantiate()
		spirit.global_position = global_position
		get_parent().add_child(spirit)
	
	queue_free()
