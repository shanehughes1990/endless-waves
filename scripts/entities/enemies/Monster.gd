extends CharacterBody2D
class_name Monster

@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var attack_component: AttackComponent = $AttackComponent
@onready var sprite: Sprite2D = $Sprite2D

# Movement targeting
var target_node: Node2D = null
var target_position: Vector2 = Vector2.ZERO
var move_toward_target: bool = true

func _ready() -> void:
	# Add to enemies group for targeting
	add_to_group("enemies")
	
	# Load the Godot icon if not already set
	if sprite and not sprite.texture:
		sprite.texture = load("res://icon.svg")
		# Make it smaller for monsters
		sprite.scale = Vector2(0.5, 0.5)
		# Set a red color to distinguish from base
		sprite.modulate = Color.RED
	
	# Connect component signals
	if health_component:
		health_component.died.connect(_on_death)
	
	if attack_component:
		attack_component.attack_performed.connect(_on_attack_performed)

func _physics_process(delta: float) -> void:
	if move_toward_target:
		_move_toward_target(delta)
		
	# Handle collision-based movement
	var collision_occurred = move_and_slide()
	
	# Debug collision information
	if collision_occurred and get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			print("Monster collided with: ", collider.name if collider else "Unknown")

func _move_toward_target(delta: float) -> void:
	var target_pos = Vector2.ZERO
	
	# Determine target position
	if target_node and is_instance_valid(target_node):
		target_pos = target_node.global_position
	elif target_position != Vector2.ZERO:
		target_pos = target_position
	else:
		return  # No target set
	
	# Calculate distance to target
	var distance_to_target = global_position.distance_to(target_pos)
	
	# Stop if close enough to target (don't overlap base)
	var stop_distance = 85.0  # Base radius (40) + Monster radius (30) + buffer (15)
	if distance_to_target <= stop_distance:
		velocity = Vector2.ZERO
		move_toward_target = false
		print("Monster reached base!")
		return
	
	# Calculate movement direction
	var direction = (target_pos - global_position).normalized()
	var speed = movement_component.get_movement_speed() if movement_component else 100.0
	
	# Set velocity for movement
	velocity = direction * speed
	
	# Check if we're stuck (collision detected)
	if is_on_wall():
		# Try to slide along the collision
		var slide_dir = get_wall_normal().rotated(PI/2)
		velocity = slide_dir * speed * 0.5  # Slower sliding movement
		print("Monster collision detected, sliding")

func set_target(new_target: Node2D) -> void:
	target_node = new_target
	target_position = Vector2.ZERO
	move_toward_target = true
	print("Monster: Target set to ", new_target.name if new_target else "null")

func set_target_position(pos: Vector2) -> void:
	target_node = null
	target_position = pos
	move_toward_target = true
	print("Monster: Target position set to ", pos)

func _on_death() -> void:
	print("Monster died!")
	queue_free()

func _on_attack_performed(target: Node, damage: float) -> void:
	print("Monster attacked ", target.name, " for ", damage, " damage")

# Public interface for taking damage
func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)
		print("Monster %s took %.0f damage (%.0f/%.0f HP)" % [name, amount, health_component.current_health, health_component.max_health])
	else:
		print("Monster %s took %.0f damage but has no health component!" % [name, amount])

func get_debug_info() -> Dictionary:
	var info = {
		"health": {},
		"movement": {},
		"attack": {}
	}
	
	if health_component:
		info.health = {
			"current": health_component.current_health,
			"max": health_component.max_health,
			"percentage": health_component.get_health_percentage()
		}
	
	if movement_component:
		info.movement = {
			"speed": movement_component.get_movement_speed()
		}
	
	if attack_component:
		info.attack = attack_component.get_attack_info()
	
	return info
