extends Node2D

var hero_scene = preload("res://scenes/hero.tscn")
var end_screen_scene = preload("res://scenes/ui/EndScreen.tscn")

var max_heroes: int = 300
var upgrade_more_heroes_cost: int = 10
var upgrade_auto_spawn_cost: int = 500
var auto_spawn_timer: float = 0.0
var pay_debt_cost: int = 10000

var total_souls_earned: int = 0

@onready var hero_spawn_btn = $UI/BottomPanel/HeroSpawnButton
@onready var spirit_label = $UI/SpiritCountLabel
@onready var upgrade_more_heroes_btn = $UI/BottomPanel/UpgradeMoreHeroesButton
@onready var upgrade_auto_spawn_btn = $UI/BottomPanel/UpgradeAutoSpawnButton
@onready var pay_debt_btn = $UI/BottomPanel2/PayDebtButton 
@onready var click_sound = $UI/ClickSoundPlayer

var dialogue_box_scene = preload("res://scenes/ui/DialogueBox.tscn")
var dialogue_box: CanvasLayer = null



# Track which dialogues have been shown
var dialogues_shown: Dictionary = {
	"intro": false,
	"100": false,
	"400": false,
	"800": false,
	"1500": false,
	"2000": false,
	"5000": false,
	"8000": false,
}

func _ready() -> void:
	dialogue_box = dialogue_box_scene.instantiate()
	add_child(dialogue_box)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	
	
	show_intro_dialogue()
	
	hero_spawn_btn.pressed.connect(_on_spawn_button_pressed)
	hero_spawn_btn.button_down.connect(_on_hero_button_down)
	hero_spawn_btn.button_up.connect(_on_hero_button_up)

	pay_debt_btn.pressed.connect(_on_pay_debt_pressed)
	upgrade_more_heroes_btn.pressed.connect(_on_upgrade_more_heroes_pressed)
	upgrade_auto_spawn_btn.pressed.connect(_on_upgrade_auto_spawn_pressed)
	update_upgrade_button_text()
	update_auto_spawn_button_text()
	update_pay_debt_button_text()
	
		
func show_intro_dialogue() -> void:
	set_process(false) 
	disable_ui()  
	dialogue_box.show_dialogue("You owe 10,000 souls mortal. Send adventurers into the dungeon. Their death- is your opportunity.")
	dialogues_shown["intro"] = true

func _on_dialogue_finished() -> void:
	enable_ui()  
	set_process(true) 

func check_soul_milestones() -> void:
	if GameManager.spirits >= 100 and not dialogues_shown["100"]:
		dialogues_shown["100"] = true
		set_process(false)
		disable_ui()
		dialogue_box.show_dialogue("Look at that, your first 100.. Wasn't so bad right? Those guys chose to go. You only pointed the way.")
	
	if GameManager.spirits >= 400 and not dialogues_shown["400"]:
		dialogues_shown["400"] = true
		set_process(false)
		disable_ui()
		dialogue_box.show_dialogue("The guild is booming now, and your aura has started to change.. Do you feel it?")
		
	elif GameManager.spirits >= 800 and not dialogues_shown["800"]:
		dialogues_shown["800"] = true
		set_process(false)
		disable_ui() 
		dialogue_box.show_dialogue("Got the hang of it now, huh?.. Guess you really are different from them.")
		
	elif GameManager.spirits >= 1500 and not dialogues_shown["1500"]:
		dialogues_shown["1500"] = true
		set_process(false)
		disable_ui() 
		dialogue_box.show_dialogue("I Didn't expect you to pull them in so quick... You've got a knack for this.")
		
	elif GameManager.spirits >= 2000 and not dialogues_shown["2000"]:
		dialogues_shown["2000"] = true
		set_process(false)
		disable_ui() 
		dialogue_box.show_dialogue("Humans really are fools... They don't even see your changing...")
		
	elif GameManager.spirits >= 5000 and not dialogues_shown["5000"]:
		dialogues_shown["5000"] = true
		set_process(false)
		disable_ui() 
		dialogue_box.show_dialogue("Half way ther- Hey... Why do you look cooler than me? Tch! No fair...")
	
	elif GameManager.spirits >= 8000 and not dialogues_shown["8000"]:
		dialogues_shown["8000"] = true
		set_process(false)
		disable_ui() 
		dialogue_box.show_dialogue("Look, you werne't really supposed to be ok doing this... Just. Just avoid the pay debt button there ok?")
		
func disable_ui() -> void:
	hero_spawn_btn.disabled = true
	upgrade_more_heroes_btn.disabled = true
	upgrade_auto_spawn_btn.disabled = true
	pay_debt_btn.disabled = true

