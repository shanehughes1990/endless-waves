extends Node
class_name AttackComponent

## Manages firing projectiles at targets.

# Signal emitted when the component fires.
signal fired(projectile)

# The scene for the projectile to be fired.
@export var projectile_scene: PackedScene

# The time in seconds between each shot.
@export var base_fire_rate: float = 1.0

# The distance the component can detect targets.
@export var attack_range: float = 300.0

# The number of projectiles to fire at once.
@export var projectile_count: int = 1

# Internal upgrade bonuses
var fire_rate_bonus: float = 0.0
var projectile_count_bonus: int = 0
var range_bonus: float = 0.0

var fire_timer: Timer
var effective_fire_rate: float
var effective_projectile_count: int
var effective_attack_range: float

func _ready() -> void:
	# Add to group so WorldManager can find this component
	add_to_group("attack_components")
	
	# Calculate effective stats
	_recalculate_stats()
	
	# Set up the timer for firing.
	fire_timer = Timer.new()
	fire_timer.wait_time = effective_fire_rate
	fire_timer.one_shot = false # The timer will restart automatically.
	fire_timer.autostart = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(fire_timer)

## Recalculate all effective stats based on base values + bonuses
func _recalculate_stats() -> void:
	effective_fire_rate = max(0.1, base_fire_rate - fire_rate_bonus)  # Lower is faster, minimum 0.1s
	effective_projectile_count = max(1, projectile_count + projectile_count_bonus)
	effective_attack_range = max(50.0, attack_range + range_bonus)
	
	if fire_timer:
		fire_timer.wait_time = effective_fire_rate
	
	print_debug("AttackComponent stats - Fire Rate: ", effective_fire_rate, 
		", Projectiles: ", effective_projectile_count, 
		", Range: ", effective_attack_range)

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
		if distance <= effective_attack_range and distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func _fire(target: Node2D) -> void:
	if not projectile_scene:
		print_debug("AttackComponent: Projectile scene not set!")
		return

	var aim_direction = (target.global_position - get_owner().global_position).normalized()

	for i in range(effective_projectile_count):
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
	base_fire_rate = max(0.01, new_rate) # Prevent division by zero or negative rates.
	_recalculate_stats()  # Recalculate with current bonuses

## Get the current effective fire rate
func get_effective_fire_rate() -> float:
	return effective_fire_rate

## Apply fire rate bonus (negative values make firing faster)
func apply_fire_rate_bonus(bonus: float) -> void:
	fire_rate_bonus = bonus
	_recalculate_stats()

## Apply projectile count bonus
func apply_projectile_count_bonus(bonus: int) -> void:
	projectile_count_bonus = bonus
	_recalculate_stats()

## Apply attack range bonus
func apply_range_bonus(bonus: float) -> void:
	range_bonus = bonus
	_recalculate_stats()

## Get current effective projectile count
func get_effective_projectile_count() -> int:
	return effective_projectile_count

## Get current effective attack range
func get_effective_attack_range() -> float:
	return effective_attack_range

## Reset all bonuses to zero
func reset_bonuses() -> void:
	fire_rate_bonus = 0.0
	projectile_count_bonus = 0
	range_bonus = 0.0
	_recalculate_stats()
