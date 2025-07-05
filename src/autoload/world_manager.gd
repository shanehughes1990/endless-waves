extends Node

## Manages the lifecycle and state of the current world.
##
## Tracks world-level stats like coins and manages transitions between worlds.
## Acts as a singleton accessible throughout the game.

# Signals for world state changes
signal coins_changed(current_coins: int)
signal world_loaded(world_scene: PackedScene)
signal world_unloaded()
signal upgrade_applied()

# World state
var current_coins: int = 0
var current_world_scene: Node = null

# Base stats that persist across world reloads
@export var starting_coins: int = 100
@export var coins_per_second: float = 1.0
@export var coin_increment_multiplier: float = 1.0

# Session upgrade bonuses (reset each session)
var session_damage_bonus: int = 0
var session_health_bonus: int = 0
var session_fire_rate_bonus: float = 0.0

# Coin generation timer
var coin_timer: Timer

func _ready() -> void:
	# Initialize with starting values
	current_coins = starting_coins
	print_debug("WorldManager initialized with ", starting_coins, " coins")

	# Create and configure coin generation timer
	coin_timer = Timer.new()
	coin_timer.wait_time = 1.0  # 1 second
	coin_timer.autostart = true
	coin_timer.timeout.connect(_on_coin_timer_timeout)
	add_child(coin_timer)

	# Test upgrades after a delay
	var test_timer = Timer.new()
	test_timer.wait_time = 3.0
	test_timer.one_shot = true
	test_timer.timeout.connect(_apply_test_upgrades)
	add_child(test_timer)
	test_timer.start()

func _apply_test_upgrades() -> void:
	print_debug("WorldManager: Applying test upgrades...")
	add_session_upgrade("damage", 5)
	add_session_upgrade("health", 25)
	add_session_upgrade("fire_rate", 2)

func _process(_delta: float) -> void:
	# Draw debug menu
	_draw_debug_menu()

func _on_coin_timer_timeout() -> void:
	# Generate coins when timer times out
	var coins_to_add = int(coins_per_second * coin_increment_multiplier)
	if coins_to_add > 0:
		add_coins(coins_to_add)

func _draw_debug_menu() -> void:
	ImGui.Begin("World Manager Debug")

	ImGui.Text("=== World Info ===")
	if current_world_scene:
		ImGui.Text("Current World: " + str(current_world_scene.name))
		ImGui.Text("World Type: " + str(current_world_scene.get_class()))
	else:
		ImGui.Text("Current World: None")
	ImGui.Separator()
	ImGui.Text("=== Stats ===")
	ImGui.Text("Coins: " + str(current_coins))
	ImGui.Text("Starting Coins: " + str(starting_coins))
	ImGui.Text("Coins/Second: " + str(coins_per_second))
	ImGui.Text("Increment Multiplier: " + str(coin_increment_multiplier))
	ImGui.Text("Effective Rate: " + str(coins_per_second * coin_increment_multiplier) + "/sec")
	ImGui.Text("Next Coin in: " + str("%.1f" % coin_timer.time_left) + "s")

	ImGui.Separator()
	ImGui.Text("=== Session Upgrades ===")
	ImGui.Text("Damage Bonus: +" + str(session_damage_bonus))
	ImGui.Text("Health Bonus: +" + str(session_health_bonus))
	ImGui.Text("Fire Rate Bonus: +" + str("%.1f" % session_fire_rate_bonus))

	ImGui.End()

## Add coins to the current total
func add_coins(amount: int) -> void:
	current_coins += amount
	coins_changed.emit(current_coins)
	print_debug("Coins added: +", amount, " (Total: ", current_coins, ")")

## Spend coins if we have enough
func spend_coins(amount: int) -> bool:
	if current_coins >= amount:
		current_coins -= amount
		coins_changed.emit(current_coins)
		print_debug("Coins spent: -", amount, " (Total: ", current_coins, ")")
		return true
	else:
		print_debug("Not enough coins to spend ", amount, " (Have: ", current_coins, ")")
		return false

## Get current coin count
func get_coins() -> int:
	return current_coins

## Get damage bonus for components
func get_damage_bonus() -> int:
	return session_damage_bonus

## Get health bonus for components
func get_health_bonus() -> int:
	return session_health_bonus

## Get fire rate bonus for components
func get_fire_rate_bonus() -> float:
	return session_fire_rate_bonus

## Add session upgrade (temporary boost)
func add_session_upgrade(upgrade_type: String, amount: int) -> void:
	match upgrade_type:
		"damage":
			session_damage_bonus += amount
			print_debug("Session damage upgraded: +", amount, " (Total: +", session_damage_bonus, ")")
		"health":
			session_health_bonus += amount
			print_debug("Session health upgraded: +", amount, " (Total: +", session_health_bonus, ")")
		"fire_rate":
			session_fire_rate_bonus += float(amount)
			print_debug("Session fire rate upgraded: +", amount, " (Total: +", session_fire_rate_bonus, ")")
		_:
			print_debug("Unknown upgrade type: ", upgrade_type)

	# Notify components to recalculate stats
	upgrade_applied.emit()

## Reset session upgrades (called when returning to menu or starting new session)
func reset_session() -> void:
	session_damage_bonus = 0
	session_health_bonus = 0
	session_fire_rate_bonus = 0.0
	current_coins = starting_coins
	print_debug("Session reset - all upgrades cleared")

## Upgrade the coin generation rate
func upgrade_coins_per_second(increase_amount: float) -> void:
	coins_per_second += increase_amount
	print_debug("Coins per second upgraded to: ", coins_per_second)

## Upgrade the coin increment multiplier
func upgrade_coin_multiplier(multiplier_increase: float) -> void:
	coin_increment_multiplier += multiplier_increase
	print_debug("Coin multiplier upgraded to: ", coin_increment_multiplier)

## Get current coin generation stats
func get_coin_generation_rate() -> float:
	return coins_per_second * coin_increment_multiplier

## Load a new world scene
func load_world(world_scene_path: String) -> void:
	# Unload current world if one exists
	if current_world_scene:
		unload_current_world()

	# Load the new world
	var scene_resource = load(world_scene_path) as PackedScene
	if scene_resource:
		current_world_scene = scene_resource.instantiate()
		get_tree().current_scene.add_child(current_world_scene)
		world_loaded.emit(scene_resource)
		print_debug("World loaded: ", world_scene_path)
	else:
		push_error("Failed to load world scene: " + world_scene_path)

## Unload the current world
func unload_current_world() -> void:
	if current_world_scene:
		current_world_scene.queue_free()
		current_world_scene = null
		world_unloaded.emit()
		print_debug("Current world unloaded")

## Register the current world scene (called by world scenes when they load)
func register_world(world_node: Node) -> void:
	current_world_scene = world_node
	print_debug("World registered: ", world_node.name)

## Get reference to current world
func get_current_world() -> Node:
	return current_world_scene
