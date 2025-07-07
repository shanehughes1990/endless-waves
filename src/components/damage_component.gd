extends Node
class_name DamageComponent

## Manages damage output for entities that can deal damage.
##
## Provides base damage values with upgrade bonuses, similar to HealthComponent.
## Integrates with WorldManager upgrade system for damage improvements.

signal damage_changed(current_damage: int)

@export var base_damage: int = 10

# Internal upgrade bonuses
var damage_bonus: int = 0

var effective_damage: int

func _ready() -> void:
	# Add to group so WorldManager can find this component
	add_to_group("damage_components")
	
	# Validate base_damage to prevent negative values
	if base_damage <= 0:
		base_damage = 1
		Loggie.msg("DamageComponent: base_damage was <= 0, set to 1").domain("DamageComp").warn()
	
	# Calculate effective damage with bonuses
	_recalculate_stats()

## Recalculate stats based on base values + bonuses
func _recalculate_stats() -> void:
	var old_damage = effective_damage
	effective_damage = max(1, base_damage + damage_bonus)
	
	# Emit signal if damage changed
	if old_damage != effective_damage:
		damage_changed.emit(effective_damage)
	
	Loggie.msg("DamageComponent stats - Base Damage: %s, Bonus: %s, Effective: %s" % [base_damage, damage_bonus, effective_damage]).domain("DamageComp").info()

## Get the current effective damage
func get_damage() -> int:
	return effective_damage

## Apply damage bonus from upgrades
func apply_damage_bonus(bonus: int) -> void:
	damage_bonus = bonus
	_recalculate_stats()

## Reset damage bonus to zero
func reset_bonuses() -> void:
	damage_bonus = 0
	_recalculate_stats()

## Get current damage bonus
func get_damage_bonus() -> int:
	return damage_bonus

## Set base damage (for different weapon types)
func set_base_damage(new_base_damage: int) -> void:
	base_damage = max(1, new_base_damage)
	_recalculate_stats()
