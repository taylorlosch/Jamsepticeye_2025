extends CanvasLayer

signal dialogue_finished

var is_typing: bool = false
var can_continue: bool = false

func _ready() -> void:
	hide()

func show_dialogue(text: String) -> void:
	show()
	$DialoguePanel/DialogueText.text = ""
	$DialoguePanel/ContinuePrompt.visible = false
	is_typing = true
	can_continue = false
	
	# Type out text
	await type_text(text)
	
	# Show continue prompt
	is_typing = false
	can_continue = true
	$DialoguePanel/ContinuePrompt.visible = true

func type_text(text: String) -> void:
	var label = $DialoguePanel/DialogueText
	
	for i in range(text.length()):
		label.text += text[i]
		
		if text[i] == " ":
			continue
		$TypeSound.play()
		await get_tree().create_timer(0.03).timeout

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and can_continue and visible:
		can_continue = false  # Prevent multiple triggers
		hide()
		dialogue_finished.emit()
		get_viewport().set_input_as_handled()  # Consume the input so it doesn't reach other nodes
