extends StaticBody2D
class_name Base

# Combat System - Exportable Variables
@export_group("Weapon Stats")
@export var attack_damage: float = 25.0
@export var attack_speed: float = 2.0  # Attacks per second
@export var attack_range: float = 300.0
@export var projectile_speed: float = 600.0
@export var projectile_pierce: int = 0  # Number of enemies projectile can pierce through
@export var projectile_range: float = 800.0

@export_group("Targeting")
@export var auto_target: bool = true
@export var target_priority: TargetPriority = TargetPriority.NEAREST
@export var multi_target: bool = false  # Can target multiple enemies at once
@export var max_targets: int = 1  # Maximum simultaneous targets

@export_group("Visual Effects")
@export var muzzle_flash: bool = true
@export var projectile_color: Color = Color.YELLOW
@export var fire_sound: bool = true

# Enums
enum TargetPriority {
	NEAREST,
	FURTHEST,
	LOWEST_HEALTH,
	HIGHEST_HEALTH,
	FIRST_IN_RANGE
}

# Components
@onready var health_component: HealthComponent = $HealthComponent
@onready var upgrades_component: UpgradesComponent = $UpgradesComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var targeting_area: Area2D = $TargetingArea
@onready var targeting_collision: CollisionShape2D = $TargetingArea/CollisionShape2D
@onready var muzzle_point: Marker2D = $MuzzlePoint

# Combat State
var current_targets: Array[Node2D] = []
var enemies_in_range: Array[Node2D] = []
var last_attack_time: float = 0.0
var projectile_scene: PackedScene
var can_fire: bool = true

# Debug
var debug_draw_range: bool = false

func _ready() -> void:
	# Center the base on screen
	var viewport_size = get_viewport().get_visible_rect().size
	global_position = viewport_size / 2
	
	# Load the Godot icon
	sprite.texture = load("res://icon.svg")
	
	# Load projectile scene
	projectile_scene = load("res://scenes/weapons/Projectile.tscn")
	
	# Setup attack timer
	_setup_attack_timer()
	
	# Setup targeting area
	_setup_targeting_system()
	
	# Connect signals
	_connect_signals()
	
	print("Base: Combat system initialized - Damage: %.0f, Speed: %.1f/s, Range: %.0f" % [attack_damage, attack_speed, attack_range])

func _setup_attack_timer() -> void:
	if not attack_timer:
		# Create timer if it doesn't exist
		attack_timer = Timer.new()
		add_child(attack_timer)
	
	attack_timer.wait_time = 1.0 / attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()

func _setup_targeting_system() -> void:
	if not targeting_area:
		# Create targeting area if it doesn't exist
		targeting_area = Area2D.new()
		add_child(targeting_area)
		
		targeting_collision = CollisionShape2D.new()
		targeting_area.add_child(targeting_collision)
		
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = attack_range
		targeting_collision.shape = circle_shape
	
	# Configure targeting area
	targeting_area.collision_layer = 0  # Don't collide with anything
	targeting_area.collision_mask = 2   # Detect enemies (layer 2)
	targeting_area.monitoring = true
	targeting_area.monitorable = false
	
	# Update range
	if targeting_collision and targeting_collision.shape:
		(targeting_collision.shape as CircleShape2D).radius = attack_range
	
	if not muzzle_point:
		# Create muzzle point for projectile spawning
		muzzle_point = Marker2D.new()
		muzzle_point.position = Vector2(50, 0)  # Offset from center
		add_child(muzzle_point)

func _connect_signals() -> void:
	if targeting_area:
		targeting_area.body_entered.connect(_on_enemy_entered_range)
		targeting_area.body_exited.connect(_on_enemy_exited_range)

func _process(delta: float) -> void:
	if auto_target:
		_update_targeting()

func _draw() -> void:
	if debug_draw_range:
		# Draw attack range
		draw_arc(Vector2.ZERO, attack_range, 0, TAU, 64, Color.RED, 2.0)
		
		# Draw lines to current targets
		for target in current_targets:
			if is_instance_valid(target):
				var target_pos = to_local(target.global_position)
				draw_line(Vector2.ZERO, target_pos, Color.YELLOW, 2.0)

func _update_targeting() -> void:
	# Clean up invalid enemies
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy))
	
	if enemies_in_range.is_empty():
		current_targets.clear()
		return
	
	# Select targets based on priority
	current_targets = _select_targets(enemies_in_range)

func _select_targets(available_enemies: Array[Node2D]) -> Array[Node2D]:
	if available_enemies.is_empty():
		return []
	
	# Sort enemies based on target priority
	var sorted_enemies = available_enemies.duplicate()
	
	match target_priority:
		TargetPriority.NEAREST:
			sorted_enemies.sort_custom(_compare_by_distance_asc)
		TargetPriority.FURTHEST:
			sorted_enemies.sort_custom(_compare_by_distance_desc)
		TargetPriority.LOWEST_HEALTH:
			sorted_enemies.sort_custom(_compare_by_health_asc)
		TargetPriority.HIGHEST_HEALTH:
			sorted_enemies.sort_custom(_compare_by_health_desc)
		TargetPriority.FIRST_IN_RANGE:
			# Keep original order
			pass
	
	# Return appropriate number of targets
	var target_count = min(max_targets if multi_target else 1, sorted_enemies.size())
	return sorted_enemies.slice(0, target_count)

func _compare_by_distance_asc(a: Node2D, b: Node2D) -> bool:
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)

func _compare_by_distance_desc(a: Node2D, b: Node2D) -> bool:
	return global_position.distance_squared_to(a.global_position) > global_position.distance_squared_to(b.global_position)

