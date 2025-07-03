extends Node
class_name SpawningSystem

# Wave Configuration
@export_group("Wave Settings")
@export var waves_enabled: bool = true
@export var auto_start_waves: bool = false  # If false, waves must be started manually
@export var current_wave: int = 1
@export var enemies_per_wave_base: int = 5
@export var enemies_per_wave_multiplier: float = 1.2  # Each wave increases by this multiplier
@export var wave_delay: float = 10.0  # Seconds between waves
@export var first_wave_delay: float = 0.0  # Delay before first wave (0 for debug)
@export var max_waves: int = 100

# Spawn Configuration
@export_group("Spawn Settings")
@export var spawn_rate: float = 2.0  # Enemies per second during active wave
@export var spawn_buffer_distance: float = 200.0  # Additional distance beyond screen edge
@export var use_viewport_based_spawning: bool = true  # If true, spawns based on screen size
@export var manual_spawn_distance_min: float = 600.0  # Fallback distances when viewport unavailable
@export var manual_spawn_distance_max: float = 800.0  # Fallback distances when viewport unavailable
@export var spawn_sides_count: int = 8  # Number of potential spawn directions (8 = all around)

# Debug Configuration
@export_group("Debug Spawning")
@export var debug_spawn_enabled: bool = true
@export var manual_spawn_uses_wave_system: bool = false  # If true, manual spawns count toward wave

# References
var world_manager: WorldSceneManager
var base: Base
var monster_scene = preload("res://scenes/entities/enemies/MonsterDebug.tscn")

# Wave State
var current_wave_enemies_spawned: int = 0
var current_wave_enemies_total: int = 0
var current_wave_enemies_remaining: int = 0
var wave_active: bool = false
var wave_complete: bool = false
var spawn_timer: float = 0.0
var wave_delay_timer: float = 0.0

# Signals
signal wave_started(wave_number: int, enemy_count: int)
signal wave_completed(wave_number: int)
signal enemy_spawned_from_wave(monster: Monster, wave_number: int)
signal all_waves_completed()

func _ready() -> void:
	print("SpawningSystem: Initialized")

func initialize(world_mgr: WorldSceneManager, base_ref: Base) -> void:
	world_manager = world_mgr
	base = base_ref
	
	if waves_enabled:
		_calculate_wave_enemies()
		if auto_start_waves:
			_start_wave_delay()
			print("SpawningSystem: Auto-starting wave system - Wave %d will have %d enemies" % [current_wave, current_wave_enemies_total])
		else:
			# Set up for manual starting
			wave_active = false
			wave_complete = false
			print("SpawningSystem: Wave system ready - Press SPACE to start Wave %d (%d enemies)" % [current_wave, current_wave_enemies_total])
	else:
		print("SpawningSystem: Wave system disabled")

func _process(delta: float) -> void:
	if not waves_enabled or not base:
		return
	
	if wave_active:
		_handle_active_wave(delta)
	elif not wave_complete and auto_start_waves:
		# Only handle wave delay if auto_start is enabled
		_handle_wave_delay(delta)

func _handle_active_wave(delta: float) -> void:
	spawn_timer += delta
	
	# Check if we should spawn an enemy
	var spawn_interval = 1.0 / spawn_rate  # Convert rate to interval
	if spawn_timer >= spawn_interval and current_wave_enemies_spawned < current_wave_enemies_total:
		spawn_timer = 0.0
		_spawn_wave_enemy()
	
	# Check if wave is complete (all enemies spawned and killed)
	if current_wave_enemies_spawned >= current_wave_enemies_total:
		if _all_wave_enemies_defeated():
			_complete_wave()

func _handle_wave_delay(delta: float) -> void:
	wave_delay_timer += delta
	
	# Use appropriate delay time
	var delay_time = first_wave_delay if current_wave == 1 else wave_delay
	if wave_delay_timer >= delay_time:
		_start_next_wave()

func _calculate_wave_enemies() -> void:
	current_wave_enemies_total = int(enemies_per_wave_base * pow(enemies_per_wave_multiplier, current_wave - 1))
	current_wave_enemies_spawned = 0
	current_wave_enemies_remaining = current_wave_enemies_total

