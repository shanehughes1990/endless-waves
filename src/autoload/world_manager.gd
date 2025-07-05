extends Node

## Manages the lifecycle and state of the current world.
##
## Tracks world-level stats like coins and manages transitions between worlds.
## Acts as a singleton accessible throughout the game.

# Signals for world state changes
signal coins_changed(current_coins: int)
signal world_loaded(world_scene: PackedScene)
signal world_unloaded()

# World state
var current_coins: int = 0
var current_world_scene: Node = null

# Base stats that persist across world reloads
@export var starting_coins: int = 100

func _ready() -> void:
	# Initialize with starting values
	current_coins = starting_coins
	print_debug("WorldManager initialized with ", starting_coins, " coins")

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
