extends Node
class_name MovementState

## Base class for all movement states.
##
## Defines the interface that all movement states must implement.
## Each state handles specific movement behavior and transitions.

# Reference to the movement component that owns this state
var movement_component: Node

## Called when entering this state
func enter() -> void:
	pass

## Called every frame while in this state
func update(_delta: float) -> void:
	pass

## Called when exiting this state
func exit() -> void:
	pass

## Get the name of this state for debugging
func get_state_name() -> String:
	return "base_state"
