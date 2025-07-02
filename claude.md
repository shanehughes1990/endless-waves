# Claude Guide for Godot 4 Development

## Overview

This guide helps you work effectively with Claude on Godot 4 projects. It covers best practices, common patterns, and useful prompts for game development.

## Project Context

When starting a conversation about your Godot project, provide:

- Godot version (e.g., 4.3)
- Project type (2D/3D)
- Target platforms
- Key mechanics or features

## Best Practices for Godot 4

### Scene Organization

- Use descriptive node names
- Group related nodes under parent containers
- Prefer composition over deep inheritance
- Keep scenes focused and modular

### Script Guidelines

- One script per node when possible
- Use typed GDScript for better performance
- Follow Godot naming conventions:
  - `snake_case` for variables and functions
  - `PascalCase` for classes and nodes
  - `CONSTANT_CASE` for constants
  - Leading underscore for private methods

### Signal Patterns

- Prefer signals over direct node references
- Use custom signals for decoupling
- Connect signals in `_ready()` when possible
- Document signal parameters

### Resource Management

- Use `.tres` for reusable resources
- Implement resource preloading for performance
- Create custom resources for data containers
- Avoid loading resources in `_process()`

## Common Prompts

### Scene Structure

"Create a [2D/3D] scene structure for [feature] following Godot best practices"

### Script Templates

"Write a GDScript for [node type] that handles [functionality] using Godot 4 idioms"

### Performance Optimization

"Optimize this Godot script for better performance while maintaining readability"

### Input Handling

"Implement [keyboard/mouse/controller] input for [action] using Godot's input system"

### Animation

"Create an AnimationPlayer setup for [character/object] with [states]"

## Code Templates

### Basic Node Script

```gdscript
extends Node

signal example_signal(value: int)

const MAX_VALUE := 100
var current_value: int = 0

func _ready() -> void:
 _initialize()

func _initialize() -> void:
 # Setup code here
 pass

func public_method() -> void:
 # Public API
 pass

func _private_method() -> void:
 # Internal logic
 pass
```

### Character Controller (2D)

```gdscript
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

func _physics_process(delta: float) -> void:
 # Add gravity
 if not is_on_floor():
  velocity += get_gravity() * delta
 
 # Handle jump
 if Input.is_action_just_pressed("jump") and is_on_floor():
  velocity.y = JUMP_VELOCITY
 
 # Handle movement
 var direction := Input.get_axis("move_left", "move_right")
 if direction:
  velocity.x = direction * SPEED
 else:
  velocity.x = move_toward(velocity.x, 0, SPEED)
 
 move_and_slide()
```

### State Machine Pattern

```gdscript
extends Node
class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
 for child in get_children():
  if child is State:
   states[child.name] = child
   child.state_machine = self
 
 if initial_state:
  current_state = initial_state
  current_state.enter()

func transition_to(state_name: String) -> void:
 if not states.has(state_name):
  return
 
 if current_state:
  current_state.exit()
 
 current_state = states[state_name]
 current_state.enter()
```

## Anti-Patterns to Avoid

- Polling in `_process()` when signals would work
- Deep node paths like `$"../../../Node"`
- Loading resources in loops
- Modifying physics bodies outside physics process
- Using `queue_free()` without null checks
- Circular dependencies between scenes

## Debugging Tips

- Use `@tool` scripts carefully
- Implement `_get_configuration_warnings()`
- Use `push_error()` for critical issues
- Add debug visualizations with `_draw()`
- Use the remote debugger for runtime inspection

## Export Considerations

- Set up export presets early
- Test on target platforms regularly
- Configure platform-specific settings
- Handle platform differences in code
- Use feature tags for conditional compilation

## Working with Claude

When asking for help:

1. Describe the current behavior
2. Explain the desired behavior
3. Share relevant code snippets
4. Mention any error messages
5. Specify Godot version

Example: "In Godot 4.3, I have a CharacterBody2D that should jump when pressing space. Currently, it moves horizontally but won't jump. Here's my code: [code]. The console shows no errors."

## Quick Reference

### Common Nodes

- **Control**: UI elements
- **Node2D**: 2D game objects
- **Node3D**: 3D game objects
- **Area2D/3D**: Detection zones
- **CharacterBody2D/3D**: Physics characters
- **RigidBody2D/3D**: Physics objects

### Essential Shortcuts

- `Ctrl+Shift+F`: Search in files
- `Ctrl+D`: Duplicate nodes
- `F6`: Play current scene
- `Ctrl+S`: Save scene
- `Ctrl+Alt+O`: Quick open scene

### Performance Markers

- `_ready()`: One-time setup
- `_process()`: Every frame
- `_physics_process()`: Fixed timestep
- `_input()`: Input events
- `_unhandled_input()`: Bubbled input

Remember: Godot favors simplicity and clarity. When in doubt, choose the more straightforward solution.
