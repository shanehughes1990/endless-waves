extends CharacterBody2D
class_name Projectile

# Projectile Properties
var damage: float = 10.0
var speed: float = 800.0
var direction: Vector2 = Vector2.ZERO
var max_travel_distance: float = 1000.0
var pierce_count: int = 0  # How many enemies it can go through

# Internal State
var travel_distance: float = 0.0
var start_position: Vector2
var targets_hit: Array[Node2D] = []

# Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Visual Effects
var trail_enabled: bool = true
var explosion_on_impact: bool = false

func _ready() -> void:
	# Set up projectile visual
	if sprite and not sprite.texture:
		# Create a simple projectile visual
		sprite.texture = load("res://icon.svg")
		sprite.scale = Vector2(0.1, 0.1)  # Small projectile
		sprite.modulate = Color.YELLOW
	
	# Set collision layers (projectiles layer 3)
	collision_layer = 4  # Projectiles
	collision_mask = 2   # Hit enemies
	
	# Store starting position
	start_position = global_position
	
	print("Projectile: Created - Damage: %.0f, Speed: %.0f" % [damage, speed])

func initialize(start_pos: Vector2, move_direction: Vector2, projectile_speed: float, projectile_damage: float) -> void:
	global_position = start_pos
	direction = move_direction.normalized()
	speed = projectile_speed
	damage = projectile_damage
	start_position = start_pos
	
	# Rotate sprite to face direction
	if sprite:
		sprite.rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Move projectile
	velocity = direction * speed
	var collision = move_and_slide()
	
	# Track travel distance
	travel_distance += speed * delta
	
	# Check for collision
	if collision and get_slide_collision_count() > 0:
		_handle_collision()
	
	# Destroy if traveled too far
	if travel_distance >= max_travel_distance:
		_destroy_projectile("Max distance reached")

func _handle_collision() -> void:
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		
		if collider and collider.has_method("take_damage"):
			# Don't hit the same target twice
			if not targets_hit.has(collider):
				targets_hit.append(collider)
				_damage_target(collider)
				
				# Check if we should stop (piercing logic)
				if targets_hit.size() > pierce_count:
					_destroy_projectile("Hit target")
					return

func _damage_target(target: Node2D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage)
		print("Projectile: Hit %s for %.0f damage" % [target.name, damage])
	
	# Visual effect on hit
	_create_hit_effect(target.global_position)

func _create_hit_effect(hit_position: Vector2) -> void:
	# Simple hit effect - you can expand this later
	print("Projectile: Hit effect at %s" % hit_position)
	
	# TODO: Add particle effects, screen shake, etc.

func _destroy_projectile(reason: String = "Unknown") -> void:
	print("Projectile: Destroyed - %s" % reason)
	
	# Create destruction effect if needed
	if explosion_on_impact:
		_create_explosion_effect()
	
	# Remove from scene
	queue_free()

func _create_explosion_effect() -> void:
	# TODO: Add explosion particle effects
	print("Projectile: Explosion effect")

# Public interface
func set_pierce_count(pierce: int) -> void:
	pierce_count = pierce

func set_max_range(range: float) -> void:
	max_travel_distance = range

func enable_trail(enabled: bool) -> void:
	trail_enabled = enabled
	# TODO: Implement trail visual effect

func enable_explosion(enabled: bool) -> void:
	explosion_on_impact = enabled

# Area damage for explosive projectiles
func deal_area_damage(center: Vector2, radius: float, area_damage: float) -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = center
	query.collision_mask = 2  # Enemies layer
	
	# Find all enemies in radius
	var enemies_in_area = []
	var all_bodies = space_state.intersect_point(query)
	
	for body_info in all_bodies:
		var body = body_info.collider
		if body.has_method("take_damage"):
			var distance = center.distance_to(body.global_position)
			if distance <= radius:
				enemies_in_area.append(body)
	
	# Damage all enemies in area
	for enemy in enemies_in_area:
		if enemy.has_method("take_damage"):
			enemy.take_damage(area_damage)
			print("Projectile: Area damage - Hit %s for %.0f damage" % [enemy.name, area_damage])
