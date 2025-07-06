extends Node2D
class_name Enemy

## Base class for all enemies in the game.
##
## Provides the foundation for enemy classification, stats, and behavior.
## All specific enemy types should extend from this class.

# Enemy classification enums
enum Rank {
	RANK_1,
	RANK_2, 
	RANK_3,
	RANK_4,
	RANK_5
}

enum EnemyType {
	GROUND,
	AIR
}

# Signals for enemy lifecycle events
signal enemy_died(enemy: Enemy)
signal enemy_reached_base(enemy: Enemy)
signal enemy_spawned(enemy: Enemy)

# Enemy classification properties
@export var rank: Rank = Rank.RANK_1
@export var enemy_type: EnemyType = EnemyType.GROUND
@export var is_special: bool = false
@export var is_boss: bool = false

# Special/Boss multipliers (configurable)
@export var special_multiplier: float = 1.5
@export var boss_multiplier: float = 2.5

# Coin reward properties
@export var base_coin_reward: int = 1
@export var special_coin_bonus: int = 2
@export var boss_coin_bonus: int = 10

# Base stats - these will be applied to components
@export_group("Base Stats")
@export var base_health: int = 100
@export var base_movement_speed: float = 50.0
@export var base_attack_rate: float = 2.0
@export var base_attack_range: float = 200.0
@export var base_projectile_count: int = 1

# References to components - these are required
@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent  
@onready var attack_component: AttackComponent = $AttackComponent
@onready var collision_area: Area2D = $CollisionArea

# Enemy state
var has_reached_base: bool = false
var spawn_manager_ref: SpawnManager = null

func _ready() -> void:
	# Add to enemies group for targeting
	add_to_group("enemies")
	
	# Validate that all required components are present
	_validate_components()
	
	# Apply stat multipliers based on special/boss flags
	_apply_stat_multipliers()
	
	# Connect component signals
	_connect_component_signals()
	
	# Connect collision signal
	_connect_collision_signals()
	
	# Initialize movement toward base
	_setup_movement()
	
	# Emit spawned signal
	enemy_spawned.emit(self)
	
	print_debug("Enemy spawned: ", _get_enemy_description())

## Validate that all required components exist
func _validate_components() -> void:
	if not movement_component:
		push_error("Enemy: MovementComponent is required but not found!")
	if not health_component:
		push_error("Enemy: HealthComponent is required but not found!")
	if not attack_component:
		push_error("Enemy: AttackComponent is required but not found!")

## Apply stat multipliers for special/boss enemies
func _apply_stat_multipliers() -> void:
	var multiplier = 1.0
	
	if is_special:
		multiplier *= special_multiplier
	
	if is_boss:
		multiplier *= boss_multiplier
	
	# Apply multiplier to health component
	if health_component and multiplier > 1.0:
		var bonus_health = int(health_component.base_max_health * (multiplier - 1.0))
		health_component.apply_health_bonus(bonus_health)
		print_debug("Enemy: Applied ", multiplier, "x multiplier (+", bonus_health, " health)")

## Connect to component signals
func _connect_component_signals() -> void:
	if health_component:
		health_component.died.connect(_on_health_component_died)
		health_component.health_changed.connect(_on_health_changed)
	
	if attack_component:
		attack_component.fired.connect(_on_attack_component_fired)
	
	if movement_component:
		movement_component.state_changed.connect(_on_movement_state_changed)
		movement_component.target_reached.connect(_on_movement_target_reached)

## Connect to collision signals
func _connect_collision_signals() -> void:
	if collision_area:
		collision_area.area_entered.connect(_on_collision_area_entered)

## Set up movement toward the base
func _setup_movement() -> void:
	if not movement_component:
		return
	
	# Different movement patterns based on enemy type
	match enemy_type:
		EnemyType.GROUND:
			_setup_ground_movement()
		EnemyType.AIR:
			_setup_air_movement()

## Setup ground enemy movement (path to base)
func _setup_ground_movement() -> void:
	# Move directly to screen center (where base is located)
	var screen_center = Vector2(960, 540)  # Based on project settings
	if movement_component:
		movement_component.move_to_target(screen_center)

