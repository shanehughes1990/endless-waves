extends Node
class_name WorldSceneManager

# Debug Settings
@export_group("Debug Settings")
@export var debug_enabled: bool = true
@export var debug_menu_visible_on_start: bool = true

# Economy Settings
@export_group("Economy")
@export var starting_coins: int = 100
@export var coin_gather_rate: float = 1.0  # Coins per second
@export var coin_gather_enabled: bool = true

# Camera Management
@export_group("Camera Settings")
@export var camera_follow_base: bool = true
@export var camera_smooth_follow: bool = false
@export var camera_follow_speed: float = 5.0

# Node References
@onready var base: Base
@onready var debug_menu: DebugMenu
@onready var debug_menu_canvas: CanvasLayer
@onready var camera: Camera2D
@onready var spawning_system: SpawningSystem

# World State
var current_coins: int = 0
var current_enemies: Array[Monster] = []
var coin_gather_timer: float = 0.0
var debug_menu_visible: bool = true

# Signals
signal coins_changed(new_amount: int)
signal enemy_spawned(monster: Monster)
signal enemy_died(monster: Monster)

func _ready() -> void:
	print("WorldSceneManager: Starting...")
	
	# Initialize economy
	current_coins = starting_coins
	debug_menu_visible = debug_menu_visible_on_start
	
	# Find required nodes
	_find_world_nodes()
	
	# Setup initial connections
	_setup_world()
	
	print("WorldSceneManager: Initialized with %d coins" % current_coins)

func _find_world_nodes() -> void:
	# Find base (now in GameLayer)
	base = get_node_or_null("../GameLayer/Base")
	if not base:
		print("ERROR: Base not found!")
	
	# Find debug menu components (now in UILayer)
	debug_menu_canvas = get_node_or_null("../UILayer/DebugMenu")
	if debug_menu_canvas:
		debug_menu = debug_menu_canvas.get_node_or_null("DebugMenuControl")
	
	if not debug_menu and debug_enabled:
		print("ERROR: DebugMenu not found!")
	
	# Find camera
	camera = get_node_or_null("../Camera2D")
	if not camera:
		print("ERROR: Camera2D not found!")
	
	# Find spawning system
	spawning_system = get_node_or_null("../SpawningSystem")
	if not spawning_system:
		print("ERROR: SpawningSystem not found!")

func _setup_world() -> void:
	# Setup debug menu if enabled
	if debug_enabled and debug_menu and base:
		debug_menu.set_base_reference(base)
		debug_menu.set_world_manager_reference(self)
		debug_menu_canvas.visible = debug_menu_visible
		print("WorldSceneManager: Debug menu connected")
	elif debug_enabled:
		print("WorldSceneManager: Debug mode enabled but components missing")
	
	# Setup camera after base is ready
	if camera and base and camera_follow_base:
		# Wait one frame for base to position itself
		await get_tree().process_frame
		camera.global_position = base.global_position
		print("WorldSceneManager: Camera centered on base at: %s" % base.global_position)
	elif camera:
		print("WorldSceneManager: Camera found but not following base")
	else:
		print("ERROR: Camera2D not found!")
	
	# Initialize spawning system
	if spawning_system and base:
		spawning_system.initialize(self, base)
		print("WorldSceneManager: SpawningSystem initialized")
	else:
		print("ERROR: Cannot initialize SpawningSystem - missing components")
	
	# Find existing monsters and track them
	_find_existing_monsters()
	
	# Connect signals
	coins_changed.connect(_on_coins_changed)

func _find_existing_monsters() -> void:
	# Find any existing monsters in the scene
	var monsters = get_tree().get_nodes_in_group("monsters")
	for monster in monsters:
		if monster is Monster:
			add_enemy_to_tracking(monster)

func _process(delta: float) -> void:
	# Handle coin gathering
	if coin_gather_enabled and coin_gather_rate > 0:
		coin_gather_timer += delta
		if coin_gather_timer >= 1.0:  # Every second
			add_coins(int(coin_gather_rate))
			coin_gather_timer = 0.0
	
	# Handle camera following
	if camera and base and camera_follow_base and camera_smooth_follow:
		camera.global_position = camera.global_position.lerp(
			base.global_position, 
			camera_follow_speed * delta
		)
	
	# Clean up dead enemies
	_cleanup_dead_enemies()