func enable_ui() -> void:
	hero_spawn_btn.disabled = false
	upgrade_more_heroes_btn.disabled = false
	upgrade_auto_spawn_btn.disabled = false
	pay_debt_btn.disabled = false

func _on_upgrade_more_heroes_pressed() -> void:
	click_sound.play()
	if GameManager.spend_spirits(upgrade_more_heroes_cost):
		GameManager.heroes_per_click += 2
		upgrade_more_heroes_cost *= 4
		update_upgrade_button_text()

func update_upgrade_button_text() -> void:
	var next_level = GameManager.heroes_per_click + 1
	
	if upgrade_more_heroes_btn.has_node("CostLabel"):
		upgrade_more_heroes_btn.get_node("CostLabel").text = str(upgrade_more_heroes_cost)
	else:
		upgrade_more_heroes_btn.text = "x" + str(next_level) + "\n" + str(upgrade_more_heroes_cost)
		

func _on_hero_button_down() -> void:
	var target_scale = Vector2(1.8, 1.8) * 0.9
	var tween = create_tween()
	tween.tween_property(hero_spawn_btn, "scale", target_scale, 0.05)

func _on_hero_button_up() -> void:
	var target_scale = Vector2(1.8, 1.8)
	var tween = create_tween()
	tween.tween_property(hero_spawn_btn, "scale", target_scale, 0.05)
	
		
func _on_spawn_button_pressed() -> void:
	click_sound.play()
	var current_hero_count = get_tree().get_nodes_in_group("heroes").size()
	
	
	for i in GameManager.heroes_per_click:
		if current_hero_count + i >= max_heroes:
			break
			
		var hero = hero_scene.instantiate()
		
		hero.add_to_group("heroes")
		
	for i in GameManager.heroes_per_click:
		var hero = hero_scene.instantiate()
		var random_x = randf_range(140, 180)
		hero.global_position = Vector2(random_x, 170)
		hero.target_position = $Dungeon.global_position
		hero.spirit_worth = GameManager.spirits_per_hero
		add_child(hero)
		await get_tree().create_timer(0.05).timeout

func spawn_heroes_auto() -> void:
	var heroes_to_spawn = 4 * pow(4, GameManager.auto_spawn_level)
	
	for i in heroes_to_spawn:
		var hero = hero_scene.instantiate()
		
		var random_x = randf_range(140, 180)
		hero.global_position = Vector2(random_x, 170)
		hero.target_position = $Dungeon.global_position
		add_child(hero)
		await get_tree().create_timer(0.05).timeout

func _on_upgrade_auto_spawn_pressed() -> void:
	click_sound.play()
	if GameManager.spend_spirits(upgrade_auto_spawn_cost):
		if not GameManager.auto_spawn_enabled:
			GameManager.auto_spawn_enabled = true
		else:
			GameManager.auto_spawn_level += 1
			GameManager.auto_spawn_rate = max(0.5, GameManager.auto_spawn_rate * 0.8)
		upgrade_auto_spawn_cost *= 4
		update_auto_spawn_button_text()

func update_auto_spawn_button_text() -> void:
	if upgrade_auto_spawn_btn.has_node("CostLabel"):
		upgrade_auto_spawn_btn.get_node("CostLabel").text = str(upgrade_auto_spawn_cost)
	else:
		upgrade_auto_spawn_btn.text = str(upgrade_auto_spawn_cost)

func _on_pay_debt_pressed() -> void:
	click_sound.play()
	if GameManager.spend_spirits(pay_debt_cost): 
		trigger_ending()
		
func trigger_ending() -> void:
	set_process(false)
	var tween = create_tween()
	tween.tween_property($BackgroundMusic, "volume_db", -80.0, 1.0)
	
	var total = total_souls_earned
	var end_screen = end_screen_scene.instantiate()
	add_child(end_screen)
	end_screen.show_ending(total)
	
func update_pay_debt_button_text() -> void:
	if pay_debt_btn.has_node("CostLabel"):
		pay_debt_btn.get_node("CostLabel").text = str(pay_debt_cost)
	
		
func _process(delta: float) -> void:
	spirit_label.text = "Souls: " + str(GameManager.spirits)
	total_souls_earned = GameManager.spirits + get_total_spent()
	check_soul_milestones()
	
	if GameManager.auto_spawn_enabled:
		auto_spawn_timer += delta
		
		if auto_spawn_timer >= GameManager.auto_spawn_rate:
			auto_spawn_timer = 0.0
			spawn_heroes_auto()

func get_total_spent() -> int:
	var spent = 0
	if GameManager.heroes_per_click > 1:
		for i in range(1, GameManager.heroes_per_click):
			spent += 10 * pow(2, i - 1)
	if GameManager.auto_spawn_level > 0:
		for i in range(GameManager.auto_spawn_level):
			spent += 500 * pow(4, i)
	
	return spent
