extends BaseNPC
class_name DebugEnemy

## Debug enemy for testing purposes.
##
## A simple enemy that moves toward the base and attacks it.
## Inherits all component functionality from BaseNPC.

func _ready() -> void:
	# Call parent _ready to initialize components
	super._ready()
	
	# Debug enemy specific initialization
	print_debug("DebugEnemy: ", name, " spawned")
	
	# Set up movement to attack the base (center of screen)
	_setup_movement()

## Configure movement to target the base
func _setup_movement() -> void:
	if movement_component:
		# Set target to center of screen (where base should be)
		var screen_center = get_viewport().get_visible_rect().size / 2
		movement_component.move_to_target(screen_center)
		print_debug("DebugEnemy: Moving to base at ", screen_center)

## Override movement target reached to attack the base
func _on_movement_target_reached() -> void:
	super._on_movement_target_reached()
	print_debug("DebugEnemy: Reached base - should start attacking!")
	
	# TODO: Switch to attacking the base when we reach it
	# For now, just stop movement
	if movement_component:
		movement_component.stop_movement()

## Override death to add debug logging
func _on_health_component_died() -> void:
	print_debug("DebugEnemy: Enemy destroyed!")
	super._on_health_component_died()
