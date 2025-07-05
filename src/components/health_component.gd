
extends Node
class_name HealthComponent

signal health_changed(current_health: int)
signal died()

@export var base_max_health: int = 100

# Internal upgrade bonuses
var health_bonus: int = 0

var current_health: int
var effective_max_health: int

func _ready() -> void:
	# Add to group so WorldManager can find this component
	add_to_group("health_components")
	
	# Validate base_max_health to prevent negative values
	if base_max_health <= 0:
		base_max_health = 1
		print_debug("HealthComponent: base_max_health was <= 0, set to 1")
	
	# Calculate effective max health with bonuses
	_recalculate_stats()
	current_health = effective_max_health
	
	# Apply any existing upgrades from WorldManager (in case we're created after upgrades applied)
	if WorldManager and WorldManager.has_method("apply_upgrades_to_component"):
		WorldManager.apply_upgrades_to_component(self)

## Recalculate stats based on base values + bonuses
func _recalculate_stats() -> void:
	var old_max_health = effective_max_health
	effective_max_health = max(1, base_max_health + health_bonus)
	
	# If max health increased, proportionally increase current health
	if old_max_health > 0 and effective_max_health > old_max_health:
		var health_ratio = float(current_health) / float(old_max_health)
		current_health = int(health_ratio * effective_max_health)
	
	# Ensure current health doesn't exceed new max
	if current_health > effective_max_health:
		current_health = effective_max_health
	
	health_changed.emit(current_health)
	print_debug("HealthComponent stats - Max Health: ", effective_max_health, 
		", Current Health: ", current_health)

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

## Apply health bonus
func apply_health_bonus(bonus: int) -> void:
	health_bonus = bonus
	_recalculate_stats()

## Reset health bonus to zero
func reset_bonuses() -> void:
	health_bonus = 0
	_recalculate_stats()

## Get current health bonus
func get_health_bonus() -> int:
	return health_bonus
