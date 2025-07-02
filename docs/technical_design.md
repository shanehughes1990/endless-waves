# Endless Waves - Technical Design Document

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Component System Design](#component-system-design)
3. [Inheritance Hierarchy](#inheritance-hierarchy)
4. [Core Systems](#core-systems)
5. [Scene Structure](#scene-structure)
6. [Data Management](#data-management)
7. [Mobile Optimization](#mobile-optimization)
8. [Performance Considerations](#performance-considerations)
9. [Development Guidelines](#development-guidelines)

## 🏗️ Architecture Overview

### Design Philosophy

**Endless Waves** follows a **Component-Driven Architecture** with **Inheritance-Based Systems**. This hybrid approach provides:

- **Modularity**: Plug-and-play components for rapid development
- **Reusability**: Components work across different entity types
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features and entity types
- **Performance**: Optimized for mobile devices

### Core Principles

1. **Component Composition**: Entities gain functionality through attached components
2. **Inheritance Hierarchies**: Base classes provide common functionality
3. **Single Responsibility**: Each component handles one specific aspect
4. **Loose Coupling**: Components communicate through well-defined interfaces
5. **Data-Driven Design**: Game balance through external configuration files

## 🧩 Component System Design

### Component Architecture

```plaintext
BaseComponent (Abstract)
├── HealthComponent
├── MovementComponent
├── WeaponComponent
├── AIComponent
├── EconomyComponent
├── BuildingComponent
├── UpgradeComponent
└── EffectComponent
```

### Core Components

#### **HealthComponent**

```gdscript
class_name HealthComponent
extends BaseComponent

# Properties
@export var max_health: float = 100.0
@export var current_health: float
@export var armor: float = 0.0
@export var regeneration_rate: float = 0.0

# Signals
signal health_changed(new_health: float, max_health: float)
signal damage_taken(damage: float, source: Node)
signal death(entity: Node)
signal healed(amount: float)

# Methods
func take_damage(amount: float, source: Node = null)
func heal(amount: float)
func set_max_health(new_max: float)
func get_health_percentage() -> float
```

#### **MovementComponent**

```gdscript
class_name MovementComponent
extends BaseComponent

# Properties
@export var speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 1000.0
@export var movement_type: MovementType

enum MovementType {
    GROUND,
    FLYING,
    TELEPORT,
    STATIONARY
}

# Methods
func move_to_position(target: Vector2)
func set_movement_speed(new_speed: float)
func stop_movement()
func is_moving() -> bool
```

#### **WeaponComponent**

```gdscript
class_name WeaponComponent
extends BaseComponent

# Properties
@export var damage: float = 10.0
@export var fire_rate: float = 1.0
@export var range: float = 200.0
@export var projectile_scene: PackedScene
@export var weapon_type: WeaponType

enum WeaponType {
    PROJECTILE,
    HITSCAN,
    AREA_OF_EFFECT,
    BEAM
}

# Methods
func fire_at_target(target: Node2D)
func can_fire() -> bool
func reload()
func upgrade_weapon(upgrade_data: Dictionary)
```

#### **AIComponent**

```gdscript
class_name AIComponent
extends BaseComponent

# Properties
@export var ai_type: AIType
@export var detection_range: float = 150.0
@export var target_priority: Array[String]

enum AIType {
    AGGRESSIVE,
    DEFENSIVE,
    SUPPORT,
    PATROL,
    GUARD
}

# Methods
func find_target() -> Node2D
func execute_behavior()
func set_target(new_target: Node2D)
func update_ai_state()
```

#### **EconomyComponent**

```gdscript
class_name EconomyComponent
extends BaseComponent

# Properties
@export var cost: int = 10
@export var upkeep: int = 0
@export var reward_value: int = 5
@export var resource_generation: Dictionary

# Methods
func calculate_cost() -> int
func generate_resources() -> Dictionary
func apply_economic_effect()
```

#### **BuildingComponent**

```gdscript
class_name BuildingComponent
extends BaseComponent

# Properties
@export var construction_time: float = 5.0
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var building_type: BuildingType
@export var prerequisites: Array[String]

enum BuildingType {
    TURRET,
    BARRACKS,
    RESOURCE,
    UTILITY,
    DEFENSIVE
}

# Methods
func can_be_built_at(position: Vector2i) -> bool
func start_construction()
func complete_construction()
func demolish()
```

### Component Manager System

```gdscript
class_name ComponentManager
extends Node

# Component registry and management
var components: Dictionary = {}

func add_component(entity: Node, component: BaseComponent)
func remove_component(entity: Node, component_type: String)
func get_component(entity: Node, component_type: String) -> BaseComponent
func has_component(entity: Node, component_type: String) -> bool
```

## 🏛️ Inheritance Hierarchy

### Entity Base Classes

```
BaseEntity (Abstract)
├── BaseUnit
│   ├── DefensiveUnit
│   │   ├── InfantryUnit
│   │   ├── ArcherUnit
│   │   └── MageUnit
│   └── SupportUnit
│       ├── EngineerUnit
│       └── MedicUnit
├── BaseEnemy
│   ├── GroundEnemy
│   │   ├── BasicEnemy
│   │   ├── FastEnemy
│   │   ├── TankEnemy
│   │   └── BossEnemy
│   └── FlyingEnemy
│       ├── FlyingBasic
│       └── FlyingBoss
├── BaseBuilding
│   ├── TurretBuilding
│   │   ├── CannonTurret
│   │   ├── ArrowTurret
│   │   └── MagicTurret
│   ├── ResourceBuilding
│   │   ├── CoinGenerator
│   │   └── MaterialMine
│   ├── UtilityBuilding
│   │   ├── Barracks
│   │   ├── Workshop
│   │   └── Market
│   └── DefensiveBuilding
│       ├── Wall
│       ├── Gate
│       └── Barrier
└── BaseProjectile
    ├── BulletProjectile
    ├── ArrowProjectile
    ├── MagicProjectile
    └── ExplosiveProjectile
```

### Base Entity Implementation

```gdscript
class_name BaseEntity
extends Node2D

# Core properties
@export var entity_id: String
@export var entity_name: String
@export var faction: Faction

enum Faction {
    PLAYER,
    ENEMY,
    NEUTRAL
}

# Component references
var health_component: HealthComponent
var movement_component: MovementComponent
var weapon_component: WeaponComponent

# Virtual methods for inheritance
func _entity_ready():
    pass

func _entity_process(delta: float):
    pass

func _entity_physics_process(delta: float):
    pass

# Component management
func setup_components():
    health_component = get_component(HealthComponent)
    movement_component = get_component(MovementComponent)
    weapon_component = get_component(WeaponComponent)

func get_component(component_class) -> BaseComponent:
    for child in get_children():
        if child is component_class:
            return child
    return null
```

## ⚙️ Core Systems

### Game Manager

```gdscript
class_name GameManager
extends Node

# Singleton pattern for global game state
signal game_started
signal game_ended
signal wave_completed(wave_number: int)

var current_wave: int = 0
var game_state: GameState
var base_health: int

enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER,
    UPGRADING
}
```

### Wave Manager

```gdscript
class_name WaveManager
extends Node

# Wave configuration and spawning
var wave_data: WaveData
var current_wave_config: Dictionary
var enemies_remaining: int

func start_wave(wave_number: int)
func spawn_enemy(enemy_type: String, spawn_point: Vector2)
func is_wave_complete() -> bool
```

### Building System

```gdscript
class_name BuildingSystem
extends Node2D

# Grid-based building placement
var grid_size: Vector2i = Vector2i(50, 50)
var occupied_tiles: Dictionary = {}
var building_queue: Array[BuildingRequest]

func can_place_building(building_type: String, position: Vector2i) -> bool
func place_building(building_type: String, position: Vector2i)
func remove_building(position: Vector2i)
func get_building_at_position(position: Vector2i) -> BaseBuilding
```

### Economy System

```gdscript
class_name EconomySystem
extends Node

# Resource management
var resources: Dictionary = {
    "coins": 100,
    "materials": 50,
    "energy": 25
}

signal resource_changed(resource_type: String, amount: int)

func add_resource(type: String, amount: int)
func spend_resource(type: String, amount: int) -> bool
func can_afford(cost: Dictionary) -> bool
```

### Meta Progression System

```gdscript
class_name MetaProgressionSystem
extends Node

# Persistent upgrades between runs
var permanent_upgrades: Dictionary = {}
var total_coins_earned: int = 0

func apply_permanent_upgrades()
func purchase_upgrade(upgrade_id: String) -> bool
func save_progression()
func load_progression()
```

## 🎬 Scene Structure

### Scene Composition Pattern

Each entity scene follows this structure:

```
EntityScene.tscn
├── EntityRoot (BaseEntity)
│   ├── Sprite2D
│   ├── CollisionShape2D
│   ├── HealthComponent
│   ├── [Additional Components]
│   ├── EffectsContainer
│   │   ├── HitEffect
│   │   └── DeathEffect
│   └── UIContainer
│       ├── HealthBar
│       └── StatusIcons
```

### Example: Infantry Unit Scene

```
InfantryUnit.tscn
├── InfantryUnit (DefensiveUnit)
│   ├── Sprite2D
│   ├── CollisionShape2D
│   ├── HealthComponent
│   ├── MovementComponent
│   ├── WeaponComponent
│   ├── AIComponent
│   ├── AnimationPlayer
│   └── AudioStreamPlayer2D
```

### Example: Cannon Turret Scene

```
CannonTurret.tscn
├── CannonTurret (TurretBuilding)
│   ├── Sprite2D
│   ├── Area2D
│   │   └── CollisionShape2D
│   ├── HealthComponent
│   ├── WeaponComponent
│   ├── BuildingComponent
│   ├── TurretRotator
│   │   └── WeaponSprite
│   └── EffectsContainer
```

## 📊 Data Management

### Configuration System

All game balance data is stored in JSON files:

#### Wave Configuration (`data/waves/wave_definitions.json`)

```json
{
  "waves": [
    {
      "wave_number": 1,
      "enemies": [
        {
          "type": "BasicEnemy",
          "count": 5,
          "spawn_interval": 2.0,
          "spawn_points": ["north", "east"]
        }
      ]
    }
  ]
}
```

#### Unit Stats (`data/units/unit_stats.json`)

```json
{
  "InfantryUnit": {
    "health": 100,
    "speed": 80,
    "damage": 15,
    "cost": 25,
    "build_time": 3.0
  }
}
```

#### Building Data (`data/buildings/building_stats.json`)

```json
{
  "CannonTurret": {
    "health": 200,
    "damage": 50,
    "range": 150,
    "fire_rate": 2.0,
    "cost": {
      "coins": 100,
      "materials": 25
    }
  }
}
```

### Resource Loading System

```gdscript
class_name DataLoader
extends Node

var cached_data: Dictionary = {}

func load_json_file(file_path: String) -> Dictionary
func get_entity_stats(entity_type: String) -> Dictionary
func cache_game_data()
```

## 📱 Mobile Optimization

### Touch Input System

```gdscript
class_name TouchInputManager
extends Node

# Touch gesture recognition
var touch_start_position: Vector2
var is_dragging: bool = false
var drag_threshold: float = 20.0

signal tap_detected(position: Vector2)
signal drag_detected(start_pos: Vector2, current_pos: Vector2)
signal pinch_detected(zoom_factor: float)
```

### Performance Optimization

#### Object Pooling

```gdscript
class_name ObjectPool
extends Node

var pools: Dictionary = {}

func get_pooled_object(type: String) -> Node
func return_to_pool(object: Node, type: String)
func preload_pool(type: String, count: int)
```

#### Level of Detail (LOD) System

```gdscript
class_name LODManager
extends Node

# Reduce visual complexity based on distance/importance
func update_entity_lod(entity: BaseEntity, distance_to_camera: float)
func disable_non_essential_components(entity: BaseEntity)
```

## 🎯 Performance Considerations

### Memory Management

- **Object Pooling**: Reuse enemy and projectile instances
- **Texture Streaming**: Load/unload textures based on needs
- **Audio Management**: Limit concurrent audio streams
- **Garbage Collection**: Minimize object allocations in update loops

### Rendering Optimization

- **Sprite Batching**: Group similar sprites for efficient rendering
- **Culling**: Don't render off-screen entities
- **Reduced Effects**: Scale particle effects based on device performance
- **Texture Compression**: Use appropriate formats for mobile

### Update Loop Optimization

- **Component Update Priorities**: Update critical components first
- **Frame Rate Targeting**: Adaptive quality based on performance
- **Background Processing**: Move heavy calculations to separate threads

## 🛠️ Development Guidelines

### Component Development Rules

1. **Single Responsibility**: Each component handles one specific aspect
2. **No Direct References**: Components communicate through signals or interfaces
3. **Data Validation**: Always validate input parameters
4. **Performance Awareness**: Consider mobile constraints in all designs

### Inheritance Best Practices

1. **Virtual Methods**: Use virtual methods for extensible behavior
2. **Proper Initialization**: Call parent initialization methods
3. **Component Setup**: Establish component references in _ready()
4. **Clean Hierarchy**: Keep inheritance trees shallow and logical

### Code Organization

```
scripts/
├── core/
│   ├── BaseEntity.gd
│   ├── BaseComponent.gd
│   └── interfaces/
├── components/
│   ├── HealthComponent.gd
│   ├── MovementComponent.gd
│   └── WeaponComponent.gd
├── entities/
│   ├── units/
│   ├── buildings/
│   └── enemies/
└── managers/
    ├── GameManager.gd
    ├── WaveManager.gd
    └── BuildingSystem.gd
```

### Testing Strategy

- **Component Testing**: Unit tests for individual components
- **Integration Testing**: Test component interactions
- **Performance Testing**: Monitor frame rates and memory usage
- **Device Testing**: Test on various mobile devices and screen sizes

## 🔄 Development Workflow

### Implementation Order

1. **Core Architecture**: Base classes and component system
2. **Basic Entities**: Simple units and buildings with core components
3. **Core Systems**: Game manager, wave system, building placement
4. **Advanced Features**: AI, economy, meta progression
5. **Polish**: Effects, audio, UI improvements
6. **Optimization**: Performance tuning and mobile optimization

### Version Control Strategy

- **Feature Branches**: Separate branches for major systems
- **Component Isolation**: Test components independently
- **Regular Integration**: Frequent merges to avoid conflicts
- **Build Automation**: Automated testing and mobile builds

---

This technical design document provides the foundation for building **Endless Waves** with a robust, scalable, and maintainable architecture. The component-driven design with inheritance hierarchies will enable rapid development while maintaining code quality and performance on mobile devices.

**Next Steps**: Begin with implementing the core base classes and essential components (Health, Movement, Weapon), then build up the entity hierarchy and core game systems.