func _start_wave_delay() -> void:
	wave_active = false
	wave_complete = false
	wave_delay_timer = 0.0
	
	# Use first_wave_delay for wave 1, normal wave_delay for others
	var delay_time = first_wave_delay if current_wave == 1 else wave_delay
	print("SpawningSystem: Wave %d delay started (%.1fs)" % [current_wave, delay_time])

func _start_next_wave() -> void:
	if current_wave > max_waves:
		_complete_all_waves()
		return
	
	wave_active = true
	wave_complete = false
	spawn_timer = 0.0
	
	wave_started.emit(current_wave, current_wave_enemies_total)
	print("SpawningSystem: Wave %d started! Spawning %d enemies at %.1f enemies/sec" % [current_wave, current_wave_enemies_total, spawn_rate])

func _spawn_wave_enemy() -> void:
	var monster = _create_and_position_monster()
	if monster:
		current_wave_enemies_spawned += 1
		current_wave_enemies_remaining = current_wave_enemies_total - current_wave_enemies_spawned
		
		# Connect to death signal to track when wave is complete
		if monster.has_signal("died"):
			monster.died.connect(_on_wave_enemy_died)
		
		enemy_spawned_from_wave.emit(monster, current_wave)
		print("SpawningSystem: Wave %d - Spawned enemy %d/%d" % [current_wave, current_wave_enemies_spawned, current_wave_enemies_total])

func _create_and_position_monster() -> Monster:
	var monster = monster_scene.instantiate()
	
	# Calculate spawn position from random side
	var spawn_position = _get_random_spawn_position()
	monster.global_position = spawn_position
	
	# Ensure monster targets the base for movement
	if monster.has_method("set_target"):
		monster.set_target(base)
	elif monster.has_method("set_target_position"):
		monster.set_target_position(base.global_position)
	
	# Add to GameLayer for proper layering
	if world_manager:
		var game_layer = world_manager.get_node_or_null("../GameLayer")
		if game_layer:
			game_layer.add_child(monster)
		else:
			# Fallback to parent if GameLayer not found
			world_manager.get_parent().add_child(monster)
		world_manager.add_enemy_to_tracking(monster)
	
	return monster

func _get_random_spawn_position() -> Vector2:
	if not base:
		return Vector2.ZERO
	
	# EXTREMELY far spawn for testing
	var spawn_distance = 10000.0  # 10,000 pixels - absolutely massive distance
	var angle = randf() * TAU
	
	var spawn_position = base.global_position + Vector2(
		cos(angle) * spawn_distance,
		sin(angle) * spawn_distance
	)
	
	push_warning("=== SPAWN DEBUG ===")
	push_warning("Base position: %s" % base.global_position)
	push_warning("Spawn position: %s" % spawn_position)
	push_warning("Distance from base: %.0f pixels" % spawn_distance)
	push_warning("Camera position: %s" % (world_manager.camera.global_position if world_manager.camera else "No camera"))
	push_warning("Camera zoom: %s" % (world_manager.camera.zoom if world_manager.camera else "No camera"))
	push_warning("===================")
	
	return spawn_position

