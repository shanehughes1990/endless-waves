extends Node

# Import the World class
const WorldBase = preload("res://src/autoload/world_manager/world.gd")

## Manages the lifecycle and state of the current world.
##
## Tracks world-level stats like coins and manages transitions between typed World instances.
## Acts as a singleton accessible throughout the game.

# Signals for world state changes
signal coins_changed(current_coins: int)
signal world_loaded(world: WorldBase)
signal world_unloaded()
signal world_started(world: WorldBase)
signal world_completed(world: WorldBase)
signal world_failed(world: WorldBase)

# World state
var current_coins: int = 0
var current_world: WorldBase = null

# Base stats that persist across world reloads
@export var starting_coins: int = 100
@export var coins_per_second: float = 1.0
@export var coin_increment_multiplier: float = 1.0

# Session upgrade bonuses (reset each session)
var session_damage_bonus: int = 0
var session_health_bonus: int = 0
var session_fire_rate_bonus: float = 0.0

# World modifiers (applied by current world)
var current_difficulty_multiplier: float = 1.0
var current_coin_multiplier: float = 1.0

# Coin generation timer
var coin_timer: Timer

# Note: spawn_manager moved to individual World instances for better encapsulation

func _ready() -> void:
	# Initialize with starting values
	current_coins = starting_coins
	Loggie.msg("WorldManager initialized with %s coins" % starting_coins).domain("WorldMgr").debug()

	# Create and configure coin generation timer
	coin_timer = Timer.new()
	coin_timer.wait_time = 1.0  # 1 second
	coin_timer.autostart = true
	coin_timer.timeout.connect(_on_coin_timer_timeout)
	add_child(coin_timer)

func _process(_delta: float) -> void:
	# Draw debug menu
	_draw_debug_menu()

func _on_coin_timer_timeout() -> void:
	# Generate coins when timer times out
	var effective_rate = coins_per_second * coin_increment_multiplier * current_coin_multiplier
	var coins_to_add = int(effective_rate)  # Convert to integer
	if coins_to_add > 0:
		add_coins(coins_to_add)

