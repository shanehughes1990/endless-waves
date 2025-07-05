# Godot 4.4 Development Instructions

## Project Overview
This is a component-based inheritance system project for "Endless Waves" built in Godot 4.4. The architecture emphasizes composition over inheritance, clean modular code, and adherence to Godot best practices.

## Core Principles

### 1. Component-Based Architecture
- Use Node composition for functionality (HealthComponent, AttackComponent, etc.)
- Components should be self-contained and reusable
- Communicate between components using signals
- Components extend Node and are added as children to actors

### 2. Clean Code Standards
- **Build for purpose, not intent** - Only create what's immediately needed
- Keep functions small and focused (single responsibility)
- Use explicit typing with Godot 4.4's type system
- Prefer composition over inheritance
- Use meaningful, descriptive names

### 3. Godot 4.4 Idioms & Standards

#### Typing and Annotations
```gdscript
# Always use explicit typing
var health: int = 100
@export var max_health: int = 100

# Type function parameters and return values
func take_damage(damage_amount: int) -> void:
    # Implementation

# Use proper signal typing
signal health_changed(current_health: int)
```

#### Node Structure
```gdscript
# Use @onready for node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# Prefer get_node() with proper typing
var health_component: HealthComponent = get_node("HealthComponent") as HealthComponent
```

#### Resource Management
- Use `queue_free()` for safe node deletion
- Use `get_tree().create_timer()` for one-shot timers
- Prefer PackedScene for instantiation

## Project Structure Standards

### Directory Organization
```
src/
├── actors/          # Main game entities (Player, Enemy, etc.)
├── components/      # Reusable behavior components
├── autoload/        # Global singletons and managers
├── ui/             # User interface scenes and scripts
└── world/          # Game world and level scenes
```

### File Naming Conventions
- Scene files: `snake_case.tscn`
- Script files: `snake_case.gd`
- Resources: `snake_case.tres` or `snake_case.res`
- Use descriptive names that indicate purpose

## Component System Guidelines

### Component Design
1. **Single Responsibility**: Each component handles one aspect of behavior
2. **Signal Communication**: Components communicate via signals, not direct calls
3. **Export Variables**: Use `@export` for designer-configurable properties
4. **Self-Contained**: Components shouldn't depend on specific parent structure

### Component Implementation Pattern
```gdscript
extends Node
class_name ComponentName

# Signals for communication
signal component_event(data: Type)

# Exported properties for configuration
@export var property_name: Type = default_value

# Internal state
var internal_state: Type

func _ready() -> void:
    # Initialization logic
    pass

# Public interface methods
func public_method(param: Type) -> ReturnType:
    # Implementation
    pass

# Private helper methods
func _private_method() -> void:
    # Implementation
    pass
```

### Actor-Component Relationship
- Actors are composed of multiple components
- Use `get_owner()` in components to reference the parent actor
- Components should not assume specific parent types
- Use `has_node()` and `get_node()` for safe component access

## Code Quality Standards

### Error Handling
```gdscript
# Check for null/invalid references
if not target:
    return

# Validate required resources
if not projectile_scene:
    print_debug("AttackComponent: Projectile scene not set!")
    return

# Safe node access
if body.has_node("HealthComponent"):
    var health_component = body.get_node("HealthComponent")
    if health_component.has_method("take_damage"):
        health_component.take_damage(damage)
```

### Performance Considerations
- Use `_physics_process()` for physics-related updates
- Use `_process()` for frame-rate dependent logic
- Cache frequently accessed nodes with `@onready`
- Avoid string-based node access in performance-critical code

### Signal Best Practices
```gdscript
# Descriptive signal names with typed parameters
signal health_changed(current_health: int, max_health: int)
signal enemy_defeated(enemy: Node2D, experience_points: int)

# Connect signals in _ready()
func _ready() -> void:
    health_component.died.connect(_on_health_component_died)

# Use signal callbacks with proper naming
func _on_health_component_died() -> void:
    # Handle death logic
    pass
```

## Scene Architecture

### Scene Composition
- Keep scenes focused and modular
- Use inheritance for shared base functionality
- Compose complex entities from simpler components
- Separate data (resources) from behavior (scripts)

### Node Organization
```
Actor (RigidBody2D/CharacterBody2D/Area2D)
├── Sprite2D
├── CollisionShape2D
├── HealthComponent (Node)
├── AttackComponent (Node)
└── [Other Components]
```

## Development Workflow

### Godot Server Integration (MANDATORY - ZERO EXCEPTIONS)
**NEVER EDIT .tscn FILES DIRECTLY WITH TEXT TOOLS. ALWAYS USE GODOT SERVER MCP TOOLS.**

#### ABSOLUTE RULES (NO EXCEPTIONS):
- **Script Files (.gd)**: Use standard file tools (`create_file`, `replace_string_in_file`, etc.)
- **Scene Files (.tscn)**: FORBIDDEN to use `replace_string_in_file`, `create_file`, or ANY text editing tools
- **Node Trees**: FORBIDDEN to use `replace_string_in_file`, `create_file`, or ANY text editing tools
- **Project Structure**: Use Godot server MCP tools for scene management

