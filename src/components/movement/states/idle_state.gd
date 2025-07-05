extends MovementState
class_name IdleState

## Idle movement state - does nothing.
##
## This is the default state when no movement is required.

## Called when entering idle state
func enter() -> void:
	print_debug("IdleState: Entered idle state")

## Called every frame while idle (does nothing)
func update(_delta: float) -> void:
	# Idle state does nothing
	pass

## Called when exiting idle state
func exit() -> void:
	print_debug("IdleState: Exited idle state")

## Get the name of this state
func get_state_name() -> String:
	return "idle"
