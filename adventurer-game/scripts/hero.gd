extends Area2D


var spirit_scene = preload("res://scenes/spirit.tscn")
var target_position: Vector2 = Vector2.ZERO
var speed: float = 50.0
var spirit_worth: int = 1 



func _process(delta: float) -> void:
	var direction = (target_position - global_position).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)
	var wobble = sin(Time.get_ticks_msec() * 0.01) * 2.0
	global_position += direction * speed * delta
	global_position += perpendicular * wobble * delta
	
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