func _draw_debug_menu() -> void:
	ImGui.Begin("World Manager Debug")

	ImGui.Text("=== World Info ===")
	if current_world:
		var config = current_world.get_world_config()
		ImGui.Text("Current World: " + config.name)
		ImGui.Text("World ID: " + config.id)
		ImGui.Text("Description: " + config.description)
		ImGui.Text("World Type: " + str(current_world.get_class()))
		ImGui.Text("Active: " + str(current_world.is_active))
		ImGui.Text("Runtime: " + str("%.1f" % current_world.get_world_runtime()) + "s")
		ImGui.Text("Difficulty: x" + str(config.difficulty_multiplier))
		ImGui.Text("Coin Rate: x" + str(config.coin_multiplier))
		
		# Show spawn configuration
		ImGui.Text("Spawn Radius: " + str(config.spawn_radius))
		ImGui.Text("Auto Start: " + str(config.auto_start_waves))
		ImGui.Text("Base Enemies: " + str(config.base_enemy_count))
		ImGui.Text("Enemy Increase: " + str(config.enemy_count_increase))
	else:
		ImGui.Text("Current World: None")
	ImGui.Separator()
	
	ImGui.Text("=== Stats ===")
	ImGui.Text("Coins: " + str(current_coins))
	ImGui.Text("Starting Coins: " + str(starting_coins))
	ImGui.Text("Base Coins/Second: " + str(coins_per_second))
	ImGui.Text("Increment Multiplier: " + str(coin_increment_multiplier))
	ImGui.Text("World Coin Multiplier: " + str(current_coin_multiplier))
	var effective_rate = coins_per_second * coin_increment_multiplier * current_coin_multiplier
	ImGui.Text("Effective Rate: " + str("%.2f" % effective_rate) + "/sec")
	ImGui.Text("Next Coin in: " + str("%.1f" % coin_timer.time_left) + "s")

	ImGui.Separator()
	ImGui.Text("=== Spawn Manager ===")
	var spawn_manager = null
	if current_world:
		spawn_manager = current_world.get_spawn_manager()
	if spawn_manager:
		ImGui.Text("Status: Active")
		ImGui.Text("Position: " + str(spawn_manager.global_position))
		
		# Get wave statistics
		var stats = spawn_manager.get_wave_stats()
		ImGui.Text("Current Wave: " + str(stats.current_wave))
		ImGui.Text("Current Tier: " + str(stats.current_tier))
		ImGui.Text("Wave Active: " + str(stats.is_wave_active))
		ImGui.Text("Is Spawning: " + str(stats.is_spawning))
		ImGui.Text("Enemies Alive: " + str(stats.enemies_alive))
		ImGui.Text("Spawned This Wave: " + str(stats.enemies_spawned_this_wave))
		ImGui.Text("Killed This Wave: " + str(stats.enemies_killed_this_wave))
		ImGui.Text("Total Spawned: " + str(stats.total_enemies_spawned))
		ImGui.Text("Total Killed: " + str(stats.total_enemies_killed))
		ImGui.Text("Boss Wave: " + str(stats.is_boss_wave))
		ImGui.Text("Auto Start: " + str(stats.auto_start_enabled))
		
		# Wave Timer Information
		ImGui.Separator()
		ImGui.Text("=== Wave Timer ===")
		if stats.is_wave_active:
			ImGui.Text("Wave Duration: " + str("%.1f" % stats.wave_duration) + "s")
			ImGui.Text("Time Remaining: " + str("%.1f" % stats.time_remaining) + "s")
			ImGui.Text("Time Elapsed: " + str("%.1f" % stats.time_elapsed) + "s")
			ImGui.Text("Wave Progress: " + str("%.1f" % (stats.wave_progress * 100.0)) + "%")
			# Visual progress bar
			ImGui.ProgressBar(stats.wave_progress, Vector2(200, 0), "")
		else:
			ImGui.Text("No Active Wave")
		
		# Wave control buttons
		ImGui.Separator()
		if not stats.is_wave_active:
			if ImGui.Button("Start Wave"):
				spawn_manager.start_wave()
		else:
			ImGui.Text("Wave " + str(stats.current_wave) + " Active")
		
		ImGui.SameLine()
		if ImGui.Button("Reset System"):
			spawn_manager.reset_spawn_system()
		
		ImGui.SameLine()
		if ImGui.Button("Toggle Auto"):
			spawn_manager.toggle_auto_start()
	else:
		ImGui.Text("Status: Not Initialized")

	ImGui.Separator()
	ImGui.Text("=== Session Upgrades ===")
	ImGui.Text("Damage Bonus: +" + str(session_damage_bonus))
	ImGui.SameLine()
	if ImGui.Button("-##damage"):
		if session_damage_bonus > 0:
			add_session_upgrade("damage", -1)
	ImGui.SameLine()
	if ImGui.Button("+1##damage"):
		add_session_upgrade("damage", 1)
	ImGui.SameLine()
	if ImGui.Button("+5##damage"):
		add_session_upgrade("damage", 5)

	ImGui.Text("Health Bonus: +" + str(session_health_bonus))
	ImGui.SameLine()
	if ImGui.Button("-##health"):
		if session_health_bonus > 0:
			add_session_upgrade("health", -1)
	ImGui.SameLine()
	if ImGui.Button("+1##health"):
		add_session_upgrade("health", 1)
	ImGui.SameLine()
	if ImGui.Button("+10##health"):
		add_session_upgrade("health", 10)

	ImGui.Text("Fire Rate Bonus: +" + str("%.1f" % session_fire_rate_bonus))
	ImGui.SameLine()
	if ImGui.Button("-##fire_rate"):
		if session_fire_rate_bonus > 0:
			add_session_upgrade("fire_rate", -1)
	ImGui.SameLine()
	if ImGui.Button("+0.5##fire_rate"):
		add_session_upgrade("fire_rate", 1)  # Internally stored as 1 but means 0.5s faster
	ImGui.SameLine()
	if ImGui.Button("+1.0##fire_rate"):
		add_session_upgrade("fire_rate", 2)  # 1.0s faster

	ImGui.Separator()
	if ImGui.Button("Reset All Upgrades"):
		reset_session()
	
	# World control buttons
	if current_world:
		ImGui.Separator()
		ImGui.Text("=== World Controls ===")
		if not current_world.is_active:
			if ImGui.Button("Start World"):
				start_current_world()
		else:
			if ImGui.Button("Stop World"):
				stop_current_world()
		
		ImGui.SameLine()
		if ImGui.Button("Complete World"):
			complete_current_world()
		
		ImGui.SameLine()
		if ImGui.Button("Fail World"):
			fail_current_world()

	ImGui.End()

