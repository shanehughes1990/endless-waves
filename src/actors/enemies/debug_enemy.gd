extends Enemy
class_name DebugEnemy

## Debug enemy for testing the spawn system and base Enemy functionality.
##
## Simple enemy with minimal stats for testing purposes.
## Uses move_to_target movement state to reach the base.

func _ready() -> void:
	# Call parent _ready to initialize all systems
	super._ready()
	
	print_debug("DebugEnemy: Initialized with exportable base stats")

# Note: _set_base_stats() method removed - now using exportable base stats from parent class

## Override: Enemy-specific initialization
func _on_enemy_initialize() -> void:
	print_debug("DebugEnemy: Custom initialization complete")

## Override: No special abilities for debug enemy
func _activate_special_ability() -> void:
	print_debug("DebugEnemy: No special abilities")

## Override: Custom death behavior
func _on_enemy_death() -> void:
	print_debug("DebugEnemy: Custom death behavior triggered")
