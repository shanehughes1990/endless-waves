extends Node
class_name UpgradesComponent

signal upgrade_purchased(upgrade_name: String, level: int)

var upgrades: Dictionary = {}

func _ready() -> void:
	# Initialize base upgrades
	upgrades = {
		"damage": {"level": 0, "cost": 10},
		"health": {"level": 0, "cost": 15},
		"fire_rate": {"level": 0, "cost": 12}
	}

func get_upgrade_level(upgrade_name: String) -> int:
	return upgrades.get(upgrade_name, {}).get("level", 0)

func get_upgrade_cost(upgrade_name: String) -> int:
	var upgrade = upgrades.get(upgrade_name, {})
	var base_cost = upgrade.get("cost", 10)
	var level = upgrade.get("level", 0)
	return base_cost + (level * 5)  # Cost increases with level

func purchase_upgrade(upgrade_name: String, coins_component: CoinsComponent) -> bool:
	if not upgrades.has(upgrade_name):
		return false
	
	var cost = get_upgrade_cost(upgrade_name)
	if coins_component.spend_coins(cost):
		upgrades[upgrade_name]["level"] += 1
		upgrade_purchased.emit(upgrade_name, upgrades[upgrade_name]["level"])
		return true
	
	return false

func get_all_upgrades() -> Dictionary:
	return upgrades