func _input(event: InputEvent) -> void:
	if not debug_enabled:
		return
	
	if event.is_action_pressed("toggle_debug_menu"):
		toggle_debug_menu()
	elif event.is_action_pressed("spawn_monster"):
		spawn_monster()
	elif event.is_action_pressed("start_wave"):
		start_wave()

# Economy Management
func add_coins(amount: int) -> void:
	current_coins += amount
	coins_changed.emit(current_coins)

func spend_coins(amount: int) -> bool:
	if current_coins >= amount:
		current_coins -= amount
		coins_changed.emit(current_coins)
		return true
	return false

func get_coins() -> int:
	return current_coins

# Enemy Management
func add_enemy_to_tracking(monster: Monster) -> void:
	if monster and not current_enemies.has(monster):
		current_enemies.append(monster)
		
		# Add to debug menu if available
		if debug_enabled and debug_menu:
			debug_menu.add_monster_reference(monster)
		
		# Connect death signal if available
		if monster.has_signal("died"):
			monster.died.connect(_on_enemy_died)
		
		enemy_spawned.emit(monster)
		print("WorldSceneManager: Added enemy to tracking (Total: %d)" % current_enemies.size())

func _on_enemy_died(monster: Monster) -> void:
	remove_enemy_from_tracking(monster)
	enemy_died.emit(monster)

func remove_enemy_from_tracking(monster: Monster) -> void:
	if current_enemies.has(monster):
		current_enemies.erase(monster)
		print("WorldSceneManager: Removed enemy from tracking (Total: %d)" % current_enemies.size())

func _cleanup_dead_enemies() -> void:
	# Remove invalid/freed monsters from tracking
	current_enemies = current_enemies.filter(func(monster): return is_instance_valid(monster))

func get_enemy_count() -> int:
	return current_enemies.size()

func get_enemies() -> Array[Monster]:
	return current_enemies.duplicate()

# Camera Management Functions
func center_camera_on_base() -> void:
	if camera and base:
		camera.global_position = base.global_position
		print("WorldSceneManager: Camera manually centered on base")

func set_camera_follow(follow: bool) -> void:
	camera_follow_base = follow
	if follow and camera and base:
		center_camera_on_base()

func move_camera_to(position: Vector2, smooth: bool = false) -> void:
	if not camera:
		return
	
	if smooth and camera_smooth_follow:
		# Let the smooth follow handle it in _process
		pass
	else:
		camera.global_position = position

# Debug Functions
func toggle_debug_menu() -> void:
	if not debug_enabled:
		return
	
	debug_menu_visible = !debug_menu_visible
	if debug_menu_canvas:
		debug_menu_canvas.visible = debug_menu_visible
	
	if debug_menu_visible:
		print("WorldSceneManager: Debug menu shown")
	else:
		print("WorldSceneManager: Debug menu hidden")

func start_wave() -> void:
	if not debug_enabled:
		return
	
	if not spawning_system:
		print("ERROR: Cannot start wave - SpawningSystem not found!")
		return
	
	# Start the current wave via spawning system
	spawning_system.start_current_wave()
	print("WorldSceneManager: Wave start requested via SpawningSystem")

func spawn_monster() -> void:
	if not debug_enabled:
		return
	
	if not spawning_system:
		print("ERROR: Cannot spawn monster - SpawningSystem not found!")
		return
	
	# Use the spawning system for manual spawns
	var new_monster = spawning_system.spawn_manual_enemy()
	if new_monster:
		print("WorldSceneManager: Manual monster spawned via SpawningSystem")
	else:
		print("WorldSceneManager: Failed to spawn manual monster")

# Signal Handlers
func _on_coins_changed(new_amount: int) -> void:
	print("WorldSceneManager: Coins changed to %d" % new_amount)

# Debug Info for Debug Menu
func get_world_debug_info() -> Dictionary:
	var wave_info = {}
	if spawning_system:
		wave_info = spawning_system.get_wave_debug_info()
	
	return {
		"coins": {
			"current": current_coins,
			"gather_rate": coin_gather_rate,
			"gather_enabled": coin_gather_enabled
		},
		"enemies": {
			"count": current_enemies.size(),
			"list": current_enemies
		},
		"debug": {
			"enabled": debug_enabled,
			"menu_visible": debug_menu_visible
		},
		"waves": wave_info
	}
