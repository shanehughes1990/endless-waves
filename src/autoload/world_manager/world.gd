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

# Spawn Manager Configuration (editable in Godot editor per world)
@export_group("Spawn Configuration")
@export var spawn_radius: float = 300.0
@export var auto_start_waves: bool = false
@export var wave_delay: float = 5.0
@export var base_enemy_count: int = 5
@export var enemy_count_increase: int = 2
@export var base_wave_duration: float = 30.0
@export var spawn_interval: float = 1.0
@export var debug_enemy_scene: PackedScene = preload("res://src/actors/enemies/debug_enemy.tscn")

# World state
var is_initialized: bool = false
var is_active: bool = false
var start_time: float = 0.0

# Spawn management
var spawn_manager: SpawnManager
const SPAWN_MANAGER_SCENE = preload("res://src/systems/spawn_manager/spawn_manager.tscn")

func _ready() -> void:
	Loggie.debug("World: ", world_name, " (", world_id, ") ready")
	# Call initialize after a frame to ensure all children are ready
	call_deferred("initialize")

## Initialize the world - called automatically after _ready()
## Override in child classes to add world-specific setup
func initialize() -> void:
	if is_initialized:
		return
	
	Loggie.info("World: Initializing ", world_name)
	
	# Perform base initialization
	_setup_world()
	
	# Register this world with the WorldManager
	if WorldManager:
		WorldManager.register_world(self)
	
	# Call child-specific initialization
	_on_world_initialize()
	
	is_initialized = true
	world_initialized.emit()
	Loggie.info("World: ", world_name, " initialized successfully")

## Start the world gameplay - called by WorldManager
func start_world() -> void:
	if not is_initialized:
		push_error("World: Cannot start world that hasn't been initialized")
		return
	
	if is_active:
		Loggie.debug("World: ", world_name, " is already active")
		return
	
	Loggie.info("World: Starting ", world_name)
	start_time = Time.get_ticks_msec() / 1000.0
	is_active = true
	
	# Call child-specific start logic
	_on_world_start()
	
	world_started.emit()

## Stop the world - called by WorldManager or when world ends
func stop_world() -> void:
	if not is_active:
		return
	
	Loggie.info("World: Stopping ", world_name)
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
	
	Loggie.info("World: ", world_name, " completed successfully")
	stop_world()
	world_completed.emit()

## Fail the world (player defeated, etc.)
func fail_world() -> void:
	if not is_active:
		return
	
	Loggie.warn("World: ", world_name, " failed")
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
		"spawn_radius": spawn_radius,
		"auto_start_waves": auto_start_waves,
		"base_enemy_count": base_enemy_count,
		"enemy_count_increase": enemy_count_increase
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
	# Get the SpawnManager node from the scene
	spawn_manager = get_node("SpawnManager") as SpawnManager
	if not spawn_manager:
		push_error("World: No SpawnManager node found in scene")
		return
	
	# Configure spawn manager with exported properties
	spawn_manager.spawn_radius = spawn_radius
	spawn_manager.auto_start_waves = auto_start_waves
	spawn_manager.wave_delay = wave_delay
	spawn_manager.base_enemy_count = base_enemy_count
	spawn_manager.enemy_count_increase = enemy_count_increase
	spawn_manager.base_wave_duration = base_wave_duration
	spawn_manager.spawn_interval = spawn_interval
	
	# Set enemy scene
	if debug_enemy_scene:
		spawn_manager.debug_enemy_scene = debug_enemy_scene
	
	# Apply world visual theme
	_apply_world_theme()
	
	# Call world-specific configuration
	_configure_spawn_manager()
	
	Loggie.debug("World: Spawn manager configured with exported properties")

## Validate that the world has required components
func _validate_world_structure() -> void:
	# Add validation logic here as needed
	# For example: check for required child nodes, validate configuration, etc.
	if world_id.is_empty():
		push_error("World: world_id cannot be empty")
	
	if world_name.is_empty():
		world_name = "World " + world_id

## Apply world visual theme
func _apply_world_theme() -> void:
	Loggie.debug("World: Applying visual theme for ", world_name, " with color ", world_theme_color)
	
	# TODO: Apply lighting, fog, and other visual effects
	# This could be expanded to modify CanvasLayer, Environment, etc.
	# For now, just store the theme color for other systems to use
	set_meta("theme_color", world_theme_color)
