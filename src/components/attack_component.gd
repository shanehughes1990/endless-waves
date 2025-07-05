extends Node
class_name AttackComponent

## Manages firing projectiles at targets.

# Signal emitted when the component fires.
signal fired(projectile)

# The scene for the projectile to be fired.
@export var projectile_scene: PackedScene

# The time in seconds between each shot.
@export var fire_rate: float = 1.0

# The distance the component can detect targets.
@export var attack_range: float = 300.0

# The number of projectiles to fire at once.
@export var projectile_count: int = 1

var fire_timer: Timer

func _ready() -> void:
	# Set up the timer for firing.
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false # The timer will restart automatically.
	fire_timer.autostart = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(fire_timer)

func _on_fire_timer_timeout() -> void:
	# This function is called every time the fire_timer finishes.
	var target = _find_target()
	if target:
		_fire(target)

func _find_target() -> Node2D:
	# Get all nodes in the "enemies" group
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	
	var closest_enemy: Node2D = null
	var closest_distance: float = INF
	var owner_position = get_owner().global_position
	
	for enemy in enemies:
		if not enemy is Node2D:
			continue
			
		var distance = owner_position.distance_to(enemy.global_position)
		if distance <= attack_range and distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func _fire(target: Node2D) -> void:
	if not projectile_scene:
		print_debug("AttackComponent: Projectile scene not set!")
		return

	var aim_direction = (target.global_position - get_owner().global_position).normalized()

	for i in range(projectile_count):
		var projectile = projectile_scene.instantiate()
		
		# Add the projectile to the scene tree (at the world level).
		get_tree().root.add_child(projectile)
		
		# Position the projectile at the owner's location.
		projectile.global_position = get_owner().global_position
		
		# Set the projectile's direction.
		# This assumes the projectile has a method called 'set_direction'.
		if projectile.has_method("set_direction"):
			projectile.set_direction(aim_direction)
		
		fired.emit(projectile)

# This allows the fire_rate to be updated by other scripts (e.g., upgrades).
func set_fire_rate(new_rate: float) -> void:
	fire_rate = max(0.01, new_rate) # Prevent division by zero or negative rates.
	if fire_timer:
		fire_timer.wait_time = fire_rate
