extends Control
class_name DebugMenu

@onready var base_stats_label: Label = $Panel/VBoxContainer/BaseStatsLabel
@onready var monster_stats_label: Label = $Panel/VBoxContainer/MonsterStatsLabel

var base_reference: Base
var world_manager_reference: WorldSceneManager
var monster_references: Array[Monster] = []

func _ready() -> void:
	# Positioning is already set in the scene file
	pass

func set_base_reference(base: Base) -> void:
	base_reference = base

func set_world_manager_reference(world_manager: WorldSceneManager) -> void:
	world_manager_reference = world_manager

func add_monster_reference(monster: Monster) -> void:
	monster_references.append(monster)

func _process(_delta: float) -> void:
	if base_reference:
		update_base_stats()
	
	update_monster_stats()

func update_base_stats() -> void:
	var debug_info = base_reference.get_debug_info()
	
	var stats_text = "=== BASE STATS ===\n"
	stats_text += "Health: %.0f/%.0f (%.1f%%)\n" % [
		debug_info.health.current,
		debug_info.health.max,
		debug_info.health.percentage * 100
	]
	
	# Get coins from WorldSceneManager if available, otherwise from base
	var coins_amount = 0
	if world_manager_reference:
		coins_amount = world_manager_reference.get_coins()
	else:
		coins_amount = debug_info.get("coins", {}).get("current", 0)
	
	stats_text += "Coins: %d" % coins_amount
	
	# Add coin gather rate if WorldSceneManager is available
	if world_manager_reference:
		var world_info = world_manager_reference.get_world_debug_info()
		stats_text += " (+%.1f/s)" % world_info.coins.gather_rate
	
	stats_text += "\n\n"
	
	stats_text += "=== UPGRADES ===\n"
	for upgrade_name in debug_info.upgrades.keys():
		var upgrade = debug_info.upgrades[upgrade_name]
		stats_text += "%s: Level %d\n" % [upgrade_name.capitalize(), upgrade.level]
	
	# Add World Manager info if available
	if world_manager_reference:
		var world_info = world_manager_reference.get_world_debug_info()
		stats_text += "\n=== WORLD INFO ===\n"
		stats_text += "Enemy Count: %d\n" % world_info.enemies.count
		stats_text += "Debug Enabled: %s\n" % ("Yes" if world_info.debug.enabled else "No")
		
		# Add wave information if available
		if world_info.has("waves") and world_info.waves.has("wave_system"):
			var wave_info = world_info.waves
			stats_text += "\n=== WAVES ===\n"
			if wave_info.wave_system.enabled:
				stats_text += "Wave: %d/%d\n" % [wave_info.wave_system.current_wave, wave_info.wave_system.max_waves]
				if wave_info.wave_system.wave_active:
					stats_text += "Status: ACTIVE\n"
					stats_text += "Enemies: %d/%d\n" % [wave_info.current_wave.enemies_spawned, wave_info.current_wave.enemies_total]
					stats_text += "Rate: %.1f/sec\n" % wave_info.spawn_settings.rate
				elif wave_info.wave_system.wave_complete:
					stats_text += "Status: COMPLETED\n"
				else:
					stats_text += "Status: DELAY\n"
					stats_text += "Next in: %.1fs\n" % (wave_info.timers.wave_delay_total - wave_info.timers.wave_delay_timer)
			else:
				stats_text += "Status: DISABLED\n"
	
	base_stats_label.text = stats_text

func update_monster_stats() -> void:
	# Remove dead monsters from references
	monster_references = monster_references.filter(func(monster): return is_instance_valid(monster))
	
	var stats_text = "=== MONSTERS ===\n"
	stats_text += "Count: %d\n\n" % monster_references.size()
	
	for i in range(min(monster_references.size(), 3)):  # Show max 3 monsters
		var monster = monster_references[i]
		var debug_info = monster.get_debug_info()
		
		stats_text += "%s:\n" % debug_info.get("type", "Monster")
		stats_text += "  HP: %.0f/%.0f\n" % [debug_info.health.current, debug_info.health.max]
		stats_text += "  Speed: %.0f\n" % debug_info.movement.speed
		stats_text += "  Attack: %.0f dmg, %.1f/s\n" % [debug_info.attack.damage, debug_info.attack.speed]
		stats_text += "  Type: %s\n" % debug_info.attack.type
		stats_text += "\n"
	
	monster_stats_label.text = stats_text