## Setup air enemy movement (direct line to base)
func _setup_air_movement() -> void:
	# Air enemies fly directly to base (same as ground for now)
	var screen_center = Vector2(960, 540)
	if movement_component:
		movement_component.move_to_target(screen_center)

## Called when health component reports death
func _on_health_component_died() -> void:
	print_debug("Enemy died: ", _get_enemy_description())
	
	# Calculate and award coins
	_award_coins()
	
	# Stop movement when dead
	if movement_component:
		movement_component.stop_movement()
	
	# Notify spawn manager
	if spawn_manager_ref:
		spawn_manager_ref._on_enemy_died(self)
	
	# Emit death signal
	enemy_died.emit(self)
	
	# TODO: Add death effects, cleanup, etc.
	queue_free()

## Called when health changes
func _on_health_changed(current_health: int) -> void:
	# TODO: Update health bar, trigger hurt effects, etc.
	pass

## Called when attack component fires
func _on_attack_component_fired(_projectile: Node) -> void:
	print_debug("Enemy fired: ", _get_enemy_description())
	# TODO: Add firing effects, sounds, etc.

## Called when movement state changes
func _on_movement_state_changed(old_state: String, new_state: String) -> void:
	print_debug("Enemy movement: ", old_state, " -> ", new_state)

## Called when movement target is reached
func _on_movement_target_reached() -> void:
	if not has_reached_base:
		has_reached_base = true
		print_debug("Enemy reached base: ", _get_enemy_description())
		
		# Stop movement and start attacking base
		if movement_component:
			movement_component.stop_movement()
		
		# TODO: Switch to attack mode against base
		
		# Emit reached base signal
		enemy_reached_base.emit(self)

## Called when enemy collides with the base
func _on_collision_area_entered(area: Area2D) -> void:
	# Check if we collided with the base
	var base_node = area.get_parent()
	if base_node and base_node.get_script() and base_node.get_script().get_global_name() == "Base":
		print_debug("Enemy collided with base: ", _get_enemy_description())
		
		# Stop movement immediately by switching to idle state
		if movement_component:
			movement_component.stop_movement()  # This should switch to idle
		
		# Mark as reached base if not already
		if not has_reached_base:
			has_reached_base = true
			enemy_reached_base.emit(self)

## Calculate and award coins for killing this enemy
func _award_coins() -> void:
	var coin_reward = base_coin_reward
	
	if is_special:
		coin_reward += special_coin_bonus
	
	if is_boss:
		coin_reward += boss_coin_bonus
	
	# Award coins through WorldManager
	var world_manager = get_node_or_null("/root/WorldManager")
	if world_manager and world_manager.has_method("add_coins"):
		world_manager.add_coins(coin_reward)
		print_debug("Enemy awarded ", coin_reward, " coins")

## Set reference to spawn manager (called by SpawnManager when spawning)
func set_spawn_manager(manager: SpawnManager) -> void:
	spawn_manager_ref = manager

## Get enemy description for debugging
func _get_enemy_description() -> String:
	var desc = "Rank " + str(rank + 1) + " " + EnemyType.keys()[enemy_type]
	if is_special:
		desc += " SPECIAL"
	if is_boss:
		desc += " BOSS"
	return desc

## Get total effective multiplier for this enemy
func get_effective_multiplier() -> float:
	var multiplier = 1.0
	if is_special:
		multiplier *= special_multiplier
	if is_boss:
		multiplier *= boss_multiplier
	return multiplier

## Get coin reward for this enemy
func get_coin_reward() -> int:
	var reward = base_coin_reward
	if is_special:
		reward += special_coin_bonus
	if is_boss:
		reward += boss_coin_bonus
	return reward

# Virtual methods for child classes to override

## Override in child classes for enemy-specific initialization
func _on_enemy_initialize() -> void:
	pass

## Override in child classes for special abilities (boss enemies)
func _activate_special_ability() -> void:
	pass

## Override in child classes for custom death behavior
func _on_enemy_death() -> void:
	pass
