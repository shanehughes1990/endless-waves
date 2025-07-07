@tool
extends Node2D
class_name SpawnManager

## Advanced spawn manager that handles wave-based enemy spawning with milestone progression.
##
## Features:
## - Visual spawn radius (red circle) configurable in editor
## - Wave system with regular and boss waves
## - Cluster spawning at random points on circumference
## - Auto/manual wave triggers with debug controls
## - Milestone-based difficulty progression
## - Real-time enemy tracking and wave statistics

# Visual configuration
@export var spawn_radius: float = 50.0: set = _set_spawn_radius
@export var circle_color: Color = Color.RED: set = _set_circle_color
@export var circle_thickness: float = 3.0: set = _set_circle_thickness

# Wave system configuration
@export_group("Wave System")
@export var auto_start_waves: bool = false
@export var wave_delay: float = 5.0
@export var milestone_interval: int = 10  # Boss waves every N waves

# Regular wave configuration
@export_group("Regular Waves")
@export var base_enemy_count: int = 5
@export var enemy_count_increase: int = 2  # Per milestone tier
@export var base_wave_duration: float = 30.0
@export var wave_duration_increase: float = 10.0  # Extra seconds per tier
@export var spawn_interval: float = 1.0  # Time between individual spawns

# Boss wave configuration
@export_group("Boss Waves")
@export var boss_enemy_count: int = 1
@export var boss_minion_count: int = 3
@export var boss_wave_duration: float = 60.0
@export var boss_duration_increase: float = 15.0  # Extra seconds per tier

# Cluster spawning configuration
@export_group("Cluster Spawning")
@export var enable_clusters: bool = true
@export var cluster_size: int = 3  # Enemies per cluster
@export var cluster_radius: float = 20.0  # Small circle around spawn point
@export var clusters_per_wave: int = 2

# Enemy scenes to spawn
@export_group("Enemy Types")
@export var debug_enemy_scene: PackedScene = preload("res://src/actors/enemies/debug_enemy.tscn")

# Wave state tracking
var current_wave: int = 0
var is_wave_active: bool = false
var is_spawning: bool = false
var spawned_enemies: Array[Enemy] = []
var wave_timer: Timer
var spawn_timer: Timer
var delay_timer: Timer

# Wave statistics
var enemies_spawned_this_wave: int = 0
var enemies_killed_this_wave: int = 0
var total_enemies_spawned: int = 0
var total_enemies_killed: int = 0

func _ready() -> void:
	if not Engine.is_editor_hint():
		Loggie.msg("SpawnManager initialized at position: %s" % global_position).domain("SpawnMgr").debug()
		_setup_timers()
	# Force redraw in editor
	queue_redraw()

func _draw() -> void:
	# Draw a red circle to visualize the spawn point
	draw_circle(Vector2.ZERO, spawn_radius, circle_color, false, circle_thickness)
	
	# Optional: Draw a small center dot
	draw_circle(Vector2.ZERO, 3.0, circle_color, true)

# Property setters to update visualization in editor
func _set_spawn_radius(value: float) -> void:
	spawn_radius = value
	queue_redraw()

func _set_circle_color(value: Color) -> void:
	circle_color = value
	queue_redraw()

func _set_circle_thickness(value: float) -> void:
	circle_thickness = value
	queue_redraw()

# ===== WAVE SYSTEM CORE METHODS =====

## Setup timers for wave management
func _setup_timers() -> void:
	# Wave duration timer
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)
	
	# Spawn interval timer
	spawn_timer = Timer.new()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Wave delay timer
	delay_timer = Timer.new()
	delay_timer.one_shot = true
	delay_timer.timeout.connect(_on_delay_timer_timeout)
	add_child(delay_timer)

## Start a new wave
func start_wave() -> void:
	if is_wave_active:
		Loggie.msg("SpawnManager: Wave already active, cannot start new wave").domain("SpawnMgr").warn()
		return
	
	current_wave += 1
	is_wave_active = true
	is_spawning = true
	enemies_spawned_this_wave = 0
	enemies_killed_this_wave = 0
	
	Loggie.msg("SpawnManager: Starting wave %s" % current_wave).domain("SpawnMgr").info()
	
	# Determine wave type and setup
	if _is_boss_wave(current_wave):
		_start_boss_wave()
	else:
		_start_regular_wave()