func _get_offscreen_spawn_position() -> Vector2:
	# Get viewport size and camera position
	var viewport = world_manager.get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	var camera_pos = Vector2.ZERO
	var camera_zoom = Vector2(1.0, 1.0)  # Default zoom
	
	if world_manager.camera:
		camera_pos = world_manager.camera.global_position
		# Get the camera's zoom level
		camera_zoom = world_manager.camera.zoom
	else:
		camera_pos = base.global_position
	
	# DEBUG: Print current values
	print("DEBUG: Viewport size: %s" % viewport_size)
	print("DEBUG: Camera position: %s" % camera_pos)
	print("DEBUG: Camera zoom: %s" % camera_zoom)
	print("DEBUG: Base position: %s" % base.global_position)
	
	# Calculate the ACTUAL screen bounds accounting for camera zoom
	# When zoom is less than 1.0, the camera sees a larger area
	var actual_width = viewport_size.x / camera_zoom.x
	var actual_height = viewport_size.y / camera_zoom.y
	var half_width = actual_width / 2.0
	var half_height = actual_height / 2.0
	
	print("DEBUG: Actual view size (accounting for zoom): %.0f x %.0f" % [actual_width, actual_height])
	
	# Calculate the actual screen edges
	var screen_left = camera_pos.x - half_width
	var screen_right = camera_pos.x + half_width
	var screen_top = camera_pos.y - half_height
	var screen_bottom = camera_pos.y + half_height
	
	print("DEBUG: REAL Screen bounds - Left: %.0f, Right: %.0f, Top: %.0f, Bottom: %.0f" % [screen_left, screen_right, screen_top, screen_bottom])
	
	# Use a reasonable buffer now that we have the correct screen size
	var buffer = 300.0
	
	# Calculate spawn boundaries (screen edge + buffer distance)
	var spawn_left = screen_left - buffer
	var spawn_right = screen_right + buffer
	var spawn_top = screen_top - buffer
	var spawn_bottom = screen_bottom + buffer
	
	print("DEBUG: Spawn bounds - Left: %.0f, Right: %.0f, Top: %.0f, Bottom: %.0f" % [spawn_left, spawn_right, spawn_top, spawn_bottom])
	
	# Choose random side (0=top, 1=right, 2=bottom, 3=left)
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match side:
		0: # Top - spawn above screen
			spawn_pos.x = randf_range(spawn_left, spawn_right)
			spawn_pos.y = spawn_top
			print("DEBUG: Spawning from TOP side")
		1: # Right - spawn to the right of screen
			spawn_pos.x = spawn_right
			spawn_pos.y = randf_range(spawn_top, spawn_bottom)
			print("DEBUG: Spawning from RIGHT side")
		2: # Bottom - spawn below screen
			spawn_pos.x = randf_range(spawn_left, spawn_right)
			spawn_pos.y = spawn_bottom
			print("DEBUG: Spawning from BOTTOM side")
		3: # Left - spawn to the left of screen
			spawn_pos.x = spawn_left
			spawn_pos.y = randf_range(spawn_top, spawn_bottom)
			print("DEBUG: Spawning from LEFT side")
	
	print("DEBUG: Final spawn position: %s" % spawn_pos)
	print("DEBUG: Distance from base: %.0f" % base.global_position.distance_to(spawn_pos))
	
	return spawn_pos

func _calculate_distance_from_screen_edge(spawn_pos: Vector2, camera_pos: Vector2, viewport_size: Vector2) -> float:
	# Calculate minimum distance from spawn position to screen edge
	var half_width = viewport_size.x / 2.0
	var half_height = viewport_size.y / 2.0
	
	var screen_left = camera_pos.x - half_width
	var screen_right = camera_pos.x + half_width
	var screen_top = camera_pos.y - half_height
	var screen_bottom = camera_pos.y + half_height
	
	# Calculate distances to each edge
	var dist_to_left = abs(spawn_pos.x - screen_left)
	var dist_to_right = abs(spawn_pos.x - screen_right)
	var dist_to_top = abs(spawn_pos.y - screen_top)
	var dist_to_bottom = abs(spawn_pos.y - screen_bottom)
	
	# Return minimum distance (closest edge)
	return min(min(dist_to_left, dist_to_right), min(dist_to_top, dist_to_bottom))

func _get_manual_spawn_position() -> Vector2:
	# Fallback to original circular spawning
	var spawn_distance = randf_range(manual_spawn_distance_min, manual_spawn_distance_max)
	var angle = randf() * TAU
	
	var spawn_position = base.global_position + Vector2(
		cos(angle) * spawn_distance,
		sin(angle) * spawn_distance
	)
	
	return spawn_position

func _all_wave_enemies_defeated() -> bool:
	if not world_manager:
		return true
	
	# Check if any enemies from this wave are still alive
	var alive_enemies = world_manager.get_enemies()
	return alive_enemies.size() == 0

func _on_wave_enemy_died(monster: Monster) -> void:
	# Enemy died, check if wave is complete
	if current_wave_enemies_spawned >= current_wave_enemies_total and _all_wave_enemies_defeated():
		_complete_wave()

