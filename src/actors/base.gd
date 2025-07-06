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

func _on_health_component_died() -> void:
	print_debug("Base destroyed!")
	# TODO: Implement game over logic

func _on_health_changed(_current_health: int) -> void:
	print_debug("Base health: ", _current_health)
	# TODO: Update UI health display

func _on_attack_component_fired(_projectile: Node) -> void:
	print_debug("Base fired a projectile!")
	# TODO: Could add visual/audio effects here
