extends Node2D
class_name BaseNPC

## Base class for all NPCs (enemies and friendlies).
##
## Requires MovementComponent, HealthComponent, and AttackComponent as children.
## This class provides the foundation for all moving, attacking entities.

# Component references - these are required
@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent  
@onready var attack_component: AttackComponent = $AttackComponent

func _ready() -> void:
	# Validate that all required components are present
	_validate_components()
	
	# Connect component signals
	_connect_component_signals()

## Validate that all required components exist
func _validate_components() -> void:
	if not movement_component:
		push_error("BaseNPC: MovementComponent is required but not found!")
	if not health_component:
		push_error("BaseNPC: HealthComponent is required but not found!")
	if not attack_component:
		push_error("BaseNPC: AttackComponent is required but not found!")

## Connect to component signals
func _connect_component_signals() -> void:
	if health_component:
		health_component.died.connect(_on_health_component_died)
		health_component.health_changed.connect(_on_health_changed)
	
	if attack_component:
		attack_component.fired.connect(_on_attack_component_fired)
	
	if movement_component:
		movement_component.state_changed.connect(_on_movement_state_changed)
		movement_component.target_reached.connect(_on_movement_target_reached)

## Called when health component reports death
func _on_health_component_died() -> void:
	print_debug("BaseNPC: ", name, " died")
	# Stop movement when dead
	if movement_component:
		movement_component.stop_movement()
	# TODO: Add death effects, cleanup, scoring, etc.
	queue_free()

## Called when health changes
func _on_health_changed(current_health: int) -> void:
	print_debug("BaseNPC: ", name, " health: ", current_health)
	# TODO: Update health bar, trigger hurt effects, etc.

## Called when attack component fires
func _on_attack_component_fired(_projectile: Node) -> void:
	print_debug("BaseNPC: ", name, " fired projectile")
	# TODO: Add firing effects, sounds, etc.

## Called when movement state changes
func _on_movement_state_changed(old_state: String, new_state: String) -> void:
	print_debug("BaseNPC: ", name, " movement: ", old_state, " -> ", new_state)
	# TODO: Sync animations with movement states

## Called when movement target is reached
func _on_movement_target_reached() -> void:
	print_debug("BaseNPC: ", name, " reached movement target")
	# TODO: Handle arrival at destination (attack base, patrol point, etc.)