func _complete_wave() -> void:
	wave_active = false
	wave_complete = true
	
	wave_completed.emit(current_wave)
	print("SpawningSystem: Wave %d completed!" % current_wave)
	
	# Prepare next wave
	current_wave += 1
	if current_wave <= max_waves:
		_calculate_wave_enemies()
		_start_wave_delay()
	else:
		_complete_all_waves()

func _complete_all_waves() -> void:
	waves_enabled = false
	all_waves_completed.emit()
	print("SpawningSystem: All waves completed! Player survived %d waves!" % max_waves)

# Manual/Debug spawning
func spawn_manual_enemy() -> Monster:
	if not debug_spawn_enabled:
		print("SpawningSystem: Manual spawning disabled")
		return null
	
	var monster = _create_and_position_monster()
	if monster:
		if manual_spawn_uses_wave_system and wave_active:
			# Count this toward current wave
			current_wave_enemies_spawned += 1
			current_wave_enemies_remaining = current_wave_enemies_total - current_wave_enemies_spawned
			if monster.has_signal("died"):
				monster.died.connect(_on_wave_enemy_died)
			enemy_spawned_from_wave.emit(monster, current_wave)
			print("SpawningSystem: Manual spawn added to wave %d (%d/%d)" % [current_wave, current_wave_enemies_spawned, current_wave_enemies_total])
		else:
			print("SpawningSystem: Manual enemy spawned (not part of wave)")
	
	return monster

# Control functions
func start_waves() -> void:
	if not waves_enabled:
		waves_enabled = true
		current_wave = 1
		_calculate_wave_enemies()
		_start_wave_delay()
		print("SpawningSystem: Wave system manually started")

func start_current_wave() -> void:
	"""Start the current wave immediately (used for manual wave triggering)"""
	print("SpawningSystem: start_current_wave called - waves_enabled=%s, wave_active=%s, wave_complete=%s" % [waves_enabled, wave_active, wave_complete])
	
	if not waves_enabled:
		# Enable waves and start first wave
		waves_enabled = true
		current_wave = 1
		_calculate_wave_enemies()
		wave_active = false
		wave_complete = false
		_start_next_wave()
		print("SpawningSystem: Wave system enabled and Wave %d started manually!" % current_wave)
	elif waves_enabled and not wave_active and not wave_complete:
		# System is waiting for wave start
		_start_next_wave()
		print("SpawningSystem: Wave %d started manually!" % current_wave)
	elif wave_active:
		print("SpawningSystem: Wave %d already active!" % current_wave)
	elif wave_complete:
		# Move to next wave
		current_wave += 1
		if current_wave <= max_waves:
			_calculate_wave_enemies()
			wave_complete = false
			_start_next_wave()
			print("SpawningSystem: Next wave %d started manually!" % current_wave)
		else:
			print("SpawningSystem: All waves completed!")
	else:
		print("SpawningSystem: Cannot start wave - wave system in invalid state")

func stop_waves() -> void:
	waves_enabled = false
	wave_active = false
	print("SpawningSystem: Wave system stopped")

func skip_to_next_wave() -> void:
	if waves_enabled:
		_complete_wave()

func set_spawn_rate(new_rate: float) -> void:
	spawn_rate = new_rate
	print("SpawningSystem: Spawn rate changed to %.1f enemies/sec" % spawn_rate)

# Debug info
func get_wave_debug_info() -> Dictionary:
	return {
		"wave_system": {
			"enabled": waves_enabled,
			"current_wave": current_wave,
			"max_waves": max_waves,
			"wave_active": wave_active,
			"wave_complete": wave_complete
		},
		"current_wave": {
			"enemies_total": current_wave_enemies_total,
			"enemies_spawned": current_wave_enemies_spawned,
			"enemies_remaining": current_wave_enemies_remaining
		},
		"spawn_settings": {
			"rate": spawn_rate,
			"offscreen_spawning": use_viewport_based_spawning,
			"spawn_buffer_distance": spawn_buffer_distance,
			"manual_distance_min": manual_spawn_distance_min,
			"manual_distance_max": manual_spawn_distance_max
		},
		"timers": {
			"spawn_timer": spawn_timer,
			"wave_delay_timer": wave_delay_timer,
			"wave_delay_total": first_wave_delay if current_wave == 1 else wave_delay,
			"auto_start_enabled": auto_start_waves
		}
	}
