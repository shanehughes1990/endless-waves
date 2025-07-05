extends MovementState
class_name MoveToTargetState

## Move to target movement state.
##
## Moves the character directly towards the target position in a straight line.
## Stops when collision detection range is reached.

## Called when entering move to target state
func enter() -> void:
	print_debug("MoveToTargetState: Started moving to target at ", movement_component.target_position)

## Called every frame while moving to target
func update(delta: float) -> void:
	if not movement_component:
		return
	
	# Check if we've reached the target
	if movement_component.is_target_reached():
		print_debug("MoveToTargetState: Target reached!")
		movement_component.target_reached.emit()
		movement_component.stop_movement()
		return
	
	# Move towards the target
	movement_component.move_towards(movement_component.target_position, delta)

## Called when exiting move to target state
func exit() -> void:
	print_debug("MoveToTargetState: Stopped moving to target")

## Get the name of this state
func get_state_name() -> String:
	return "move_to_target"
