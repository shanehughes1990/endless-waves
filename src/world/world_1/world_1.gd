extends "res://src/autoload/world_manager/world.gd"

## World 1 - The first level/world in the game.
##
## Extends the base World class and implements world-specific functionality.

func _ready() -> void:	
	# Call parent _ready
	super._ready()

## Override: World-specific initialization
func _on_world_initialize() -> void:
	Loggie.info(world_name+": Performing world-specific initialization")
	
	# Give additional coins for this peaceful world
	if WorldManager:
		WorldManager.add_coins(75)  # More generous for starting world
	
	# Auto-start the world for testing (deferred to ensure initialization is complete)
	call_deferred("start_world")

## Override: World-specific start logic
func _on_world_start() -> void:
	Loggie.info(world_name+": World started - beginning peaceful gameplay")
	
	# Apply world-specific upgrades after starting
	await get_tree().create_timer(2.0).timeout
	Loggie.info(world_name+": Applying nature's blessing...")
	if WorldManager:
		WorldManager.add_session_upgrade("damage", 5)
		WorldManager.add_session_upgrade("health", 25)
		WorldManager.add_session_upgrade("fire_rate", 2)

## Override: World-specific stop logic
func _on_world_stop() -> void:
	Loggie.info(world_name+": Leaving the peaceful gardens")
	
	# Call parent stop logic
	super._on_world_stop()
