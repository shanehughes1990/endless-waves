extends Node2D
class_name Base

## The player's base that can be upgraded with different components.

# References to components
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent

func _ready() -> void:
	# Connect to health component signals
	if health_component:
		health_component.died.connect(_on_health_component_died)
		health_component.health_changed.connect(_on_health_changed)

	# Connect to attack component signals
	if attack_component:
		attack_component.fired.connect(_on_attack_component_fired)

	# Connect to WorldManager signals for upgrade changes
	if WorldManager.has_signal("upgrade_applied"):
		WorldManager.upgrade_applied.connect(_on_upgrade_applied)

## Called when WorldManager applies an upgrade
func _on_upgrade_applied() -> void:
	print_debug("Base: Recalculating stats due to upgrade")
	if health_component:
		health_component.recalculate_stats()
	if attack_component:
		attack_component.recalculate_stats()

func _on_health_component_died() -> void:
	print_debug("Base destroyed!")
	# TODO: Implement game over logic

func _on_health_changed(current_health: int) -> void:
	print_debug("Base health: ", current_health)
	# TODO: Update UI health display

func _on_attack_component_fired(_projectile: Node) -> void:
	print_debug("Base fired a projectile!")
	# TODO: Could add visual/audio effects here