#### FORBIDDEN ACTIONS:
- ❌ `replace_string_in_file` on ANY .tscn file
- ❌ `create_file` for ANY .tscn file
- ❌ Direct text editing of scene files
- ❌ Manual modification of node tree structures

#### MANDATORY ACTIONS:
- ✅ ONLY use `mcp_godot-server_*` tools for .tscn files
- ✅ ONLY use `mcp_godot-server_*` tools for node operations
- ✅ ALWAYS use Godot server for scene modifications

#### Required Tools for Godot Operations:
- `mcp_godot-server_create_scene` - Create new scene files and node trees
- `mcp_godot-server_add_node` - Add nodes to existing scene trees
- `mcp_godot-server_load_sprite` - Load sprites into Sprite2D nodes in scenes
- `mcp_godot-server_save_scene` - Save scene modifications and node tree changes
- `mcp_godot-server_run_project` - Run and test the project
- `mcp_godot-server_get_project_info` - Get project metadata
- `mcp_godot-server_launch_editor` - Launch Godot editor

#### Workflow Requirements:
1. **Scene Creation**: Always use `mcp_godot-server_create_scene` instead of manual .tscn file creation
2. **Node Management**: Use `mcp_godot-server_add_node` for adding components and child nodes to scene trees
3. **Resource Loading**: Use `mcp_godot-server_load_sprite` for texture assignments in scenes
4. **Scene Persistence**: Always call `mcp_godot-server_save_scene` after node tree modifications
5. **Testing**: Use `mcp_godot-server_run_project` to validate changes
6. **Project Validation**: Use `mcp_godot-server_get_project_info` to verify project state

#### Example Workflow:
```
1. Create component script with standard file tools (create_file, replace_string_in_file)
2. Use mcp_godot-server_add_node to add component to scene's node tree
3. Use mcp_godot-server_save_scene to persist node tree changes
4. Use mcp_godot-server_run_project to test functionality
```

### Creating New Components
1. Identify single responsibility
2. Define signal interface
3. Implement core functionality using standard script tools (`create_file`, `replace_string_in_file`)
4. **Use Godot server to integrate into scene node trees**
5. Add export variables for configuration
6. **Use Godot server to test in isolation**

### Adding Features
1. Analyze if existing components can be extended
2. Create new components only when necessary
3. **Use Godot server for all scene node tree modifications**
4. Ensure loose coupling between systems
5. Document component interfaces

### Code Review Checklist
- [ ] Explicit typing used throughout
- [ ] Components are self-contained
- [ ] Signals used for communication
- [ ] No hardcoded assumptions about parent structure
- [ ] Proper error handling and null checks
- [ ] Performance considerations addressed
- [ ] Code serves immediate purpose (no speculative features)
- [ ] **NEVER used text tools on .tscn files**
- [ ] **ONLY used Godot server MCP tools for scene operations**
- [ ] **NO direct editing of scene files**

## Testing and Debugging

### Godot Server Testing (MANDATORY)
**All Godot project testing MUST use the Godot server MCP tools.**

#### Required Testing Workflow:
1. **Project Validation**: Use `mcp_godot-server_get_project_info` to verify project state
2. **Runtime Testing**: Use `mcp_godot-server_run_project` to test functionality
3. **Scene Validation**: Use `mcp_godot-server_save_scene` to ensure scenes are properly saved
4. **Editor Integration**: Use `mcp_godot-server_launch_editor` for visual debugging

### Debug Practices
```gdscript
# Use print_debug for development debugging
print_debug("Component initialized with value: ", value)

# Add assertions for critical assumptions
assert(projectile_scene != null, "Projectile scene must be assigned")

# Use descriptive error messages
push_error("AttackComponent: Cannot fire without a valid target")
```

### Component Testing
- Test components in isolation using Godot server tools
- Verify signal emission and reception with `mcp_godot-server_run_project`
- Test edge cases (null values, boundary conditions)
- Ensure components work with different parent types
- **Always use Godot server for scene-based testing and node tree modifications**

## Performance Guidelines

### Memory Management
- Use object pooling for frequently created/destroyed objects (projectiles)
- Call `queue_free()` instead of `free()` for safe deletion
- Avoid creating unnecessary temporary objects in loops

### Optimization
- Profile before optimizing
- Cache expensive calculations
- Use appropriate process functions (_process vs _physics_process)
- Consider using Groups for efficient node queries

## Documentation Standards

### Code Documentation
```gdscript
## Brief description of the component's purpose.
##
## Detailed explanation of how the component works,
## what it expects, and how it should be used.

# Single-line comments for implementation details
# explaining non-obvious logic
```

### Component Interface Documentation
- Document all exported variables
- Explain signal parameters and when they're emitted
- Provide usage examples in component headers
- Document any dependencies or requirements

Remember: Build only what's needed now, keep it clean, keep it modular, and let the component system drive the architecture.
