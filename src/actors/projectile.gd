extends Area2D

## A projectile that moves in a straight line and damages targets.

# The damage the projectile inflicts on a target.
@export var damage: int = 10

# The speed of the projectile in pixels per second.
@export var speed: float = 600.0

# The time in seconds before the projectile is destroyed.
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Connect the body_entered signal to handle collisions.
	body_entered.connect(_on_body_entered)
	
	# Set a timer to destroy the projectile after its lifetime expires.
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _process(delta: float) -> void:
	# Move the projectile in its direction.
	global_position += direction * speed * delta

# This method is called by the AttackComponent to set the projectile's initial direction.
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	# Rotate the projectile to face the direction it's moving.
	rotation = direction.angle()

func _on_body_entered(body: Node) -> void:
	# Check if the body has a health component.
	if body.has_node("HealthComponent"):
		var health_component = body.get_node("HealthComponent")
		if health_component.has_method("take_damage"):
			health_component.take_damage(damage)
	
	# Destroy the projectile on impact.
	queue_free()