## Get current wave count (alive enemies)
func get_wave_count() -> int:
	return spawned_enemies.size()

## Get wave enemies list (no-op for now)
func get_wave_enemies() -> Array:
	return []  # TODO: Implement when needed

## Check if current wave number is a boss wave
func _is_boss_wave(wave_num: int) -> bool:
	return wave_num % milestone_interval == 0

## Start a regular wave
func _start_regular_wave() -> void:
	var tier = (current_wave - 1) / milestone_interval  # 0, 1, 2, etc.
	var enemy_count = base_enemy_count + (tier * enemy_count_increase)
	var wave_duration = base_wave_duration + (tier * wave_duration_increase)
	
	Loggie.msg("SpawnManager: Regular wave %s - Tier %s - %s enemies - %ss duration" % [current_wave, tier, enemy_count, wave_duration]).domain("SpawnMgr").info()
	
	# Start wave timer with progressive duration
	wave_timer.wait_time = wave_duration
	wave_timer.start()
	
	# Start spawning enemies
	_start_spawning_enemies(enemy_count)

## Start a boss wave
func _start_boss_wave() -> void:
	var tier = (current_wave - 1) / milestone_interval  # Boss wave tier
	var total_enemies = boss_enemy_count + boss_minion_count
	var wave_duration = boss_wave_duration + (tier * boss_duration_increase)
	
	Loggie.msg("SpawnManager: Boss wave %s - Tier %s - %s boss + %s minions - %ss duration" % [current_wave, tier, boss_enemy_count, boss_minion_count, wave_duration]).domain("SpawnMgr").info()
	
	# Start wave timer with progressive duration
	wave_timer.wait_time = wave_duration
	wave_timer.start()
	
	# Start spawning enemies
	_start_spawning_enemies(total_enemies)

## Start spawning enemies with timer
func _start_spawning_enemies(count: int) -> void:
	var enemies_to_spawn = count
	
	# Setup spawn timer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()
	
	# Store count for spawning
	set_meta("enemies_to_spawn", enemies_to_spawn)

## Spawn a single enemy at random position on circumference
func _spawn_enemy() -> void:
	if not debug_enemy_scene:
		push_error("SpawnManager: No enemy scene configured")
		return
	
	# Get spawn position on circumference
	var spawn_pos = _get_random_spawn_position()
	
	# Create enemy
	var enemy = debug_enemy_scene.instantiate() as Enemy
	if not enemy:
		push_error("SpawnManager: Failed to instantiate enemy")
		return
	
	# Setup enemy
	enemy.global_position = spawn_pos
	enemy.set_spawn_manager(self)
	enemy.enemy_died.connect(_on_enemy_died)
	
	# Add to scene and track
	get_tree().current_scene.add_child(enemy)
	spawned_enemies.append(enemy)
	
	# Update statistics
	enemies_spawned_this_wave += 1
	total_enemies_spawned += 1
	
	Loggie.msg("SpawnManager: Spawned enemy at %s" % spawn_pos).domain("SpawnMgr").debug()

## Get random position on spawn circle circumference
func _get_random_spawn_position() -> Vector2:
	var angle = randf() * 2 * PI
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	return global_position + offset