func _compare_by_health_asc(a: Node2D, b: Node2D) -> bool:
	var health_a = _get_enemy_health(a)
	var health_b = _get_enemy_health(b)
	return health_a < health_b

func _compare_by_health_desc(a: Node2D, b: Node2D) -> bool:
	var health_a = _get_enemy_health(a)
	var health_b = _get_enemy_health(b)
	return health_a > health_b

func _get_enemy_health(enemy: Node2D) -> float:
	if enemy.has_method("get_component"):
		var health_comp = enemy.get_component("HealthComponent")
		if health_comp:
			return health_comp.current_health
	elif enemy.has_node("HealthComponent"):
		return enemy.get_node("HealthComponent").current_health
	return 100.0  # Default health value

func _on_attack_timer_timeout() -> void:
	if can_fire and not current_targets.is_empty():
		_perform_attack()
		
		# Update timer rate if attack speed changed
		var new_wait_time = 1.0 / attack_speed
		if abs(attack_timer.wait_time - new_wait_time) > 0.01:
			attack_timer.wait_time = new_wait_time

func _perform_attack() -> void:
	# Attack all current targets
	for target in current_targets:
		if is_instance_valid(target):
			_fire_projectile_at_target(target)
			
			if muzzle_flash:
				_create_muzzle_flash()
				
			if fire_sound:
				_play_fire_sound()
	
	print("Base: Fired at %d target(s)" % current_targets.size())

func _fire_projectile_at_target(target: Node2D) -> void:
	if not projectile_scene:
		print("Base: No projectile scene loaded!")
		return
	
	if not is_inside_tree():
		print("Base: Cannot fire - not in scene tree")
		return
	
	# Create projectile
	var projectile = projectile_scene.instantiate() as Projectile
	if not projectile:
		print("Base: Failed to create projectile!")
		return
	
	# Safely get the current scene
	var current_scene = get_tree().current_scene
	if not current_scene:
		print("Base: No current scene available")
		projectile.queue_free()
		return
	
	# Add to scene
	current_scene.add_child(projectile)
	
	# Calculate firing direction
	var start_pos = muzzle_point.global_position if muzzle_point else global_position
	var direction = (target.global_position - start_pos).normalized()
	
	# Initialize projectile
	projectile.initialize(start_pos, direction, projectile_speed, attack_damage)
	projectile.set_pierce_count(projectile_pierce)
	projectile.set_max_range(projectile_range)
	
	# Set projectile color
	if projectile.sprite:
		projectile.sprite.modulate = projectile_color

func _create_muzzle_flash() -> void:
	# Simple muzzle flash effect
	# TODO: Add particle effects or animated sprite
	print("Base: Muzzle flash!")

func _play_fire_sound() -> void:
	# TODO: Add audio system
	print("Base: Fire sound!")

func _on_enemy_entered_range(body: Node2D) -> void:
	if body.is_in_group("enemies") or body is Monster:
		if not enemies_in_range.has(body):
			enemies_in_range.append(body)
			print("Base: Enemy entered range - %s" % body.name)

func _on_enemy_exited_range(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)
		if body in current_targets:
			current_targets.erase(body)
		print("Base: Enemy exited range - %s" % body.name)

# Public interface for upgrades
func upgrade_damage(amount: float) -> void:
	attack_damage += amount
	print("Base: Damage upgraded to %.0f" % attack_damage)

func upgrade_attack_speed(amount: float) -> void:
	attack_speed += amount
	if attack_timer:
		attack_timer.wait_time = 1.0 / attack_speed
	print("Base: Attack speed upgraded to %.1f/s" % attack_speed)

func upgrade_range(amount: float) -> void:
	attack_range += amount
	if targeting_collision and targeting_collision.shape:
		(targeting_collision.shape as CircleShape2D).radius = attack_range
	queue_redraw()  # Update debug drawing
	print("Base: Range upgraded to %.0f" % attack_range)

func upgrade_projectile_speed(amount: float) -> void:
	projectile_speed += amount
	print("Base: Projectile speed upgraded to %.0f" % projectile_speed)

func upgrade_pierce(amount: int) -> void:
	projectile_pierce += amount
	print("Base: Pierce upgraded to %d" % projectile_pierce)

# Targeting controls
func set_target_priority(priority: TargetPriority) -> void:
	target_priority = priority
	print("Base: Target priority changed to %s" % TargetPriority.keys()[priority])

func toggle_multi_target(enabled: bool) -> void:
	multi_target = enabled
	print("Base: Multi-target %s" % ("enabled" if enabled else "disabled"))

func set_max_targets(count: int) -> void:
	max_targets = max(1, count)
	print("Base: Max targets set to %d" % max_targets)

# Combat controls
func set_auto_fire(enabled: bool) -> void:
	auto_target = enabled
	if not enabled:
		current_targets.clear()
	print("Base: Auto-fire %s" % ("enabled" if enabled else "disabled"))

# Debug functions
func toggle_debug_draw() -> void:
	debug_draw_range = not debug_draw_range
	queue_redraw()

func get_debug_info() -> Dictionary:
	return {
		"health": {
			"current": health_component.current_health,
			"max": health_component.max_health,
			"percentage": health_component.get_health_percentage()
		},
		"upgrades": upgrades_component.get_all_upgrades(),
		"combat": {
			"damage": attack_damage,
			"attack_speed": attack_speed,
			"range": attack_range,
			"projectile_speed": projectile_speed,
			"pierce": projectile_pierce,
			"enemies_in_range": enemies_in_range.size(),
			"current_targets": current_targets.size(),
			"auto_target": auto_target,
			"target_priority": TargetPriority.keys()[target_priority]
		}
	}
