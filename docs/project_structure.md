# Endless Waves - Project Structure

Following Godot 4 best practices and component-driven architecture principles.

## 🏗️ Architecture Overview

This project uses a **Component-Driven Design** with **Inheritance Patterns** optimized for Godot 4:

- **Modular Components**: Reusable behaviors attached to nodes
- **Scene Composition**: Godot scenes as entity templates
- **Resource-Driven**: External data files for balance and configuration
- **Signal-Based Communication**: Loose coupling between systems
- **Typed GDScript**: Performance and maintainability

## 📁 Directory Structure

```plaintext
endless-waves/
├── .godot/                     # Godot engine files (gitignored)
├── .git/                       # Git repository
├── addons/                     # Third-party plugins and custom tools
│   └── component_system/       # Custom component framework
├── autoloads/                  # Singleton scripts (AutoLoad)
│   ├── GameManager.gd          # Global game state
│   ├── EventBus.gd            # Global signal communication
│   ├── AudioManager.gd        # Audio management
│   ├── SaveManager.gd         # Save/load system
│   └── DataLoader.gd          # Configuration loading
├── components/                 # 🧩 Reusable component scripts
│   ├── combat/                 # Combat-related components
│   │   ├── HealthComponent.gd
│   │   ├── WeaponComponent.gd
│   │   ├── ArmorComponent.gd
│   │   └── DamageComponent.gd
│   ├── movement/               # Movement and positioning
│   │   ├── MovementComponent.gd
│   │   ├── PathfindingComponent.gd
│   │   └── GridPositionComponent.gd
│   ├── ai/                     # AI behavior components
│   │   ├── AIComponent.gd
│   │   ├── StateMachineComponent.gd
│   │   └── TargetingComponent.gd
│   ├── economy/                # Economy and resources
│   │   ├── CostComponent.gd
│   │   ├── ResourceGeneratorComponent.gd
│   │   └── UpgradeComponent.gd
│   ├── building/               # Building-specific components
│   │   ├── PlacementComponent.gd
│   │   ├── ConstructionComponent.gd
│   │   └── ProductionComponent.gd
│   └── ui/                     # UI-related components
│       ├── HealthBarComponent.gd
│       ├── InfoDisplayComponent.gd
│       └── InteractionComponent.gd
├── data/                       # 📊 Game configuration (JSON/Resources)
│   ├── units/                  # Unit definitions
│   │   ├── unit_stats.tres     # Unit base stats resource
│   │   └── unit_abilities.json # Ability configurations
│   ├── buildings/              # Building definitions
│   │   ├── building_stats.tres
│   │   └── building_costs.json
│   ├── enemies/                # Enemy definitions
│   │   ├── enemy_stats.tres
│   │   └── spawn_patterns.json
│   ├── waves/                  # Wave system configuration
│   │   ├── wave_definitions.json
│   │   └── difficulty_curves.json
│   ├── progression/            # Meta progression
│   │   ├── upgrades.json
│   │   └── achievements.json
│   └── economy/                # Economic balance
│       ├── costs.json
│       └── rewards.json
├── scenes/                     # 🎬 Godot scene files
│   ├── main/                   # Core game scenes
│   │   ├── Main.tscn           # Main scene entry point
│   │   ├── MainMenu.tscn       # Main menu
│   │   └── GameArena.tscn      # Main gameplay scene
│   ├── entities/               # Entity prefab scenes
│   │   ├── units/              # Unit prefabs
│   │   │   ├── Unit.tscn       # Base unit scene
│   │   │   ├── Infantry.tscn
│   │   │   ├── Archer.tscn
│   │   │   └── Mage.tscn
│   │   ├── buildings/          # Building prefabs
│   │   │   ├── Building.tscn   # Base building scene
│   │   │   ├── CannonTurret.tscn
│   │   │   ├── Barracks.tscn
│   │   │   └── Wall.tscn
│   │   ├── enemies/            # Enemy prefabs
│   │   │   ├── Enemy.tscn      # Base enemy scene
│   │   │   ├── BasicEnemy.tscn
│   │   │   └── BossEnemy.tscn
│   │   └── projectiles/        # Projectile scenes
│   │       ├── Bullet.tscn
│   │       ├── Arrow.tscn
│   │       └── Fireball.tscn
│   ├── ui/                     # User interface scenes
│   │   ├── GameHUD.tscn        # In-game UI overlay
│   │   ├── BuildMenu.tscn      # Building selection
│   │   ├── UnitPanel.tscn      # Unit management
│   │   ├── PauseMenu.tscn      # Pause screen
│   │   ├── UpgradeMenu.tscn    # Meta progression
│   │   └── SettingsMenu.tscn   # Game settings
│   └── effects/                # Visual/audio effect scenes
│       ├── Explosion.tscn
│       ├── HitEffect.tscn
│       └── BuildingPlacement.tscn
├── scripts/                    # 📜 Entity and system scripts
│   ├── entities/               # Entity behavior scripts
│   │   ├── BaseEntity.gd       # Root entity class
│   │   ├── BaseUnit.gd         # Base unit behavior
│   │   ├── BaseBuilding.gd     # Base building behavior
│   │   ├── BaseEnemy.gd        # Base enemy behavior
│   │   └── BaseProjectile.gd   # Base projectile behavior
│   ├── systems/                # Game system managers
│   │   ├── WaveSystem.gd       # Wave spawning and management
│   │   ├── BuildingSystem.gd   # Building placement and management
│   │   ├── CombatSystem.gd     # Combat resolution
│   │   ├── EconomySystem.gd    # Resource management
│   │   └── GridSystem.gd       # Grid-based positioning
│   ├── ui/                     # UI controller scripts
│   │   ├── GameHUD.gd
│   │   ├── BuildMenu.gd
│   │   ├── TouchControls.gd
│   │   └── MainMenu.gd
│   └── utils/                  # Utility scripts and helpers
│       ├── ObjectPool.gd       # Object pooling system
│       ├── GridUtils.gd        # Grid calculation helpers
│       └── MathUtils.gd        # Mathematical utilities
├── assets/                     # 🎨 Game resources
│   ├── textures/               # All image files
│   │   ├── units/              # Unit sprites
│   │   ├── buildings/          # Building graphics
│   │   ├── enemies/            # Enemy sprites
│   │   ├── ui/                 # Interface graphics
│   │   ├── effects/            # Effect textures
│   │   └── environment/        # Background/terrain
│   ├── audio/                  # Sound files
│   │   ├── music/              # Background music
│   │   ├── sfx/                # Sound effects
│   │   │   ├── combat/
│   │   │   ├── ui/
│   │   │   └── ambient/
│   │   └── voice/              # Voice lines (if any)
│   ├── fonts/                  # Font files
│   └── materials/              # Material resources
├── export/                     # 📦 Export templates and builds
│   ├── presets/                # Export preset configurations
│   ├── android/                # Android builds
│   └── ios/                    # iOS builds
├── tools/                      # 🔧 Development tools
│   ├── scripts/                # Build and deployment scripts
│   └── editor/                 # Custom editor tools
├── tests/                      # 🧪 Unit and integration tests
│   ├── unit/                   # Component unit tests
│   └── integration/            # System integration tests
├── docs/                       # 📚 Documentation
│   ├── design/                 # Game design documents
│   ├── technical/              # Technical documentation
│   └── guides/                 # Development guides
├── .editorconfig              # Editor configuration
├── .gitattributes             # Git attributes
├── .gitignore                 # Git ignore rules
├── project.godot              # Godot project configuration
├── claude.md                  # AI assistant guide
├── README.md                  # Project overview
└── export_presets.cfg         # Godot export settings
```

