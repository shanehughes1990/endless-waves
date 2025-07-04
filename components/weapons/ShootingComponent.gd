extends Node
class_name ShootingComponent

signal projectile_fired(projectile: Node2D, target: Node2D)
signal target_acquired(target: Node2D)
signal target_lost()

# Shooting Configuration
@export_group("Weapon Settings")
@export var auto_fire_enabled: bool = true
@export var fire_rate: float = 2.0  # Shots per second
@export var projectile_damage: float = 25.0
@export var projectile_speed: float = 800.0
@export var weapon_range: float = 400.0  # Maximum shooting distance

# Targeting Configuration  
@export_group("Targeting")
@export var target_closest: bool = true  # If false, targets first enemy in range
@export var retarget_on_death: bool = true
@export var lead_target: bool = false  # Predict target movement (advanced)

# Visual Configuration
@export_group("Visual Effects")
@export var show_range_circle: bool = false  # Debug: show weapon range
@export var muzzle_flash_enabled: bool = true
@export var projectile_tracer: bool = true

# Internal State
var current_target: Node2D = null
var fire_timer: float = 0.0
var world_manager: WorldSceneManager = null

# Projectile scene
var projectile_scene = preload("res://scenes/weapons/Projectile.tscn")

func _ready() -> void:
	# Connect to world manager if available
	_find_world_manager()
	
	print("ShootingComponent: Initialized - Rate: %.1f/sec, Damage: %.0f, Range: %.0f" % [fire_rate, projectile_damage, weapon_range])

func _find_world_manager() -> void:
	# Try to find world manager in scene tree
	var current_node = get_parent()
	while current_node and not world_manager:
		if current_node.has_method("get_enemies"):
			world_manager = current_node
			break
		current_node = current_node.get_parent()
	
	if not world_manager:
		# Try alternative path
		var scene_root = get_tree().current_scene
		world_manager = scene_root.get_node_or_null("WorldSceneManager")

func _process(delta: float) -> void:
	if not auto_fire_enabled:
		return
	
	# Update fire timer
	fire_timer += delta
	
	# Find/update target
	_update_target()
	
	# Fire at target if ready
	if current_target and _can_fire():
		_fire_at_target()

func _update_target() -> void:
	# Check if current target is still valid
	if current_target and (not is_instance_valid(current_target) or not _is_in_range(current_target)):
		_lose_target()
	
	# Find new target if needed
	if not current_target:
		current_target = _find_best_target()
		if current_target:
			target_acquired.emit(current_target)
			print("ShootingComponent: Target acquired - %s" % current_target.name)

func _find_best_target() -> Node2D:
	if not world_manager:
		return null
	
	var enemies = world_manager.get_enemies()
	if enemies.is_empty():
		return null
	
	var base_position = get_parent().global_position
	var best_target = null
	var best_distance = weapon_range + 1.0  # Start beyond range
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = base_position.distance_to(enemy.global_position)
		if distance <= weapon_range:
			if target_closest:
				if distance < best_distance:
					best_distance = distance
					best_target = enemy
			else:
				# Return first valid target
				return enemy
	
	return best_target

func _is_in_range(target: Node2D) -> bool:
	if not is_instance_valid(target):
		return false
	
	var distance = get_parent().global_position.distance_to(target.global_position)
	return distance <= weapon_range

func _can_fire() -> bool:
	var fire_interval = 1.0 / fire_rate
	return fire_timer >= fire_interval

func _fire_at_target() -> void:
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Reset fire timer
	fire_timer = 0.0
	
	# Calculate projectile spawn position (from base center)
	var base_position = get_parent().global_position
	var target_position = current_target.global_position
	
	# Predict target movement if enabled
	if lead_target and current_target.has_method("get_velocity"):
		target_position = _predict_target_position(target_position)
	
	# Create projectile
	var projectile = _create_projectile(base_position, target_position)
	if projectile:
		projectile_fired.emit(projectile, current_target)
		print("ShootingComponent: Fired at %s (distance: %.0f)" % [current_target.name, base_position.distance_to(target_position)])

func _predict_target_position(current_pos: Vector2) -> Vector2:
	# Simple lead calculation - predict where target will be
	if not current_target.has_method("get_velocity"):
		return current_pos
	
	var target_velocity = current_target.velocity if current_target.has_method("get_velocity") else Vector2.ZERO
	var distance_to_target = get_parent().global_position.distance_to(current_pos)
	var time_to_impact = distance_to_target / projectile_speed
	
	return current_pos + (target_velocity * time_to_impact)

func _create_projectile(start_pos: Vector2, target_pos: Vector2) -> Node2D:
	# Create projectile instance
	var projectile = projectile_scene.instantiate()
	
	# Set projectile properties
	if projectile.has_method("initialize"):
		var direction = (target_pos - start_pos).normalized()
		projectile.initialize(start_pos, direction, projectile_speed, projectile_damage)
	
	# Add to scene (try GameLayer first, then parent)
	var game_layer = get_tree().current_scene.get_node_or_null("GameLayer")
	if game_layer:
		game_layer.add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
	
	return projectile

func _lose_target() -> void:
	if current_target:
		print("ShootingComponent: Lost target - %s" % current_target.name)
		current_target = null
		target_lost.emit()

# Public interface
func set_fire_rate(new_rate: float) -> void:
	fire_rate = new_rate
	print("ShootingComponent: Fire rate changed to %.1f/sec" % fire_rate)

func set_damage(new_damage: float) -> void:
	projectile_damage = new_damage
	print("ShootingComponent: Damage changed to %.0f" % projectile_damage)

func set_range(new_range: float) -> void:
	weapon_range = new_range
	print("ShootingComponent: Range changed to %.0f" % weapon_range)

func enable_auto_fire(enabled: bool) -> void:
	auto_fire_enabled = enabled
	if not enabled:
		_lose_target()
	print("ShootingComponent: Auto-fire %s" % ("enabled" if enabled else "disabled"))

func force_retarget() -> void:
	_lose_target()
	print("ShootingComponent: Forced retarget")

# Debug info
func get_shooting_debug_info() -> Dictionary:
	return {
		"auto_fire_enabled": auto_fire_enabled,
		"fire_rate": fire_rate,
		"damage": projectile_damage,
		"speed": projectile_speed,
		"range": weapon_range,
		"current_target": current_target.name if current_target else "None",
		"fire_timer": fire_timer,
		"can_fire": _can_fire()
	}
