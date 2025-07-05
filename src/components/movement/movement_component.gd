extends Node
class_name MovementComponent

## Manages movement behavior through a finite state machine.
##
## This component handles movement styles and state transitions for NPCs and enemies.

# Signal emitted when movement state changes
signal state_changed(old_state: String, new_state: String)
signal target_reached()

# Movement configuration
@export var movement_speed: float = 100.0
@export var target_position: Vector2 = Vector2.ZERO
@export var collision_detection_range: float = 5.0

# Current movement state
var current_state: MovementState
var movement_states: Dictionary = {}

# Reference to the owner's body for movement
var body: Node2D

func _ready() -> void:
	# Add to group so WorldManager can find this component
	add_to_group("movement_components")
	
	# Get reference to the owner (should be the character body)
	body = get_owner()
	if not body:
		push_error("MovementComponent: No owner found!")
		return
	
	# Initialize with default state
	_discover_states()
	
	# Initialize with default state (idle if available, otherwise first found state)
	if "idle" in movement_states:
		_change_state("idle")
	elif not movement_states.is_empty():
		_change_state(movement_states.keys()[0])
	else:
		print_debug("MovementComponent: No movement states found as child nodes")

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

## Discover movement states from child nodes
func _discover_states() -> void:
	movement_states.clear()
	
	for child in get_children():
		if child.has_method("get_state_name") and child.has_method("enter") and child.has_method("exit") and child.has_method("update"):
			# This is a movement state node
			child.movement_component = self
			var state_name = child.get_state_name()
			movement_states[state_name] = child
			print_debug("MovementComponent: Found state '", state_name, "'")

## Change to a new movement state
func _change_state(state_name: String) -> void:
	var old_state_name = ""
	if current_state:
		old_state_name = current_state.get_state_name()
		current_state.exit()
	
	if state_name in movement_states:
		current_state = movement_states[state_name]
		current_state.enter()
		state_changed.emit(old_state_name, state_name)
		print_debug("MovementComponent: Changed state from '", old_state_name, "' to '", state_name, "'")
	else:
		push_error("MovementComponent: Unknown state: " + state_name)

## Public API for setting target and starting movement
func move_to_target(target: Vector2) -> void:
	target_position = target
	_change_state("move_to_target")

## Stop movement and return to idle
func stop_movement() -> void:
	_change_state("idle")

## Get current state name
func get_current_state() -> String:
	if current_state:
		return current_state.get_state_name()
	return "none"

## Check if target has been reached
func is_target_reached() -> bool:
	if not body:
		return false
	return body.global_position.distance_to(target_position) <= collision_detection_range

## Move the body towards a position
func move_towards(target: Vector2, delta: float) -> void:
	if not body:
		return
	
	var direction = (target - body.global_position).normalized()
	var movement = direction * movement_speed * delta
	
	# Simple position-based movement (lightweight for idle game)
	body.global_position += movement
	
	# Check if we've reached the target
	if is_target_reached():
		target_reached.emit()
