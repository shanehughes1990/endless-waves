extends "res://src/autoload/world_manager/world.gd"

## World 1 - The first level/world in the game.
##
## Extends the base World class and implements world-specific functionality.

func _ready() -> void:	
	# Call parent _ready
	super._ready()

## Override: World-specific initialization
func _on_world_initialize() -> void:
	print_debug(world_name+": Performing world-specific initialization")
	
	# Give additional coins for this peaceful world
	if WorldManager:
		WorldManager.add_coins(75)  # More generous for starting world
	
	# Auto-start the world for testing (deferred to ensure initialization is complete)
	call_deferred("start_world")

## Override: World-specific start logic
func _on_world_start() -> void:
	print_debug(world_name+": World started - beginning peaceful gameplay")
	
	# Apply world-specific upgrades after starting
	await get_tree().create_timer(2.0).timeout
	print_debug(world_name+": Applying nature's blessing...")
	if WorldManager:
		WorldManager.add_session_upgrade("damage", 5)
		WorldManager.add_session_upgrade("health", 25)
		WorldManager.add_session_upgrade("fire_rate", 2)

## Override: World-specific stop logic
func _on_world_stop() -> void:
	print_debug(world_name+": Leaving the peaceful gardens")
	
	# Call parent stop logic
	super._on_world_stop()

## Override: Define visual theme for Emerald Gardens
func get_visual_theme() -> Dictionary:
	return {
		"primary_color": Color(0.2, 0.8, 0.3),  # Vibrant green
		"secondary_color": Color(0.1, 0.6, 0.2),  # Darker green
		"accent_color": Color(1.0, 0.9, 0.3),  # Golden yellow
		"fog_color": Color(0.8, 1.0, 0.8, 0.1),  # Light green mist
		"lighting_intensity": 1.2,  # Bright, cheerful lighting
		"contrast": 1.1,  # Slightly enhanced contrast
		"saturation": 1.3  # More vibrant colors
	}

## Override: Define base stats for Emerald Gardens (beginner-friendly)
func get_base_stats() -> Dictionary:
	return {
		"base_health": 120,  # More health for beginners
		"base_damage": 12,  # Slightly higher damage
		"base_fire_rate": 1.1,  # Faster firing
		"base_movement_speed": 60.0,  # Faster movement
		"base_armor": 5,  # Some starting armor
		"base_magic_resistance": 0  # No magic resistance needed
	}

## Override: Define wave configuration for World 1
func get_wave_configuration() -> Dictionary:
	return {
		"auto_start_waves": false,  # Manual start for first world
		"wave_delay": 7.0,  # Longer delay between waves
		"base_enemy_count": 3,  # Start with fewer enemies
		"enemy_count_increase": 1,  # Slower progression
		"base_wave_duration": 25.0,  # Shorter waves
		"spawn_interval": 1.5  # Slower spawn rate
	}

## Override: Define spawn radius for World 1
func get_spawn_radius() -> float:
	return 250.0  # Smaller radius for first world
