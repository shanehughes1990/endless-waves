extends Node2D
class_name Base

## The player's base that can be upgraded with different components.

# References to components
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent
@onready var damage_component: DamageComponent = $DamageComponent

# UI Elements for stats display
var stats_label: Label

func _ready() -> void:
	# Add to bases group so enemies can find this base
	add_to_group("bases")
	
	# Create stats display
	_create_stats_display()
	
	# Configure attack component with projectile
	if attack_component:
		attack_component.projectile_scene = preload("res://src/actors/projectile.tscn")
		attack_component.base_fire_rate = 0.5  # Fire twice per second
		attack_component.attack_range = 400.0  # Good range to defend
		attack_component.projectile_count = 1
		attack_component.base_projectile_damage = 15  # Default damage if no DamageComponent
	
	# Configure damage component
	if damage_component:
		damage_component.base_damage = 25  # Base damage for projectiles
		Loggie.msg("Base: DamageComponent configured with %s base damage" % damage_component.base_damage).domain("Base").info()
	
	# Connect to health component signals
	if health_component:
		health_component.died.connect(_on_health_component_died)
		health_component.health_changed.connect(_on_health_changed)

	# Connect to attack component signals
	if attack_component:
		attack_component.fired.connect(_on_attack_component_fired)
	
	# Connect to damage component signals
	if damage_component:
		damage_component.damage_changed.connect(_on_damage_changed)
	
	# Update stats display initially
	_update_stats_display()

func _create_stats_display() -> void:
	# Create a label to show current stats
	stats_label = Label.new()
	stats_label.position = Vector2(-100, -100)  # Position above the base
	stats_label.add_theme_color_override("font_color", Color.WHITE)
	stats_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	stats_label.add_theme_constant_override("shadow_offset_x", 2)
	stats_label.add_theme_constant_override("shadow_offset_y", 2)
	stats_label.add_theme_font_size_override("font_size", 14)
	add_child(stats_label)

func _update_stats_display() -> void:
	if not stats_label:
		return
		
	var stats_text = "BASE STATS\n"
	
	if health_component:
		stats_text += "Health: %d/%d\n" % [health_component.get_current_health(), health_component.get_max_health()]
	
	if damage_component:
		stats_text += "Damage: %d\n" % damage_component.get_damage()
	
	if attack_component:
		stats_text += "Fire Rate: %.2fs\n" % attack_component.get_effective_fire_rate()
	
	stats_label.text = stats_text

func _on_health_component_died() -> void:
	Loggie.msg("Base destroyed!").domain("Base").warn()
	# TODO: Implement game over logic

func _on_health_changed(_current_health: int) -> void:
	Loggie.msg("Base health: %s" % _current_health).domain("Base").info()
	# Update stats display
	_update_stats_display()

func _on_attack_component_fired(_projectile: Node) -> void:
	Loggie.msg("Base fired a projectile!").domain("Base").info()
	# TODO: Could add visual/audio effects here

func _on_damage_changed(current_damage: int) -> void:
	Loggie.msg("Base damage updated to: %s" % current_damage).domain("Base").info()
	# Update stats display
	_update_stats_display()
