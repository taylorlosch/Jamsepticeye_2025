extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	var overlapping = get_overlapping_areas()
	
	for area in overlapping:
		if area.name == "Hero":
			if area.has_method("die"):
				area.die() 
			else:
				area.queue_free()

func _on_body_entered(body: Node2D) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	
	if area.name == "Hero":
		if area.has_method("die"):
			area.die()
		else:
			area.queue_free()
