extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	# Get all overlapping areas
	var overlapping = get_overlapping_areas()
	
	# Delete any heroes touching the dungeon
	for area in overlapping:
		if area.name == "Hero":
			if area.has_method("die"):
				area.die()  # Call hero's die function
			else:
				area.queue_free()  # Fallback

func _on_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)

func _on_area_entered(area: Area2D) -> void:
	print("Area entered: ", area.name)
	
	if area.name == "Hero":
		if area.has_method("die"):
			area.die()
		else:
			area.queue_free()