## Load a world scene and ensure it's a World type
func load_world(world_scene_path: String) -> bool:
	# Unload current world if one exists
	if current_world:
		unload_current_world()

	# Load the new world
	var scene_resource = load(world_scene_path) as PackedScene
	if not scene_resource:
		push_error("WorldManager: Failed to load world scene: " + world_scene_path)
		return false

	var world_instance = scene_resource.instantiate()
	
	# Type check: ensure it's a World
	if not world_instance is WorldBase:
		push_error("WorldManager: Scene is not a World type: " + world_scene_path)
		world_instance.queue_free()
		return false
	
	current_world = world_instance as WorldBase
	get_tree().current_scene.add_child(current_world)
	
	# Connect world signals
	_connect_world_signals()
	
	world_loaded.emit(current_world)
	Loggie.msg("WorldManager: World loaded successfully: %s" % current_world.world_name).domain("WorldMgr").info()
	return true

## Load a world by passing a World instance directly
func load_world_instance(world: WorldBase) -> void:
	if current_world:
		unload_current_world()
	
	current_world = world
	get_tree().current_scene.add_child(current_world)
	
	# Connect world signals
	_connect_world_signals()
	
	world_loaded.emit(current_world)
	Loggie.msg("WorldManager: World instance loaded: %s" % current_world.world_name).domain("WorldMgr").info()

## Unload the current world
func unload_current_world() -> void:
	if not current_world:
		return
	
	Loggie.msg("WorldManager: Unloading world: %s" % current_world.world_name).domain("WorldMgr").info()
	
	# Disconnect signals
	_disconnect_world_signals()
	
	current_world.queue_free()
	current_world = null
	
	# Reset world modifiers
	current_difficulty_multiplier = 1.0
	current_coin_multiplier = 1.0
	
	world_unloaded.emit()

## Start the current world
func start_current_world() -> void:
	if not current_world:
		push_error("WorldManager: No world loaded to start")
		return
	
	current_world.start_world()

## Stop the current world
func stop_current_world() -> void:
	if not current_world:
		return
	
	current_world.stop_world()

## Complete the current world
func complete_current_world() -> void:
	if not current_world:
		return
	
	current_world.complete_world()

## Fail the current world
func fail_current_world() -> void:
	if not current_world:
		return
	
	current_world.fail_world()

## Get reference to current world (type-safe)
func get_current_world() -> WorldBase:
	return current_world

## Apply world modifiers (called by World instances)
func apply_world_modifiers(difficulty_mult: float, coin_mult: float) -> void:
	current_difficulty_multiplier = difficulty_mult
	current_coin_multiplier = coin_mult
	Loggie.msg("WorldManager: Applied world modifiers - Difficulty: x%s, Coins: x%s" % [difficulty_mult, coin_mult]).domain("WorldMgr").debug()

## Connect to world signals
func _connect_world_signals() -> void:
	if not current_world:
		return
	
	current_world.world_started.connect(_on_world_started)
	current_world.world_completed.connect(_on_world_completed)
	current_world.world_failed.connect(_on_world_failed)

## Disconnect world signals
func _disconnect_world_signals() -> void:
	if not current_world:
		return
	
	if current_world.world_started.is_connected(_on_world_started):
		current_world.world_started.disconnect(_on_world_started)
	if current_world.world_completed.is_connected(_on_world_completed):
		current_world.world_completed.disconnect(_on_world_completed)
	if current_world.world_failed.is_connected(_on_world_failed):
		current_world.world_failed.disconnect(_on_world_failed)

## Handle world started signal
func _on_world_started() -> void:
	Loggie.msg("WorldManager: World started: %s" % current_world.world_name).domain("WorldMgr").info()
	world_started.emit(current_world)

## Handle world completed signal
func _on_world_completed() -> void:
	Loggie.msg("WorldManager: World completed: %s" % current_world.world_name).domain("WorldMgr").info()
	world_completed.emit(current_world)
	# TODO: Award completion bonuses, unlock next world, etc.

## Handle world failed signal
func _on_world_failed() -> void:
	Loggie.msg("WorldManager: World failed: %s" % current_world.world_name).domain("WorldMgr").warn()
	world_failed.emit(current_world)
	# TODO: Handle failure penalties, retry options, etc.

# ===== EXISTING FUNCTIONALITY (kept for compatibility) =====

## Add coins to the current total
func add_coins(amount: int) -> void:
	current_coins += amount
	coins_changed.emit(current_coins)
	Loggie.msg("Coins added: +%s (Total: %s)" % [amount, current_coins]).domain("WorldMgr").debug()

## Spend coins if we have enough
func spend_coins(amount: int) -> bool:
	if current_coins >= amount:
		current_coins -= amount
		coins_changed.emit(current_coins)
		Loggie.msg("Coins spent: -%s (Total: %s)" % [amount, current_coins]).domain("WorldMgr").debug()
		return true
	else:
		Loggie.msg("Not enough coins to spend %s (Have: %s)" % [amount, current_coins]).domain("WorldMgr").debug()
		return false

