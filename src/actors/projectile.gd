extends Area2D

## A projectile that moves in a straight line and damages targets.

# The damage the projectile inflicts on a target (set dynamically by firing component).
var damage: int = 10

# The speed of the projectile in pixels per second.
@export var speed: float = 600.0

# The time in seconds before the projectile is destroyed.
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Connect collision signals for both bodies and areas
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Set a timer to destroy the projectile after its lifetime expires.
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _process(delta: float) -> void:
	# Move the projectile in its direction.
	global_position += direction * speed * delta

# This method is called by the AttackComponent to set the projectile's damage amount.
func set_damage(damage_amount: int) -> void:
	damage = max(1, damage_amount)  # Ensure minimum 1 damage
	Loggie.msg("Projectile damage set to %s" % damage).domain("Projectile").info()

# This method is called by the AttackComponent to set the projectile's initial direction.
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	# Rotate the projectile to face the direction it's moving.
	rotation = direction.angle()

func _on_body_entered(body: Node) -> void:
	# Handle collision with CharacterBody2D or RigidBody2D enemies
	_damage_target(body)

func _on_area_entered(area: Area2D) -> void:
	# Handle collision with Area2D-based enemies
	var target = area.get_parent()  # Get the enemy node
	if target and target.is_in_group("enemies"):
		_damage_target(target)

func _damage_target(target: Node) -> void:
	# Check if the target has a health component
	if target.has_node("HealthComponent"):
		var health_component = target.get_node("HealthComponent")
		if health_component.has_method("take_damage"):
			health_component.take_damage(damage)
			Loggie.msg("Projectile hit %s for %s damage" % [target.name, damage]).domain("Projectile").info()
			
			# Create floating damage number
			_show_damage_number(target, damage)
	
	# Destroy the projectile on impact
	queue_free()

# Show floating damage number at target location
func _show_damage_number(target: Node, damage_amount: int) -> void:
	# Create a floating label to show damage
	var damage_label = Label.new()
	damage_label.text = str(damage_amount)
	damage_label.add_theme_color_override("font_color", Color.YELLOW)
	damage_label.add_theme_font_size_override("font_size", 20)
	
	# Add to the scene at target position
	get_tree().root.add_child(damage_label)
	damage_label.global_position = target.global_position
	
	# Animate the floating effect
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(damage_label, "global_position", damage_label.global_position + Vector2(0, -50), 1.0)
	tween.parallel().tween_property(damage_label, "modulate", Color.TRANSPARENT, 1.0)
	tween.tween_callback(damage_label.queue_free)
