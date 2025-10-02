extends Node2D

var hero_scene = preload("res://scenes/hero.tscn")

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

func _ready() -> void:
	
	hero_spawn_btn.pressed.connect(_on_spawn_button_pressed)
	hero_spawn_btn.button_down.connect(_on_hero_button_down)
	hero_spawn_btn.button_up.connect(_on_hero_button_up)

	pay_debt_btn.pressed.connect(_on_pay_debt_pressed)
	upgrade_more_heroes_btn.pressed.connect(_on_upgrade_more_heroes_pressed)
	upgrade_auto_spawn_btn.pressed.connect(_on_upgrade_auto_spawn_pressed)
	update_upgrade_button_text()
	update_auto_spawn_button_text()
	update_pay_debt_button_text()
	
func _on_upgrade_more_heroes_pressed() -> void:
	if GameManager.spend_spirits(upgrade_more_heroes_cost):
		GameManager.heroes_per_click += 1
		print("Upgraded! Heroes per click: ", GameManager.heroes_per_click)
		upgrade_more_heroes_cost *= 2
		update_upgrade_button_text()
	else:
		print("Not enough spirits! Need ", upgrade_more_heroes_cost, " but have ", GameManager.spirits)

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
	
	var current_hero_count = get_tree().get_nodes_in_group("heroes").size()
	
	
	for i in GameManager.heroes_per_click:
		if current_hero_count + i >= max_heroes:
			print("Too many heroes! Max: ", max_heroes)
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
	if GameManager.spend_spirits(upgrade_auto_spawn_cost):
		if not GameManager.auto_spawn_enabled:
			GameManager.auto_spawn_enabled = true
			print("Auto-spawn enabled!")
		else:
			GameManager.auto_spawn_level += 1
			GameManager.auto_spawn_rate = max(0.5, GameManager.auto_spawn_rate * 0.8)
			print("Auto-spawn upgraded! Level: ", GameManager.auto_spawn_level)
		upgrade_auto_spawn_cost *= 4
		update_auto_spawn_button_text()
	else:
		print("Not enough spirits! Need ", upgrade_auto_spawn_cost, " but have ", GameManager.spirits)

func update_auto_spawn_button_text() -> void:
	if upgrade_auto_spawn_btn.has_node("CostLabel"):
		upgrade_auto_spawn_btn.get_node("CostLabel").text = str(upgrade_auto_spawn_cost)
	else:
		upgrade_auto_spawn_btn.text = str(upgrade_auto_spawn_cost)

func _on_pay_debt_pressed() -> void:
	var cost = 10
	
	if GameManager.spend_spirits(cost):
		print("Debt paid! Triggering ending...")
		# TODO: Add ending sequence later
	else:
		print("Not enough souls! Need ", cost, " but have ", GameManager.spirits)
		
func update_pay_debt_button_text() -> void:
	var cost = 10000
	
	if pay_debt_btn.has_node("CostLabel"):
		pay_debt_btn.get_node("CostLabel").text = str(cost)
		
func _process(delta: float) -> void:
	# Update spirit count display
	spirit_label.text = "Souls: " + str(GameManager.spirits)
	
	# Track total souls (current + spent)
	total_souls_earned = GameManager.spirits + get_total_spent()
	
	# Auto-spawn heroes if enabled
	if GameManager.auto_spawn_enabled:
		auto_spawn_timer += delta
		
		if auto_spawn_timer >= GameManager.auto_spawn_rate:
			auto_spawn_timer = 0.0
			spawn_heroes_auto()

func get_total_spent() -> int:
	# Calculate how much was spent on upgrades
	# This is an approximation - you could track it more precisely
	var spent = 0
	
	# Heroes per click upgrades (10, 20, 40, 80...)
	if GameManager.heroes_per_click > 1:
		for i in range(1, GameManager.heroes_per_click):
			spent += 10 * pow(2, i - 1)
	
	# Auto spawn upgrades (500, 2000, 8000...)
	if GameManager.auto_spawn_level > 0:
		for i in range(GameManager.auto_spawn_level):
			spent += 500 * pow(4, i)
	
	return spent
