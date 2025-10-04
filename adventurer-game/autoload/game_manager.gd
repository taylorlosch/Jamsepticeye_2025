extends Node
var spirits: int = 0
var spirits_per_hero: int = 1
var heroes_per_click: int = 1


var auto_spawn_enabled: bool = false
var auto_spawn_rate: float = 1.0
var auto_spawn_level: int = 0  

func reset_game() -> void:
	spirits = 0
	spirits_per_hero = 1
	heroes_per_click = 1
	auto_spawn_enabled = false
	auto_spawn_rate = 2.0
	auto_spawn_level = 0

func add_spirits(amount: int) -> void:
	spirits += amount

func spend_spirits(amount: int) -> bool:
	if spirits >= amount:
		spirits -= amount
		return true
	return false
