
extends Node
class_name HealthComponent

signal health_changed(current_health: int)
signal died()

@export var base_max_health: int = 100
var current_health: int
var effective_max_health: int


func _ready() -> void:
	# Validate base_max_health to prevent negative values
	if base_max_health <= 0:
		base_max_health = 1
		print_debug("HealthComponent: base_max_health was <= 0, set to 1")
	
	# Calculate effective max health with WorldManager bonuses
	recalculate_stats()
	current_health = effective_max_health

## Recalculate stats based on WorldManager bonuses
func recalculate_stats() -> void:
	effective_max_health = base_max_health + WorldManager.get_health_bonus()
	# Ensure current health doesn't exceed new max
	if current_health > effective_max_health:
		current_health = effective_max_health
	health_changed.emit(current_health)

## Get the current effective max health
func get_max_health() -> int:
	return effective_max_health


func take_damage(damage_amount: int) -> void:
	# Validate damage amount - negative damage is treated as healing
	if damage_amount < 0:
		heal(-damage_amount)
		return
	
	current_health -= damage_amount
	if current_health < 0:
		current_health = 0
	
	health_changed.emit(current_health)
	
	if current_health == 0:
		died.emit()

func heal(heal_amount: int) -> void:
	# Validate heal amount
	if heal_amount <= 0:
		return
	
	current_health += heal_amount
	if current_health > effective_max_health:
		current_health = effective_max_health
	
	health_changed.emit(current_health)

func get_current_health() -> int:
	return current_health