## Get cluster spawn positions around a main point
func _get_cluster_spawn_positions(main_pos: Vector2, cluster_count: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	for i in range(cluster_count):
		var angle = randf() * 2 * PI
		var distance = randf() * cluster_radius
		var offset = Vector2(cos(angle), sin(angle)) * distance
		positions.append(main_pos + offset)
	
	return positions

## Called when wave timer expires
func _on_wave_timer_timeout() -> void:
	Loggie.msg("SpawnManager: Wave %s duration expired" % current_wave).domain("SpawnMgr").info()
	_end_wave()

## Called when spawn timer ticks
func _on_spawn_timer_timeout() -> void:
	if not is_spawning:
		return
	
	var enemies_to_spawn = get_meta("enemies_to_spawn", 0)
	if enemies_to_spawn > 0:
		_spawn_enemy()
		enemies_to_spawn -= 1
		set_meta("enemies_to_spawn", enemies_to_spawn)
		
		if enemies_to_spawn <= 0:
			is_spawning = false
			spawn_timer.stop()
			Loggie.msg("SpawnManager: Finished spawning all enemies for wave %s" % current_wave).domain("SpawnMgr").info()

## Called when wave delay timer expires
func _on_delay_timer_timeout() -> void:
	Loggie.msg("SpawnManager: Wave delay expired, starting next wave").domain("SpawnMgr").info()
	start_wave()

## End the current wave
func _end_wave() -> void:
	if not is_wave_active:
		return
	
	is_wave_active = false
	is_spawning = false
	spawn_timer.stop()
	
	Loggie.msg("SpawnManager: Wave %s ended" % current_wave).domain("SpawnMgr").info()
	
	# Start delay for next wave if auto mode enabled
	if auto_start_waves:
		Loggie.msg("SpawnManager: Auto-starting next wave in %s seconds" % wave_delay).domain("SpawnMgr").info()
		delay_timer.wait_time = wave_delay
		delay_timer.start()

## Called when an enemy dies
func _on_enemy_died(enemy: Enemy) -> void:
	# Remove from tracking
	spawned_enemies.erase(enemy)
	
	# Update statistics
	enemies_killed_this_wave += 1
	total_enemies_killed += 1
	
	Loggie.msg("SpawnManager: Enemy died, %s enemies remaining" % get_wave_count()).domain("SpawnMgr").debug()
	
	# Check if wave is complete (all enemies dead and no more spawning)
	if get_wave_count() == 0 and not is_spawning:
		Loggie.msg("SpawnManager: All enemies defeated, wave complete!").domain("SpawnMgr").info()
		_end_wave()
		# Start next wave immediately when all enemies are defeated
		Loggie.msg("SpawnManager: Starting next wave immediately").domain("SpawnMgr").info()
		call_deferred("start_wave")

## Get wave statistics
func get_wave_stats() -> Dictionary:
	var tier = 0
	var current_wave_duration = 0.0
	var time_remaining = 0.0
	var time_elapsed = 0.0
	
	# Calculate tier and duration info
	if current_wave > 0:
		tier = (current_wave - 1) / milestone_interval
		if _is_boss_wave(current_wave):
			current_wave_duration = boss_wave_duration + (tier * boss_duration_increase)
		else:
			current_wave_duration = base_wave_duration + (tier * wave_duration_increase)
	
	# Get timer information
	if wave_timer and is_wave_active:
		time_remaining = wave_timer.time_left
		time_elapsed = current_wave_duration - time_remaining
	
	return {
		"current_wave": current_wave,
		"current_tier": tier,
		"is_wave_active": is_wave_active,
		"is_spawning": is_spawning,
		"enemies_alive": get_wave_count(),
		"enemies_spawned_this_wave": enemies_spawned_this_wave,
		"enemies_killed_this_wave": enemies_killed_this_wave,
		"total_enemies_spawned": total_enemies_spawned,
		"total_enemies_killed": total_enemies_killed,
		"is_boss_wave": _is_boss_wave(current_wave),
		"auto_start_enabled": auto_start_waves,
		"wave_duration": current_wave_duration,
		"time_remaining": time_remaining,
		"time_elapsed": time_elapsed,
		"wave_progress": (time_elapsed / current_wave_duration) if current_wave_duration > 0 else 0.0
	}

## Reset spawn system
func reset_spawn_system() -> void:
	current_wave = 0
	is_wave_active = false
	is_spawning = false
	enemies_spawned_this_wave = 0
	enemies_killed_this_wave = 0
	total_enemies_spawned = 0
	total_enemies_killed = 0
	
	# Clear all spawned enemies
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	
	# Stop all timers
	if wave_timer:
		wave_timer.stop()
	if spawn_timer:
		spawn_timer.stop()
	if delay_timer:
		delay_timer.stop()
	
	Loggie.msg("SpawnManager: Spawn system reset").domain("SpawnMgr").info()

## Toggle auto start waves
func toggle_auto_start() -> void:
	auto_start_waves = not auto_start_waves
	Loggie.msg("SpawnManager: Auto start waves: %s" % auto_start_waves).domain("SpawnMgr").info()