## 🎯 Godot Best Practices Applied

### 1. **Scene Organization**

- **Modular Scenes**: Each entity is a self-contained scene
- **Component Composition**: Entities built from component nodes
- **Descriptive Names**: Clear, purposeful node naming
- **Focused Scenes**: Single responsibility per scene

### 2. **Script Guidelines**

- **Typed GDScript**: All variables and functions properly typed
- **Naming Conventions**:
  - `snake_case` for variables/functions
  - `PascalCase` for classes/files
  - `CONSTANT_CASE` for constants
- **One Script Per Node**: Clean separation of concerns
- **Signal-Based**: Loose coupling through signals

### 3. **Resource Management**

- **`.tres` Files**: Reusable resource definitions
- **Preloading**: Critical resources loaded at startup
- **Custom Resources**: Data containers for game stats
- **External Config**: JSON for easy balance tweaking

### 4. **Performance Optimization**

- **Object Pooling**: Efficient projectile/enemy reuse
- **Component Caching**: Store component references
- **Typed References**: Better performance with typing
- **AutoLoad Singletons**: Global systems management

## 🧩 Component System Integration

### Component Attachment Pattern

```gdscript
# In entity scenes, components are child nodes
# BaseUnit.gd
extends CharacterBody2D
class_name BaseUnit

@onready var health_component: HealthComponent = $HealthComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var movement_component: MovementComponent = $MovementComponent

func _ready() -> void:
    _setup_component_connections()

func _setup_component_connections() -> void:
    health_component.died.connect(_on_death)
    weapon_component.weapon_fired.connect(_on_weapon_fired)
```

