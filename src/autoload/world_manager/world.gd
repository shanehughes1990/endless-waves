extends Node2D
class_name World

## Base class for all game worlds.
##
## Provides common functionality, type safety, and standardized interface
## for world management. All world scenes should extend from this class.
## Each world manages its own spawn manager for customized gameplay.

# Signals for world lifecycle events
signal world_initialized()
signal world_started()
signal world_completed()
signal world_failed()

# World configuration
@export var world_name: String = "Unknown World"
@export var world_id: String = "world_unknown"
@export var difficulty_multiplier: float = 1.0
@export var coin_multiplier: float = 1.0
@export var world_description: String = "A mysterious world"
@export var world_theme_color: Color = Color.WHITE

# World state
var is_initialized: bool = false
var is_active: bool = false
var start_time: float = 0.0

# Spawn management
var spawn_manager: SpawnManager
const SPAWN_MANAGER_SCENE = preload("res://src/systems/spawn_manager/spawn_manager.tscn")

func _ready() -> void:
	print_debug("World: ", world_name, " (", world_id, ") ready")
	# Call initialize after a frame to ensure all children are ready
	call_deferred("initialize")

## Initialize the world - called automatically after _ready()
## Override in child classes to add world-specific setup
func initialize() -> void:
	if is_initialized:
		return
	
	print_debug("World: Initializing ", world_name)
	
	# Perform base initialization
	_setup_world()
	
	# Call child-specific initialization
	_on_world_initialize()
	
	is_initialized = true
	world_initialized.emit()
	print_debug("World: ", world_name, " initialized successfully")

## Start the world gameplay - called by WorldManager
func start_world() -> void:
	if not is_initialized:
		push_error("World: Cannot start world that hasn't been initialized")
		return
	
	if is_active:
		print_debug("World: ", world_name, " is already active")
		return
	
	print_debug("World: Starting ", world_name)
	start_time = Time.get_ticks_msec() / 1000.0
	is_active = true
	
	# Call child-specific start logic
	_on_world_start()
	
	world_started.emit()

## Stop the world - called by WorldManager or when world ends
func stop_world() -> void:
	if not is_active:
		return
	
	print_debug("World: Stopping ", world_name)
	is_active = false
	
	# Stop and cleanup spawn manager
	if spawn_manager:
		spawn_manager.reset_spawn_system()
	
	# Call child-specific stop logic
	_on_world_stop()

## Complete the world successfully
func complete_world() -> void:
	if not is_active:
		return
	
	print_debug("World: ", world_name, " completed successfully")
	stop_world()
	world_completed.emit()

## Fail the world (player defeated, etc.)
func fail_world() -> void:
	if not is_active:
		return
	
	print_debug("World: ", world_name, " failed")
	stop_world()
	world_failed.emit()

## Get world runtime in seconds
func get_world_runtime() -> float:
	if start_time <= 0:
		return 0.0
	return (Time.get_ticks_msec() / 1000.0) - start_time

## Get world configuration as dictionary
func get_world_config() -> Dictionary:
	return {
		"name": world_name,
		"id": world_id,
		"description": world_description,
		"theme_color": world_theme_color,
		"difficulty_multiplier": difficulty_multiplier,
		"coin_multiplier": coin_multiplier,
		"background_scene": get_background_scene(),
		"music_track": get_music_track(),
		"ambient_sounds": get_ambient_sounds(),
		"visual_theme": get_visual_theme(),
		"base_stats": get_base_stats(),
		"world_resources": get_world_resources()
	}

# Virtual methods for child classes to override

## Override in child classes for world-specific initialization
func _on_world_initialize() -> void:
	pass

## Override in child classes for world-specific start logic
func _on_world_start() -> void:
	pass

## Override in child classes for world-specific stop logic
func _on_world_stop() -> void:
	pass

## Override in child classes to define spawn points
func get_spawn_points() -> Array[Vector2]:
	return [Vector2(960, 540)]  # Default center spawn

## Override in child classes to define world boundaries
func get_world_bounds() -> Rect2:
	return Rect2(0, 0, 1920, 1080)  # Default screen bounds

## Get the spawn manager instance
func get_spawn_manager() -> SpawnManager:
	return spawn_manager

## Override in child classes to configure spawn manager settings
func _configure_spawn_manager() -> void:
	pass

## Override in child classes to define spawn radius
func get_spawn_radius() -> float:
	return 300.0  # Default radius

## Override in child classes to define enemy scenes
func get_enemy_scenes() -> Array[PackedScene]:
	return [preload("res://src/actors/enemies/debug_enemy.tscn")]  # Default enemy

## Override in child classes to define wave configuration
func get_wave_configuration() -> Dictionary:
	return {
		"auto_start_waves": false,
		"wave_delay": 5.0,
		"base_enemy_count": 5,
		"enemy_count_increase": 2,
		"base_wave_duration": 30.0,
		"spawn_interval": 1.0
	}

## Override in child classes to define background scene
func get_background_scene() -> PackedScene:
	return null  # No background by default

