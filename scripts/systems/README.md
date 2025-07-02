# System Scripts

This directory contains game system managers that coordinate entities and components.

## System Categories

- **WaveSystem.gd** - Enemy wave spawning and progression
- **BuildingSystem.gd** - Building placement and management
- **CombatSystem.gd** - Combat resolution and damage
- **EconomySystem.gd** - Resource management
- **GridSystem.gd** - Grid-based positioning

## System Pattern

```gdscript
extends Node
class_name BaseSystem

# System initialization
func _ready() -> void:
    _initialize_system()
    _connect_events()

func _initialize_system() -> void:
    # System-specific setup
    pass

func _connect_events() -> void:
    # Connect to EventBus signals
    EventBus.connect("relevant_event", _on_relevant_event)

# Event handlers
func _on_relevant_event(data) -> void:
    # Handle event
    pass
```

## System Communication

Systems communicate through:
1. **EventBus** - Global events and state changes
2. **Direct queries** - Getting entity/component data
3. **Component modification** - Updating component state

Example:
```gdscript
# WaveSystem.gd
extends BaseSystem
class_name WaveSystem

func spawn_enemy(enemy_type: String, position: Vector2) -> void:
    var enemy_scene = load("res://scenes/entities/enemies/" + enemy_type + ".tscn")
    var enemy = enemy_scene.instantiate()
    enemy.global_position = position
    get_tree().current_scene.add_child(enemy)
    
    # Notify other systems
    EventBus.enemy_spawned.emit(enemy)
```

## System Guidelines

- Systems should be stateless when possible
- Use EventBus for cross-system communication
- Query entities through component managers
- Handle initialization order carefully
- Keep systems focused and single-purpose