### Data-Driven Configuration

```gdscript
# DataLoader.gd (AutoLoad)
extends Node

var unit_stats: Dictionary = {}
var building_stats: Dictionary = {}

func _ready() -> void:
    _load_game_data()

func _load_game_data() -> void:
    unit_stats = _load_json_file("res://data/units/unit_stats.json")
    building_stats = _load_json_file("res://data/buildings/building_stats.json")
```

### Signal-Based Communication

```gdscript
# EventBus.gd (AutoLoad)
extends Node

# Game events
signal wave_started(wave_number: int)
signal enemy_defeated(enemy_type: String)
signal building_placed(building_type: String, position: Vector2i)
signal unit_recruited(unit_type: String)

# UI events
signal resource_changed(resource_type: String, amount: int)
signal building_selected(building: BaseBuilding)
```

## 🎮 Development Workflow

### 1. **Component Development**

1. Create component script in `components/`
2. Define typed properties and signals
3. Implement component logic
4. Test in isolation

### 2. **Entity Creation**

1. Create base entity script in `scripts/entities/`
2. Create entity scene in `scenes/entities/`
3. Attach required components as child nodes
4. Configure through data files

### 3. **System Integration**

1. Create system script in `scripts/systems/`
2. Connect to EventBus for communication
3. Register as AutoLoad if needed
4. Test system interactions

### 4. **Scene Composition**

1. Build scenes from entity prefabs
2. Configure through Inspector
3. Use signals for scene communication
4. Test in context

## 📝 File Naming Conventions

- **Scripts**: `PascalCase.gd` (e.g., `HealthComponent.gd`)
- **Scenes**: `PascalCase.tscn` (e.g., `CannonTurret.tscn`)
- **Resources**: `snake_case.tres` (e.g., `unit_stats.tres`)
- **Data Files**: `snake_case.json` (e.g., `wave_definitions.json`)
- **Textures**: `snake_case.png` (e.g., `archer_idle.png`)
- **Audio**: `snake_case.ogg` (e.g., `cannon_fire.ogg`)

## 🔧 Development Tools

- **AutoLoad Systems**: Global state management
- **Custom Resources**: Type-safe data containers
- **Component Framework**: Reusable behavior system
- **Object Pooling**: Performance optimization
- **Event Bus**: Decoupled communication

This structure balances Godot best practices with our component-driven architecture, providing a solid foundation for scalable tower defense game development.
