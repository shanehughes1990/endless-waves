extends Node2D
class_name World

## Base class for all game worlds.
##
## Provides common functionality, type safety, and standardized interface
## for world management. All world scenes should extend from this class.

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

# World state
var is_initialized: bool = false
var is_active: bool = false
var start_time: float = 0.0

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
		"difficulty_multiplier": difficulty_multiplier,
		"coin_multiplier": coin_multiplier
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

# Private methods

## Base world setup - called during initialization
func _setup_world() -> void:
	# Apply world multipliers to WorldManager
	if WorldManager:
		WorldManager.apply_world_modifiers(difficulty_multiplier, coin_multiplier)
	
	# Set up any common world elements here
	_validate_world_structure()

## Validate that the world has required components
func _validate_world_structure() -> void:
	# Add validation logic here as needed
	# For example: check for required child nodes, validate configuration, etc.
	if world_id.is_empty():
		push_error("World: world_id cannot be empty")
	
	if world_name.is_empty():
		world_name = "World " + world_id
