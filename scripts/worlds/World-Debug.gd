extends Node2D

@onready var world_manager: WorldSceneManager = $WorldSceneManager
@onready var spawning_system: SpawningSystem = $SpawningSystem
@onready var base: Base = $GameLayer/Base

func _ready() -> void:
	print("World-Debug: Scene loaded, WorldSceneManager will handle initialization...")
	
	# Wait a frame for all nodes to be ready
	await get_tree().process_frame
	
	# Setup debug controls
	_setup_debug_controls()

func _setup_debug_controls() -> void:
	if base:
		# Enable debug drawing for the base
		base.debug_draw_range = true
		base.queue_redraw()
		
		print("World-Debug: Base shooting system ready!")
		print("  - Attack Damage: %.0f" % base.attack_damage)
		print("  - Attack Speed: %.1f/s" % base.attack_speed)
		print("  - Attack Range: %.0f" % base.attack_range)
		print("  - Projectile Speed: %.0f" % base.projectile_speed)
		print("  - Auto Target: %s" % base.auto_target)
		print("")
		print("DEBUG CONTROLS:")
		print("  - F1: Spawn enemy manually")
		print("  - F2: Toggle base debug drawing")
		print("  - F3: Upgrade base damage")
		print("  - F4: Upgrade base attack speed")
		print("  - F5: Upgrade base range")
		print("  - SPACE: Start wave")
		print("  - NUMPAD_ENTER: Spawn enemy at base position")

func _input(event: InputEvent) -> void:
	# Handle keyboard input only - no manual firing for idle game
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				_spawn_debug_enemy()
			KEY_F2:
				_toggle_base_debug_draw()
			KEY_F3:
				_upgrade_base_damage()
			KEY_F4:
				_upgrade_base_attack_speed()
			KEY_F5:
				_upgrade_base_range()
			KEY_KP_ENTER:
				_spawn_enemy_near_base()

func _spawn_debug_enemy() -> void:
	if spawning_system:
		var enemy = spawning_system.spawn_manual_enemy()
		if enemy:
			print("World-Debug: Spawned debug enemy at position %s" % enemy.global_position)
		else:
			print("World-Debug: Failed to spawn debug enemy")

func _spawn_enemy_near_base() -> void:
	if not base:
		return
		
	# Spawn an enemy close to the base for immediate testing
	var monster_scene = load("res://scenes/entities/enemies/MonsterDebug.tscn")
	var monster = monster_scene.instantiate()
	
	# Position it within shooting range but not too close
	var angle = randf() * TAU
	var distance = base.attack_range * 0.8  # 80% of attack range
	monster.global_position = base.global_position + Vector2(
		cos(angle) * distance,
		sin(angle) * distance
	)
	
	# Set target to base
	if monster.has_method("set_target"):
		monster.set_target(base)
	
	# Add to game layer
	$GameLayer.add_child(monster)
	
	# Track with world manager
	if world_manager:
		world_manager.add_enemy_to_tracking(monster)
	
	print("World-Debug: Spawned enemy near base at distance %.0f" % distance)

func _toggle_base_debug_draw() -> void:
	if base:
		base.toggle_debug_draw()
		print("World-Debug: Base debug drawing toggled - now %s" % ("ON" if base.debug_draw_range else "OFF"))

func _upgrade_base_damage() -> void:
	if base:
		base.upgrade_damage(10.0)
		print("World-Debug: Base damage upgraded to %.0f" % base.attack_damage)

func _upgrade_base_attack_speed() -> void:
	if base:
		base.upgrade_attack_speed(0.5)
		print("World-Debug: Base attack speed upgraded to %.1f/s" % base.attack_speed)

func _upgrade_base_range() -> void:
	if base:
		base.upgrade_range(50.0)
		print("World-Debug: Base range upgraded to %.0f" % base.attack_range)