## Get current coin count
func get_coins() -> int:
	return current_coins

## Add session upgrade (temporary boost)
func add_session_upgrade(upgrade_type: String, amount: int) -> void:
	match upgrade_type:
		"damage":
			session_damage_bonus = max(0, session_damage_bonus + amount)  # Prevent negative
			Loggie.msg("Session damage upgraded: %s (Total: +%s)" % [(("+"+str(amount)) if amount >= 0 else str(amount)), session_damage_bonus]).domain("WorldMgr").debug()
		"health":
			session_health_bonus = max(0, session_health_bonus + amount)  # Prevent negative
			Loggie.msg("Session health upgraded: %s (Total: +%s)" % [(("+"+str(amount)) if amount >= 0 else str(amount)), session_health_bonus]).domain("WorldMgr").debug()
		"fire_rate":
			session_fire_rate_bonus = max(0.0, session_fire_rate_bonus + float(amount))  # Prevent negative
			Loggie.msg("Session fire rate upgraded: %s (Total: +%s)" % [(("+"+str(amount)) if amount >= 0 else str(amount)), session_fire_rate_bonus]).domain("WorldMgr").debug()
		_:
			Loggie.msg("Unknown upgrade type: %s" % upgrade_type).domain("WorldMgr").warn()
	# Apply upgrades to all relevant components in the scene
	_apply_upgrades_to_components()

## Apply current upgrades to all components in the scene
func _apply_upgrades_to_components() -> void:
	# Find all HealthComponents and apply health bonus
	var health_components = get_tree().get_nodes_in_group("health_components")
	for component in health_components:
		if component.has_method("apply_health_bonus"):
			component.apply_health_bonus(session_health_bonus)

	# Find all AttackComponents and apply bonuses
	var attack_components = get_tree().get_nodes_in_group("attack_components")
	for component in attack_components:
		if component.has_method("apply_fire_rate_bonus"):
			component.apply_fire_rate_bonus(session_fire_rate_bonus)
		# Note: damage bonus would be applied to a DamageComponent if it existed

## Reset all components to their base values (no bonuses)
func _reset_components_to_base() -> void:
	# Reset all HealthComponents
	var health_components = get_tree().get_nodes_in_group("health_components")
	for component in health_components:
		if component.has_method("reset_bonuses"):
			component.reset_bonuses()

	# Reset all AttackComponents
	var attack_components = get_tree().get_nodes_in_group("attack_components")
	for component in attack_components:
		if component.has_method("reset_bonuses"):
			component.reset_bonuses()

## Apply current session upgrades to a specific component (called when component joins scene)
func apply_upgrades_to_component(component: Node) -> void:
	if component.is_in_group("health_components") and component.has_method("apply_health_bonus"):
		component.apply_health_bonus(session_health_bonus)

	if component.is_in_group("attack_components") and component.has_method("apply_fire_rate_bonus"):
		component.apply_fire_rate_bonus(session_fire_rate_bonus)

## Reset session upgrades (called when returning to menu or starting new session)
func reset_session() -> void:
	session_damage_bonus = 0
	session_health_bonus = 0
	session_fire_rate_bonus = 0.0
	current_coins = starting_coins
	Loggie.msg("Session reset - all upgrades cleared").domain("WorldMgr").info()

	# Reset all components to base values
	_reset_components_to_base()

## Upgrade the coin generation rate
func upgrade_coins_per_second(increase_amount: float) -> void:
	coins_per_second += increase_amount
	Loggie.msg("Coins per second upgraded to: %s" % coins_per_second).domain("WorldMgr").debug()

## Upgrade the coin increment multiplier
func upgrade_coin_multiplier(multiplier_increase: float) -> void:
	coin_increment_multiplier += multiplier_increase
	Loggie.msg("Coin multiplier upgraded to: %s" % coin_increment_multiplier).domain("WorldMgr").debug()

## Get current coin generation stats
func get_coin_generation_rate() -> float:
	return coins_per_second * coin_increment_multiplier * current_coin_multiplier

# ===== DEPRECATED METHODS (kept for compatibility) =====

## Register the current world scene
func register_world(world_node: Node) -> void:
	if world_node is WorldBase:
		current_world = world_node as WorldBase
		_connect_world_signals()
		Loggie.msg("WorldManager: World registered: %s" % world_node.name).domain("WorldMgr").debug()
		# Emit the world loaded signal
		world_loaded.emit(current_world)
	else:
		push_error("WorldManager: Registered node is not a World type")
