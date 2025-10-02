extends Node
var spirits: int = 0
var spirits_per_hero: int = 1
var heroes_per_click: int = 1


var auto_spawn_enabled: bool = false
var auto_spawn_rate: float = 1.0
var auto_spawn_level: int = 0  

# Called when spirit is collected
func add_spirits(amount: int) -> void:
	spirits += amount
	print("Spirits collected! Total: ", spirits)

# Called when spending spirits on upgrades
func spend_spirits(amount: int) -> bool:
	if spirits >= amount:
		spirits -= amount
		return true
	return false
