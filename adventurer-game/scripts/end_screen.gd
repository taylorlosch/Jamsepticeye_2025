extends CanvasLayer

func _ready() -> void:
	print("End screen loaded")
	$RestartButton.visible = false
	$RestartButton.pressed.connect(_on_restart_pressed)

func show_ending(total_souls: int) -> void:
	# Make sure labels start hidden
	$DialogueLabel.visible = false
	$StatsLabel.visible = false
	
	# Fade in black background
	var tween = create_tween()
	tween.tween_property($BlackBackground, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	# Type out dialogue
	await type_text($DialogueLabel, "Huh, I didn't think you'd actually do it...")
	
	# Wait a moment
	await get_tree().create_timer(1.0).timeout
	
	# Type out stats
	var stats_text = "Total Souls Collected: " + str(total_souls)
	await type_text($StatsLabel, stats_text)
	await get_tree().create_timer(0.5).timeout
	$RestartButton.visible = true

func type_text(label: Label, text: String) -> void:
	label.visible = true
	label.text = ""
	
	for i in range(text.length()):
		label.text += text[i]
		$TypeSound.play()
		if text[i] == " ":
			continue
		
		await get_tree().create_timer(0.03).timeout
		
		
func _on_restart_pressed() -> void:
	GameManager.reset_game()
	get_tree().reload_current_scene()
