extends "res://src/autoload/world_manager/world.gd"

## World 1 - The first level/world in the game.
##
## Extends the base World class and implements world-specific functionality.

func _ready() -> void:
	# Set world configuration
	world_name = "First World"
	world_id = "world_1"
	difficulty_multiplier = 1.0
	coin_multiplier = 1.0
	
	# Call parent _ready
	super._ready()

## Override: World-specific initialization
func _on_world_initialize() -> void:
	print_debug("World 1: Performing world-specific initialization")
	
	# Example: Give player some starting coins for this world
	if WorldManager:
		WorldManager.add_coins(50)
	
	# Auto-start the world for testing (deferred to ensure initialization is complete)
	call_deferred("start_world")

## Override: World-specific start logic
func _on_world_start() -> void:
	print_debug("World 1: World started - beginning gameplay")
	
	# Example: Apply some test upgrades after starting
	await get_tree().create_timer(2.0).timeout
	print_debug("World 1: Applying test upgrades...")
	if WorldManager:
		WorldManager.add_session_upgrade("damage", 5)
		WorldManager.add_session_upgrade("health", 25)
		WorldManager.add_session_upgrade("fire_rate", 2)

## Override: World-specific stop logic
func _on_world_stop() -> void:
	print_debug("World 1: World stopped")

## Override: Define spawn points for this world
func get_spawn_points() -> Array[Vector2]:
	# Return multiple spawn points around the center
	return [
		Vector2(960, 540),  # Center
		Vector2(760, 340),  # Top-left
		Vector2(1160, 340), # Top-right
		Vector2(760, 740),  # Bottom-left
		Vector2(1160, 740)  # Bottom-right
	]

## Override: Define world boundaries
func get_world_bounds() -> Rect2:
	return Rect2(0, 0, 1920, 1080)
