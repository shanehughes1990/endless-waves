# Entity Scripts

This directory contains the core entity behavior scripts that work with components.

## Entity Hierarchy

```
BaseEntity.gd                 # Root entity class
├── BaseUnit.gd              # Player units
├── BaseBuilding.gd          # Buildings and turrets  
├── BaseEnemy.gd             # Enemy entities
└── BaseProjectile.gd        # Projectiles and effects
```

## Base Entity Pattern

```gdscript
extends Node2D
class_name BaseEntity

# Component references (cached in _ready)
@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent

# Entity properties
@export var entity_id: String
@export var entity_name: String

func _ready() -> void:
    _cache_components()
    _setup_connections()
    _entity_ready()

func _cache_components() -> void:
    # Cache component references for performance
    health_component = get_component(HealthComponent)
    movement_component = get_component(MovementComponent)

func _setup_connections() -> void:
    # Connect to component signals
    if health_component:
        health_component.died.connect(_on_death)

# Override in derived classes
func _entity_ready() -> void:
    pass

func get_component(component_class) -> Node:
    for child in get_children():
        if child is component_class:
            return child
    return null

func _on_death() -> void:
    # Handle entity death
    queue_free()
```

## Entity Guidelines

- Inherit from appropriate base class
- Cache component references in _ready()
- Use signals for component communication
- Keep entity logic minimal - use components
- Follow typed GDScript patterns
- Test entities in isolation

## Scene Structure

Entity scenes should follow this pattern:
```
EntityScene.tscn
├── EntityRoot (BaseEntity script)
│   ├── Sprite2D
│   ├── CollisionShape2D
│   ├── [Required Components]
│   └── [Optional Components]
```