## Override in child classes to define music track
func get_music_track() -> AudioStream:
	return null  # No music by default

## Override in child classes to define ambient sounds
func get_ambient_sounds() -> Array[AudioStream]:
	return []  # No ambient sounds by default

## Override in child classes to define visual theme
func get_visual_theme() -> Dictionary:
	return {
		"primary_color": world_theme_color,
		"secondary_color": Color.GRAY,
		"accent_color": Color.YELLOW,
		"fog_color": Color.TRANSPARENT,
		"lighting_intensity": 1.0,
		"contrast": 1.0,
		"saturation": 1.0
	}

## Override in child classes to define base stats for entities in this world
func get_base_stats() -> Dictionary:
	return {
		"base_health": 100,
		"base_damage": 10,
		"base_fire_rate": 1.0,
		"base_movement_speed": 50.0,
		"base_armor": 0,
		"base_magic_resistance": 0
	}

## Override in child classes to define enemy scenes by type
func get_enemy_scenes_by_type() -> Dictionary:
	return {
		"basic": [preload("res://src/actors/enemies/debug_enemy.tscn")],
		"elite": [],
		"boss": []
	}

## Override in child classes to define world-specific resources
func get_world_resources() -> Dictionary:
	return {
		"backgrounds": [],
		"props": [],
		"effects": [],
		"textures": [],
		"materials": []
	}

# Private methods

## Base world setup - called during initialization
func _setup_world() -> void:
	# Apply world multipliers to WorldManager
	if WorldManager:
		WorldManager.apply_world_modifiers(difficulty_multiplier, coin_multiplier)
	
	# Initialize spawn manager
	_initialize_spawn_manager()
	
	# Set up any common world elements here
	_validate_world_structure()

## Initialize the spawn manager for this world
func _initialize_spawn_manager() -> void:
	if not SPAWN_MANAGER_SCENE:
		push_error("World: No spawn manager scene configured")
		return
	
	spawn_manager = SPAWN_MANAGER_SCENE.instantiate()
	if not spawn_manager:
		push_error("World: Failed to instantiate spawn manager")
		return
	
	# Position spawn manager at world center by default
	var world_bounds = get_world_bounds()
	spawn_manager.global_position = world_bounds.position + world_bounds.size / 2
	
	# Configure spawn manager with world-specific settings
	spawn_manager.spawn_radius = get_spawn_radius()
	
	# Apply wave configuration
	var wave_config = get_wave_configuration()
	spawn_manager.auto_start_waves = wave_config.get("auto_start_waves", false)
	spawn_manager.wave_delay = wave_config.get("wave_delay", 5.0)
	spawn_manager.base_enemy_count = wave_config.get("base_enemy_count", 5)
	spawn_manager.enemy_count_increase = wave_config.get("enemy_count_increase", 2)
	spawn_manager.base_wave_duration = wave_config.get("base_wave_duration", 30.0)
	spawn_manager.spawn_interval = wave_config.get("spawn_interval", 1.0)
	
	# Set enemy scenes with enhanced selection
	_configure_enemy_scenes()
	
	# Apply world visual theme
	_apply_world_theme()
	
	# Add to world
	add_child(spawn_manager)
	
	# Call world-specific configuration
	_configure_spawn_manager()
	
	print_debug("World: Spawn manager initialized at ", spawn_manager.global_position)

## Validate that the world has required components
func _validate_world_structure() -> void:
	# Add validation logic here as needed
	# For example: check for required child nodes, validate configuration, etc.
	if world_id.is_empty():
		push_error("World: world_id cannot be empty")
	
	if world_name.is_empty():
		world_name = "World " + world_id

## Configure enemy scenes for the spawn manager
func _configure_enemy_scenes() -> void:
	if not spawn_manager:
		return
	
	var enemy_types = get_enemy_scenes_by_type()
	
	# Set primary enemy (first basic enemy)
	var basic_enemies = enemy_types.get("basic", [])
	if basic_enemies.size() > 0:
		spawn_manager.debug_enemy_scene = basic_enemies[0]
	
	# Store enemy types in spawn manager for future use
	spawn_manager.set_meta("enemy_types", enemy_types)
	print_debug("World: Enemy scenes configured - Basic: ", basic_enemies.size(), ", Elite: ", enemy_types.get("elite", []).size(), ", Boss: ", enemy_types.get("boss", []).size())

## Apply world visual theme
func _apply_world_theme() -> void:
	var theme = get_visual_theme()
	print_debug("World: Applying visual theme - Primary: ", theme.get("primary_color"), ", Lighting: ", theme.get("lighting_intensity"))
	
	# Apply background if available
	var bg_scene = get_background_scene()
	if bg_scene:
		var background = bg_scene.instantiate()
		background.z_index = -100  # Behind everything
		add_child(background)
		print_debug("World: Background scene loaded")
	
	# TODO: Apply lighting, fog, and other visual effects
	# This could be expanded to modify CanvasLayer, Environment, etc.
	
	# Store theme for other systems to use
	set_meta("visual_theme", theme)
