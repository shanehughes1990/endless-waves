# Movement Component System

A scene-driven finite state machine for handling movement behaviors in NPCs and enemies.

## Overview

The movement system is built around a component-based architecture where movement behaviors are composed by adding state nodes to a MovementComponent scene. This allows for flexible, reusable movement patterns that can be configured in the Godot editor.

## Architecture

```plaintext
MovementComponent (Node)
├── movement_component.gd (script)
└── Movement States (child nodes):
    ├── IdleState
    ├── MoveToTargetState
    └── WanderAndFindState (future)
```

## Core Components

### MovementComponent

- **Type**: Node
- **Script**: `movement_component.gd`
- **Purpose**: State machine controller that manages movement state transitions

#### Exported Properties

- `movement_speed: float` - Base movement speed (default: 100.0)
- `target_position: Vector2` - Target destination for movement states
- `collision_detection_range: float` - Distance threshold for collision detection (default: 5.0)

#### Signals

- `state_changed(old_state: String, new_state: String)` - Emitted when movement state changes
- `target_reached()` - Emitted when character reaches target position
- `collision_detected(body: Node2D)` - Emitted when collision is detected

### MovementState (Base Class)

- **Type**: Node
- **Script**: `movement_state.gd`
- **Purpose**: Abstract base class for all movement states

#### Required Methods

- `get_state_name() -> String` - Returns unique identifier for this state
- `enter()` - Called when entering this state
- `exit()` - Called when leaving this state
- `update(delta: float)` - Called every physics frame while active

## Available States

### IdleState

- **Purpose**: No movement, character stays in place
- **Use Case**: Default state, waiting, stationary guards

### MoveToTargetState

- **Purpose**: Move directly toward `target_position`
- **Behavior**:
  - Moves in straight line to target
  - Stops when within `collision_detection_range` of target
  - Emits `target_reached()` signal when destination reached
- **Use Case**: Enemies moving to base, NPCs moving to specific locations

### WanderAndFindState

- **Status**: Placeholder (noop implementation)
- **Future Purpose**: Random wandering with target detection
- **Use Case**: Friendly NPCs that patrol and engage enemies

## Usage

### 1. Adding Movement to an Actor

1. **Instance the MovementComponent scene** in your actor:

   ```plaintext
   YourActor (CharacterBody2D/Area2D)
   ├── Sprite2D
   ├── [Other Components]
   └── MovementComponent (instance of movement_component.tscn)
       └── MoveToTargetState (or other states)
   ```

2. **Configure the MovementComponent** in the inspector:
   - Set `movement_speed` for how fast the character moves
   - Set `target_position` if using MoveToTargetState
   - Adjust `collision_detection_range` for precision

### 2. Adding Movement States

Movement states are added as **child nodes** of the MovementComponent:

1. **Right-click MovementComponent** in scene tree
2. **Add Child** → **Instance** → Select desired state scene:
   - `idle_state.tscn`
   - `move_to_target_state.tscn`
   - `wander_and_find_state.tscn`

### 3. Controlling Movement via Script

```gdscript
# Get reference to movement component
@onready var movement_component: MovementComponent = $MovementComponent

func _ready():
    # Connect to movement signals
    movement_component.target_reached.connect(_on_target_reached)
    movement_component.state_changed.connect(_on_state_changed)

# Change movement state
func start_moving_to_base():
    movement_component.target_position = Vector2(400, 300)  # Base position
    movement_component.change_state("move_to_target")

func stop_moving():
    movement_component.change_state("idle")

# Signal callbacks
func _on_target_reached():
    print("Character reached destination!")
    
func _on_state_changed(old_state: String, new_state: String):
    print("Movement changed from ", old_state, " to ", new_state)
```

## Example Configurations

### Enemy That Attacks Base

```plaintext
Enemy (Area2D)
├── Sprite2D
├── HealthComponent
└── MovementComponent
    └── MoveToTargetState
```

**Configuration**:

- MovementComponent.movement_speed = 50.0
- MovementComponent.target_position = Vector2(400, 300) # Base position
- MovementComponent.collision_detection_range = 10.0

### Stationary Guard

```plaintext
Guard (Area2D)
├── Sprite2D
├── AttackComponent
└── MovementComponent
    └── IdleState
```

**Configuration**:

- MovementComponent starts in "idle" state
- No movement, but can switch to other states if needed

## Implementation Details

### State Discovery

The MovementComponent automatically discovers movement states by:

1. Iterating through child nodes in `_ready()`
2. Checking if node has required MovementState methods
3. Registering valid states in internal dictionary

### Physics Integration

- Uses `_physics_process()` for smooth, frame-rate independent movement
- Compatible with CharacterBody2D, RigidBody2D, and Area2D
- Lightweight collision detection using distance calculations

### Performance

- Minimal overhead when in IdleState
- Efficient state transitions with no memory allocation
- Scene-based architecture allows Godot to optimize loading

## Creating Custom States

To create new movement states:

1. **Create new script** inheriting from MovementState:

```gdscript
extends MovementState
class_name CustomMovementState

func get_state_name() -> String:
    return "custom"

func enter() -> void:
    print("Entering custom state")

func exit() -> void:
    print("Leaving custom state")

func update(delta: float) -> void:
    # Your movement logic here
    pass
```

2. **Create scene file** with Node + your script
3. **Add as child** to MovementComponent in your actor

## Best Practices

1. **State Naming**: Use descriptive, lowercase names for states
2. **Signal Usage**: Connect to MovementComponent signals for state-aware behavior
3. **Performance**: Keep `update()` methods lightweight for smooth gameplay
4. **Composition**: Mix different states for complex behaviors
5. **Configuration**: Use exported variables for designer-configurable behavior

## Future Enhancements

- **State Transitions**: Automatic state switching based on conditions
- **Animation Integration**: Sync movement states with character animations
- **Pathfinding**: Advanced movement with obstacle avoidance
- **Formation Movement**: Coordinated group movement patterns
