# Component System

This directory contains reusable component scripts that can be attached to entities.

## Component Categories

- **combat/** - Health, weapons, damage, armor
- **movement/** - Movement, pathfinding, positioning
- **ai/** - AI behaviors, state machines, targeting
- **economy/** - Costs, resource generation, upgrades
- **building/** - Construction, placement, production
- **ui/** - Health bars, info displays, interactions

## Component Guidelines

### Base Component Pattern
```gdscript
extends Node
class_name BaseComponent

# Reference to the entity this component is attached to
@onready var entity: Node = get_parent()

# Override in derived components
func _component_ready() -> void:
    pass

func _ready() -> void:
    _component_ready()
```

### Component Communication
- Use signals for loose coupling
- Access sibling components through parent entity
- Avoid direct references between components
- Use EventBus for global communication

### Example Component
```gdscript
extends BaseComponent
class_name HealthComponent

signal health_changed(current: float, maximum: float)
signal died(entity: Node)

@export var max_health: float = 100.0
var current_health: float

func _component_ready() -> void:
    current_health = max_health

func take_damage(amount: float) -> void:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health, max_health)
    
    if current_health <= 0:
        died.emit(entity)
```

## Usage in Entities

Components are added as child nodes in entity scenes:
```
UnitEntity
├── Sprite2D
├── CollisionShape2D  
├── HealthComponent
├── MovementComponent
└── WeaponComponent
```
